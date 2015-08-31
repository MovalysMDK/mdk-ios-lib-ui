/**
 * Copyright (C) 2010 Sopra (support_movalys@sopra.com)
 *
 * This file is part of Movalys MDK.
 * Movalys MDK is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * Movalys MDK is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 * You should have received a copy of the GNU Lesser General Public License
 * along with Movalys MDK. If not, see <http://www.gnu.org/licenses/>.
 */

#import "MFPickerList.h"

//Extension
#import "MFPickerListExtension.h"

//Delegates
#import "MFPickerListItemBindingDelegate.h"
#import "MFPickerSelectedItemBindingDelegate.h"
#import "MFUIBaseListViewModel.h"

#import "MFFormViewController.h"

@interface MFPickerList ()

/**
 * @brief The extension for PickerList
 */
@property (nonatomic, strong) MFPickerListExtension *mf;

/**
 * @brief Le tableau contenant les données de la Liste éditable
 */
@property (nonatomic, strong) MFUIBaseViewModel *data;
/**
 * @brief Indicates if the constraints between the storyboard and the pickerlist have been added
 */
@property (nonatomic) BOOL constraintsAdded;

@end

@implementation MFPickerList
@synthesize controlAttributes = _controlAttributes;
@synthesize data = _data;
@synthesize targetDescriptors = _targetDescriptors;

-(void)initialize {
    [super initialize];
    self.mf = [MFPickerListExtension new];
    
    self.constraintsAdded = NO;
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
}


#pragma mark - MFUIComponentProtocol methods

+(NSString *)getDataType {
    return @"MFUIBaseViewModel";
}

/**
 * @brief Returns the value of the field
 * @return the value of the field
 */

-(MFUIBaseViewModel *) getData {
    return _data;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void)setData:(MFUIBaseViewModel *)data {
    if(![_data isEqual:data] && ![data isKindOfClass:[MFKeyNotFound class]]) {
        _data= data;
        [self.mf.selectedItemBindingDelegate performSelector:@selector(computeCellHeightAndDispatchToFormController)];
        [self.mf.selectedItemBindingDelegate performSelector:@selector(updateStaticView)];
    }
    [self validate];
}
#pragma clang diagnostic pop


-(void)setControlAttributes:(NSDictionary *)controlAttributes {
    _controlAttributes = controlAttributes;
    NSString *selectedItemBindingDelegate = controlAttributes[@"selectedItemBindingDelegate"];
    if(selectedItemBindingDelegate && !self.mf.selectedItemBindingDelegate) {
        self.mf.selectedItemBindingDelegate = [[NSClassFromString(selectedItemBindingDelegate) alloc] initWithPickerList:self];
    }
    else {
        self.mf.selectedItemBindingDelegate.picker = self;
    }
    
    NSString *listItemBindingDelegate = controlAttributes[@"listItemBindingDelegate"];
    if(listItemBindingDelegate && !self.mf.listItemBindingDelegate) {
        self.mf.listItemBindingDelegate = [[NSClassFromString(listItemBindingDelegate) alloc] initWithPickerList:self];
    }
    else {
        self.mf.listItemBindingDelegate.picker = self;
    }
    
    
    NSString *pickerValuesKey = controlAttributes[@"pickerValuesKey"];
    if(pickerValuesKey && !self.mf.pickerValuesKey) {
        self.mf.pickerValuesKey = pickerValuesKey;
    }
    
    NSString *filter = controlAttributes[@"filter"];
    if(filter && !self.mf.filter) {
        self.mf.filter = [NSClassFromString(filter) new];
        self.mf.listItemBindingDelegate.filter = self.mf.filter;
    }
    
    NSNumber *hasSearch = controlAttributes[@"search"];
    if(hasSearch) {
        self.mf.hasSearch = [hasSearch boolValue];
        self.mf.listItemBindingDelegate.hasSearch = self.mf.hasSearch;
    }
}

-(void)setSelectedView:(UIView *)selectedView {
    if(!_selectedView || ![_selectedView isEqual:selectedView]) {
        if(_selectedView) {
            [_selectedView removeFromSuperview];
        }
        _selectedView = (MFBindingViewAbstract *)selectedView;
        
        [self setNeedsDisplay];
        //Dans la vue sélectionnée, les champs ne sont pas éditables
        for(UIView * view in selectedView.subviews) {
            view.userInteractionEnabled = NO;
        }
        [self addSubview:_selectedView];
        [_selectedView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addCustomConstraints];
        [self updateConstraints];
    }
}

-(void) addCustomConstraints {
    if(self.selectedView) {
        
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.selectedView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.selectedView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.selectedView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.selectedView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        [self addConstraints:@[topConstraint, leftConstraint, rightConstraint, bottomConstraint]];
        self.constraintsAdded = YES;
        
    }
}



#pragma mark - GestureRecognizers methods

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    
    UIView *currentView = touch.view;
    while (currentView) {
        if([self.selectedView isEqual:touch.view]) {
            if([self.editable isEqualToNumber:@1]) {
                [self displayPickerView];
                [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
            }
            break;
        }
        currentView = currentView.superview;
    }
    
}

