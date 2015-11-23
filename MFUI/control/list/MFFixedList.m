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

#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreError.h>
#import <MFCore/MFCoreBean.h>

#import "MFFixedList.h"
#import "MFUIBaseListViewModel.h"
#import "MFFixedListContentFieldValidator.h"


@interface MFFixedList()

/**
 * @brief An array containinig the custom buttons created by in the user project
 */
@property (nonatomic, strong) NSMutableArray *customButtonsArray;

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
NSString *const FIXED_LIST_PARAMETER_CAN_EDIT_ITEM = @"canEditItem";
NSString *const FIXED_LIST_PARAMETER_CAN_ADD_ITEM = @"canAddItem";
NSString *const FIXED_LIST_PARAMETER_CAN_DELETE_ITEM = @"canDeleteItem";
NSString *const FIXED_LIST_PARAMETER_EDIT_MODE = @"editMode";
NSString *const FIXED_LIST_PARAMETER_IS_PHOTO = @"isPhotoFixedList";



@implementation MFFixedList

#pragma mark - Synthesizing

@synthesize localizedFieldDisplayName = _localizedFieldDisplayName;
@synthesize componentInCellAtIndexPath =_componentInCellAtIndexPath;
@synthesize mandatory = _mandatory;

#pragma mark - Initializing

-(void) initialize {
    [super initialize];
    
    self.mf = [MFFixedListExtension new];
    //self.hasBeenReload = NO;
    self.dismissWaitingView = NO;
    if(!self.tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.titleLabel = [[UILabel alloc] init];
    }
    
    self.customButtonsArray = [NSMutableArray array];
    
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


-(void) changeDynamicHeight:(int)newHeight {
    if(!self.fixedListHeightConstraint) {
        for(NSLayoutConstraint *constraint in self.constraints) {
            if([constraint firstAttribute] == NSLayoutAttributeHeight && [[constraint firstItem] isEqual:self] && ![constraint secondItem]) {
                self.fixedListHeightConstraint = constraint;
            }
        }
    }
    
    [self.fixedListHeightConstraint setConstant:newHeight];
    [self setNeedsLayout];
}
#pragma mark - Méthodes dérivées de MFUIComponentProtocol

+(NSString *)getDataType {
    return @"MFUIBaseListViewModel";
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
}

/**
 * @brief Returns the value of the field
 * @return the value of the field
 */
-(MFUIBaseListViewModel *) getData {
    return self.data;
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
    return [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_KEYNOTFOUND];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    [self.tableView setValue:value forKey:key];
}

#pragma mark - Custom methods

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
-(void) addItem {
    if([self.mf.dataDelegate respondsToSelector:NSSelectorFromString(@"addItemOnFixedList")]) {
        [self.mf.dataDelegate performSelector:NSSelectorFromString(@"addItemOnFixedList")];
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





#pragma mark - TopBar and title

-(void) setTitle:(NSString *)title {
    [self.titleLabel setText:title];
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

-(void) toogleEditMode {
    self.mf.canDeleteItem = !self.mf.canDeleteItem;
    NSString *imagePath = nil;
    if(self.mf.canDeleteItem) {
        imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ios_ic_edit_active@2x" ofType:@"png"];
    }
    else {
        imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ios_ic_edit_unactive@2x" ofType:@"png"];
    }
    [self.editButton setImage:[UIImage imageWithContentsOfFile:imagePath] forState:UIControlStateNormal];
    imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ios_ic_edit_pressed@2x" ofType:@"png"];
    [self.editButton setImage:[UIImage imageWithContentsOfFile:imagePath] forState:UIControlStateHighlighted];

    [self.tableView reloadData];
}

-(BOOL)isPhotoFixedList {
    return self.mf.isPhotoFixedList;
}

#pragma mark - Validation


-(CGRect)getErrorButtonFrameForInvalid {
    CGFloat errorButtonSize = MIN(MIN(self.topBarView.bounds.size.width, self.topBarView.bounds.size.height), ERROR_BUTTON_SIZE);
    
    return CGRectMake(0,
                      (self.topBarView.bounds.size.height - errorButtonSize)/2.0f,
                      errorButtonSize,
                      errorButtonSize);
}

-(void)setControlAttributes:(NSDictionary *)controlAttributes {
    [super setControlAttributes:controlAttributes];
    NSString *dataDelegateName = controlAttributes[@"dataDelegateName"];
    if(dataDelegateName && !self.mf.dataDelegate) {
        self.mf.dataDelegate = [[NSClassFromString(dataDelegateName) alloc] initWithFixedList:self];
        self.tableView.dataSource = self.mf.dataDelegate;
        self.tableView.delegate = self.mf.dataDelegate;
    }
    
    NSNumber *canEditItem = controlAttributes[FIXED_LIST_PARAMETER_CAN_EDIT_ITEM];
    if(canEditItem) {self.mf.canEditItem = [canEditItem boolValue];}
    
    NSNumber *canAddItem = controlAttributes[FIXED_LIST_PARAMETER_CAN_ADD_ITEM];
    if(canAddItem) {self.mf.canAddItem = [canAddItem boolValue];}
    
    NSNumber *canDeleteItem = controlAttributes[FIXED_LIST_PARAMETER_CAN_DELETE_ITEM];
    if(canDeleteItem) {self.mf.canDeleteItem = [canDeleteItem boolValue];}
    
    NSNumber *editMode = controlAttributes[FIXED_LIST_PARAMETER_EDIT_MODE];
    if(editMode) {
        self.mf.editMode = (MFFixedListEditMode)[editMode integerValue];
    }
    if(self.mf.editMode == MFFixedListEditModePopup) {
        self.allowsSelectionDuringEditing = YES;
    }

    NSNumber *isPhotoFixedList = controlAttributes[FIXED_LIST_PARAMETER_IS_PHOTO];
    if(isPhotoFixedList) {self.mf.isPhotoFixedList = [isPhotoFixedList boolValue];}
    
    [self.tableView reloadData];
}

-(NSArray *)controlValidators {
    return @[[MFFixedListContentFieldValidator sharedInstance]];
}


-(void)prepareForInterfaceBuilder {
    self.backgroundColor = [UIColor colorWithRed:0.45 green:0.87 blue:0.23 alpha:0.5];
    UILabel *innerDescriptionLabel = [[UILabel alloc] initWithFrame:self.bounds];
    innerDescriptionLabel.text = [[self class] description];
    innerDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    innerDescriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    [self addSubview:innerDescriptionLabel];
}

@end
