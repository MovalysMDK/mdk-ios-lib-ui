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
//
//  MFFixedList.m
//  MFUI
//
//

#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreBean.h>

#import "MFFixedList.h"
#import "MFUIBaseListViewModel.h"



@interface MFFixedList()

/**
 * @brief An array containinig the custom buttons created by in the user project
 */
@property (nonatomic, strong) NSArray *customButtonsArray;

/**
 * @brief The buttons view container of this component
 */
@property (nonatomic, strong) UIView *buttonsView;

/**
 * @brief The waiting view displayed during data loading of the component
 */
//@property (nonatomic, strong) UIView *waitingView;

/**
 * @brief A BOOL that indicates if the waitingView should be shown or not
 */
@property (nonatomic) BOOL dismissWaitingView;

/**
 * @brief The constraint that defines the dynamic height of the fixedList
 */
@property (nonatomic, strong) NSLayoutConstraint *fixedListHeightConstraint;

/**
 * @brief The constraint that defines the dynamic height of the fixedList
 */
@property (nonatomic, strong) MFUIBaseListViewModel *data;

@end

//Parameters keys
NSString *const FIXED_LIST_PARAMETER_DATA_DELEGATE_NAME = @"dataDelegateName";
NSString *const FIXED_LIST_PARAMETER_ROW_HEIGHT = @"rowHeight";
NSString *const FIXED_LIST_PARAMETER_FORM_DESCRIPTOR_NAME = @"formDescriptorName";
NSString *const FIXED_LIST_PARAMETER_CAN_EDIT_ITEM = @"canEditItem";
NSString *const FIXED_LIST_PARAMETER_CAN_ADD_ITEM = @"canAddItem";
NSString *const FIXED_LIST_PARAMETER_CAN_DELETE_ITEM = @"canDeleteItem";
NSString *const FIXED_LIST_PARAMETER_EDIT_MODE = @"editMode";
NSString *const FIXED_LIST_PARAMETER_IS_PHOTO = @"isPhotoFixedList";



@implementation MFFixedList

#pragma mark - Synthesizing

@synthesize cellContainer = _cellContainer;
@synthesize localizedFieldDisplayName = _localizedFieldDisplayName;
@synthesize groupDescriptor = _groupDescriptor;
@synthesize isValid = _isValid;
@synthesize form = _form;
@synthesize componentInCellAtIndexPath =_componentInCellAtIndexPath;


#pragma mark - Initializing

-(void) initialize {
    [super initialize];
    //self.hasBeenReload = NO;
    self.dismissWaitingView = NO;
    if(!self.tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.titleLabel = [[UILabel alloc] init];
    }
    self.mf = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_FORM_EXTEND];
    
    self.customButtonsArray = [NSArray array];
    
    // Nécessaire pour ne pas bloquer le "ScrollsToTop" du formulaire parent.
    [self.tableView setScrollsToTop:NO];
    
    [self.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.titleLabel setMinimumScaleFactor:0.5];
    
    
    self.topBarView = [[UIView alloc] init];
    self.topBarView.userInteractionEnabled = YES;
    
    [self addSubview:self.tableView];
    [self addSubview:self.topBarView];
    
    self.buttonsView = [[UIView alloc] init];
    self.buttonsView.userInteractionEnabled = YES;
    [self.topBarView addSubview:self.buttonsView];
    [self.topBarView addSubview:self.titleLabel];
        
    self.tableView.scrollEnabled = NO;
    
    
}

-(void)awakeFromNib {
    [super awakeFromNib];
    dispatch_async(dispatch_get_main_queue(), ^{
        //        self.tableView.frame = self.bounds;
        [self defineAndAddConstraint];
    });
    
}

-(void) changeDynamicHeight:(int)newHeight {
    if(!self.fixedListHeightConstraint) {
        for(NSLayoutConstraint *constraint in self.constraints) {
            if([constraint firstAttribute] == NSLayoutAttributeHeight && [[constraint firstItem] isEqual:self] && ![constraint secondItem]) {
                self.fixedListHeightConstraint = constraint;
            }
        }
    }
    
    [self.fixedListHeightConstraint setConstant:newHeight];
    [self updateConstraints];
}