-(void) displayPickerView {
    
    NSString *xibIdentifier = @"PickerListView";
    if(self.mf.hasSearch) {
        xibIdentifier = @"PickerListViewWithSearch";
    }
    
    self.pickerListTableView = [[[NSBundle bundleForClass:[MFPickerListTableView class]] loadNibNamed:xibIdentifier owner:self.mf.listItemBindingDelegate options:nil] firstObject];
    self.pickerListTableView.tableView.delegate = self.mf.listItemBindingDelegate;
    self.pickerListTableView.tableView.dataSource = self.mf.listItemBindingDelegate;
    self.pickerListTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.parentNavigationController.view addSubview:self.pickerListTableView];
    
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.pickerListTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.parentNavigationController.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.pickerListTableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.parentNavigationController.view  attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.pickerListTableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.parentNavigationController.view  attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.pickerListTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.parentNavigationController.view  attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    [self.parentNavigationController.view addConstraints:@[right, left, bottom, top]];
    self.pickerListTableView.alpha = 0;
    [self.mf.listItemBindingDelegate willDisplayPickerListView];
    [UIView animateWithDuration:0.25 animations:^{
        self.pickerListTableView.alpha = 1;
    } completion:^(BOOL finished) {
        if(finished) {
            int index = 0;
            for(id object in [self getValues]) {
                if([object isEqual:[self getData]]) {
                    break;
                }
                index++;
            }
            [self.pickerListTableView.tableView reloadData];
            //SI index < au nombre d'items on scroll vers l'item sélectionné, sinon on ne scrolle pas : aucun item n'est sélectionné (cas de l'itinitalisation)
            if(index < [self getValues].count) {
                [self.pickerListTableView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }
    }];
}

-(NSArray *) getValues {
    MFUIBaseListViewModel *values = nil;
    if(self.mf.pickerValuesKey) {
        MFUIBaseViewModel *formViewModel = (MFUIBaseViewModel *)[((MFFormViewController *)self.parentViewController) getViewModel];
        
        if([self.parentViewController conformsToProtocol:@protocol(MFDetailViewControllerProtocol)] && [self.parentViewController respondsToSelector:@selector(parentFormController)]) {
            formViewModel = [((MFFormBaseViewController *)[((id<MFDetailViewControllerProtocol>)self.parentViewController) parentFormController]) getViewModel];
        }
        
        //SI le controller répond à partialViewModelKeys, on est dans le cas d'un controller conteneur
        // et on prend du coup le ViewModel associé à l'une des clés qui nous est donnée,
        //SINON on remontre dans les parentViewModel jusqu'à trouver le ListViewModel recherché.
        if([self.parentViewController respondsToSelector:@selector(partialViewModelKeys)]
           && [(NSArray *)[self.parentViewController performSelector:@selector(partialViewModelKeys)] count] > 0 ) {
            MFFormViewController *controller = (MFFormViewController *)self.parentViewController;
            for(NSString *key in [controller partialViewModelKeys]) {
                if([formViewModel respondsToSelector:NSSelectorFromString(key)]) {
                    formViewModel = [formViewModel valueForKey:key];
                }
            }
        }
        else {
            while(formViewModel && ![formViewModel respondsToSelector:NSSelectorFromString(self.mf.pickerValuesKey)]) {
                formViewModel = (MFUIBaseViewModel *)formViewModel.parentViewModel;
            }
        }
        
        id object = [formViewModel valueForKeyPath:self.mf.pickerValuesKey];
        if(object && [object isKindOfClass:[MFUIBaseListViewModel class]]) {
            values = (MFUIBaseListViewModel *) object;
        }
    }
    return values.viewModels;
}

-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    MFControlChangedTargetDescriptor *commonCCTD = [MFControlChangedTargetDescriptor new];
    commonCCTD.target = target;
    commonCCTD.action = action;
    self.targetDescriptors = @{@(self.hash) : commonCCTD};
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void) valueChanged:(UIView *)sender {
    MFControlChangedTargetDescriptor *cctd = self.targetDescriptors[@(sender.hash)];
    [cctd.target performSelector:cctd.action withObject:self];
}
#pragma clang diagnostic pop


-(void)prepareForInterfaceBuilder {
    self.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1];
    UILabel *innerDescriptionLabel = [[UILabel alloc] initWithFrame:self.bounds];
    innerDescriptionLabel.text = [[self class] description];
    innerDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    innerDescriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    [self addSubview:innerDescriptionLabel];
}

@end

@implementation MFPickerListDefaultFilter

-(NSArray *)filterItems:(NSArray *)items withString:(NSString *)string {
    NSMutableArray *result = [NSMutableArray array];
    for(MFUIBaseViewModel *viewModel in items) {
        for(NSString *bindedProtperty in [viewModel getBindedProperties]) {
            id object = [viewModel valueForKey:bindedProtperty];
            if([object isKindOfClass:[NSString class]]) {
                if([(NSString *)object containsString:string]) {
                    [result addObject:viewModel];
                    break;
                }
            }
        }
    }
    return result;
}



@end