-(void)defineAndAddConstraint {
    int customButtonsMargin = [self.dataDelegate marginForCustomButtons];
    
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.topBarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //    [self.waitingView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.buttonsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    //display a button if the user is allowed to add an item
    [self resetCustomButtons];
    [self refreshCustomButtons];
    
    NSLayoutConstraint *topBarViewWidth = [NSLayoutConstraint constraintWithItem:self.topBarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    NSLayoutConstraint *topBarViewHeight = [NSLayoutConstraint constraintWithItem:self.topBarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:[self topBarViewHeight]];
    NSLayoutConstraint *topBarViewLeft = [NSLayoutConstraint constraintWithItem:self.topBarView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *topBarViewTop = [NSLayoutConstraint constraintWithItem:self.topBarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    
    NSLayoutConstraint *tableViewRight = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *tableViewBottom = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *tableViewLeft = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *tableViewTop = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topBarView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    NSLayoutConstraint *buttonsViewHeight = [NSLayoutConstraint constraintWithItem:self.buttonsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.topBarView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    NSLayoutConstraint *buttonsViewRight = [NSLayoutConstraint constraintWithItem:self.buttonsView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.topBarView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *buttonsViewTop = [NSLayoutConstraint constraintWithItem:self.buttonsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topBarView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSInteger buttonsViewsize = [self customButtonsArray].count * [self topBarViewHeight] + ([self customButtonsArray].count -1) * customButtonsMargin;
    NSLayoutConstraint *buttonsViewWidth = [NSLayoutConstraint constraintWithItem:self.buttonsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:buttonsViewsize];
    
    if(![self showButtons]) {
        buttonsViewWidth = [NSLayoutConstraint constraintWithItem:self.buttonsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:0];
    }
    if(![self showTitle]) {
        buttonsViewWidth = [NSLayoutConstraint constraintWithItem:self.buttonsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.topBarView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    }
    
    
    NSLayoutConstraint *titleLabelLeft = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.topBarView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *titleLabelTop = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topBarView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *titleLabelBottom = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.topBarView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *titleLabelRight = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.buttonsView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    
    
    
    [self.topBarView addConstraints:@[
                                      buttonsViewHeight, buttonsViewRight, buttonsViewTop, buttonsViewWidth,
                                      titleLabelLeft, titleLabelTop, titleLabelRight, titleLabelBottom
                                      ]];
    
    [self addConstraints:@[
                           topBarViewHeight, topBarViewLeft, topBarViewTop, topBarViewWidth,
                           tableViewRight, tableViewBottom,tableViewLeft, tableViewTop
                           ]];
    
}

#pragma mark - Méthodes dérivées de MFUIBaseComponent

+(NSString *)getDataType {
    return @"MFUIBaseListViewModel";
}

/**
 * @brief Set value of the field
 * @param value the value of the string
 */
-(void) setData:(id)data {
    //Set Data
    _data= data;
    if(data && ![data isKindOfClass:[MFKeyNotFound class]]) {
        [self updateValue:data];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    
    self.tableView.editing = self.mf.canDeleteItem;
}

-(BOOL) dataDifferentFrom:(id) data
{
    if(_data != nil || data !=nil) {
        if(_data !=nil && data !=nil) {
            if(![_data isEqual:data]) {
                return true;
            }
        } else {
            return true;
        }
    }
    
    return false;
}

-(void) setDataAfterEdition:(id)data {
    _data= data;
    [self updateValue:data];
}

/**
 * @brief Returns the value of the field
 * @return the value of the field
 */
-(MFUIBaseListViewModel *) getData {
    return self.data;
}


-(void)setMandatory:(NSNumber *)mandatory {
    //Non implémenté
}



-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    if([self.editable isEqualToNumber:@0]) {
        self.mf.canAddItem = NO;
        self.mf.canDeleteItem = NO;
        if(self.mf.canEditItem) {
            self.editMode = MFFixedListEditModePopup;
        }
    }
}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.tableView.tag == 0) {
        [self.tableView setTag:TAG_MFFIXEDLIST_TABLEVIEW];
    }
    if (self.topBarView.tag == 0) {
        [self.topBarView setTag:TAG_MFFIXEDLIST_TOPBARVIEW];
    }
}


#pragma mark - Fast Forwarding UILabel methods

-(id)forwardingTargetForSelector:(SEL)sel {
    return self.tableView;
}



#pragma mark - KVC magic forwarding

-(id)valueForUndefinedKey:(NSString *)key {
    if(![key isEqualToString:@"mf."]) {
        return [self.tableView valueForKey:key];
    }
    else {
        return [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_KEYNOTFOUND];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    [self.tableView setValue:value forKey:key];
}

#pragma mark - Custom methods

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
-(void) addItem {
    if([self.dataDelegate respondsToSelector:NSSelectorFromString(@"addItemOnFixedList")]) {
        [self.dataDelegate performSelector:NSSelectorFromString(@"addItemOnFixedList")];
    }
}
#pragma clang diagnostic pop


#pragma mark - Buttons
-(void) addCustomButton:(UIButton *)button {
    NSMutableArray *buttons = [self.customButtonsArray mutableCopy];
    [buttons addObject:button];
    self.customButtonsArray = buttons;
    
}

-(void) removeCustomButtonAtIndex:(int) index{
    NSMutableArray *buttons = [self.customButtonsArray mutableCopy];
    if(index < self.customButtonsArray.count) {
        [buttons removeObjectAtIndex:index];
        self.customButtonsArray = buttons;
        [self refreshCustomButtons];
    }
}

-(void) removeCustomButton:(UIButton *) button{
    NSMutableArray *buttons = [self.customButtonsArray mutableCopy];
    [buttons removeObject:button];
    self.customButtonsArray = buttons;
    [self refreshCustomButtons];
}

-(void) refreshCustomButtons {
    for(UIButton *button in [self.dataDelegate customButtonsForFixedList]) {
        [self addCustomButton:button];
    }
    
    int marginForCustomButtons = -[self.dataDelegate marginForCustomButtons];
    CGSize sizeForCustomButtons = [self.dataDelegate sizeForCustomButtons];
    
    self.buttonsView.userInteractionEnabled = YES;
    [self.topBarView addSubview:self.buttonsView];
    [self.topBarView bringSubviewToFront:self.buttonsView];
    
    UIButton *lasButtonReference = nil;
    for(UIButton *button in self.customButtonsArray) {
        [self.buttonsView addSubview:button];
        
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *rightButtonMargin = nil;
        NSLayoutConstraint *centerYButton = nil;
        NSLayoutConstraint *buttonWidth = nil;
        NSLayoutConstraint *buttonHeight = nil;
        //NSLayoutConstraint *leftContainer = nil;
        
        if([self.customButtonsArray indexOfObject:button] == 0 ) {
            if([self buttonsAlignment] == MFFixedListAlignmentCenter) {
                rightButtonMargin = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.buttonsView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
            }
            else if([self buttonsAlignment] == MFFixedListAlignmentRight){
                rightButtonMargin = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.buttonsView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
            }
            else {
                rightButtonMargin = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.buttonsView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
            }
            
        }
        else {
            if(lasButtonReference) {
                rightButtonMargin = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:lasButtonReference attribute:NSLayoutAttributeLeft multiplier:1 constant:marginForCustomButtons];
            }
        }
        centerYButton = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.buttonsView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        buttonWidth = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:sizeForCustomButtons.width];
        buttonHeight = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:sizeForCustomButtons.height];
        
        [self.buttonsView addConstraints:@[rightButtonMargin, centerYButton, buttonHeight, buttonWidth ]];
        lasButtonReference = button;
    }
    
}

-(void)resetCustomButtons {
    for(UIView *button in self.buttonsView.subviews) {
        [button removeFromSuperview];
    }
    if(self.mf.canAddItem) {
        self.addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        self.customButtonsArray = @[self.addButton];
        [self.addButton addTarget:self action:@selector(addItem) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        self.customButtonsArray = @[];
    }
    [self.buttonsView removeConstraints:[self.buttonsView constraints]];
}



#pragma mark - TopBar and title

-(void) setTitle:(NSString *)title {
    [self.titleLabel setText:title];
}

-(NSInteger) topBarViewHeight {
    int customButtonsSize = [self.dataDelegate sizeForCustomButtons].height;
    return customButtonsSize;
}

-(BOOL)showTitle {
    return YES;
}

-(BOOL) showButtons {
    return YES;
}

-(MFFixedListAlignment)buttonsAlignment {
    return MFFixedListAlignmentRight;
}

-(void)didLoadFieldDescriptor:(MFFieldDescriptor *)fieldDescriptor {
    [super didLoadFieldDescriptor:fieldDescriptor];
    NSDictionary *componentParameters = ((MFFieldDescriptor *)self.selfDescriptor).parameters;
    Class dataDelegateClass = NSClassFromString([componentParameters objectForKey:FIXED_LIST_PARAMETER_DATA_DELEGATE_NAME]);
    self.dataDelegate = [[dataDelegateClass alloc] initWithFixedList:self];
    self.mf.canAddItem =[[componentParameters objectForKey:FIXED_LIST_PARAMETER_CAN_ADD_ITEM] boolValue];
    self.mf.canEditItem =[[componentParameters objectForKey:FIXED_LIST_PARAMETER_CAN_EDIT_ITEM] boolValue];
    self.mf.canDeleteItem =[[componentParameters objectForKey:FIXED_LIST_PARAMETER_CAN_DELETE_ITEM] boolValue];
    self.mf.rowHeight = [[componentParameters objectForKey:FIXED_LIST_PARAMETER_ROW_HEIGHT] intValue];
    self.mf.editMode = [[componentParameters objectForKey:FIXED_LIST_PARAMETER_EDIT_MODE] intValue];
    self.mf.formDescriptorName = [componentParameters objectForKey:FIXED_LIST_PARAMETER_FORM_DESCRIPTOR_NAME];
    
    [self.dataDelegate setContent];
}

-(void)setDataDelegate:(MFFixedListDataDelegate *)dataDelegate {
    _dataDelegate = dataDelegate;
    self.tableView.dataSource = _dataDelegate;
    self.tableView.delegate =  _dataDelegate;
}

-(BOOL)isPhotoFixedList {
    return [[((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:FIXED_LIST_PARAMETER_IS_PHOTO] boolValue];
}

#pragma mark  - LiveRendering methods

-(void)buildDesignableComponentView {
    //TODO: Implémenter
}

-(void)renderComponentFromInspectableAttributes {
    //TODO: Implémenter
}

@end
