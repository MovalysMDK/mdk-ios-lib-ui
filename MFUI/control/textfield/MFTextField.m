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
//  MFTextField.m
//  MFUI
//
//

#import <MFCore/MFCoreFoundationExt.h>
#import <MFCore/MFCoreConfig.h>
#import <MFCore/MFApplication.h>

#import "MFUILog.h"
#import "MFUIUtils.h"

#import "MFTextField.h"
#import "MFExtensionKeyboardingUIControl.h"
#import "MFUIBaseViewModel.h"
#import "MFBaseBindingForm.h"
#import "MFCellAbstract.h"

const NSString * MAX_LENGTH_PARAMETER_KEY = @"maxLength";


@interface MFTextField()

@property (nonatomic, strong) NSDate *date;

@property (nonatomic) BOOL hasACustomColor;

@property (nonatomic) CGFloat keyboardHeight;

@property (nonatomic) BOOL keyboardVisible;

@property (nonatomic, weak) UITableView *scrollingTableView;

@property (nonatomic) CGSize originalContentSize;

@property (nonatomic) CGRect originalFrame;

@property (nonatomic) CGPoint contentOffset;

@property (nonatomic, strong) id<UITextFieldDelegate> textFieldDelegate;

@end



@implementation MFTextField
@synthesize currentOrientation = _currentOrientation;

-(void)initialize {
    
    [super initialize];
    
#if !TARGET_INTERFACE_BUILDER
    
    self.applicationContext = [MFApplication getInstance];
    
    self.isValid = YES;
    
    if(self.sender && [self.sender conformsToProtocol:@protocol(UITextFieldDelegate)]) {
        self.textFieldDelegate = (id<UITextFieldDelegate>)self.sender;
    }
    else {
        self.sender = self;
    }
    
    
    self.textField.delegate = self.textFieldDelegate;
    self.hasACustomColor = NO;
    self.hasFocus = NO;
    
    
    [self registerOrientationChange];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (keyboardDidHide:)
                                                 name: UIKeyboardDidHideNotification
                                               object:nil];
    
    
    [self setAllTags];
    
    self.mf = [self.applicationContext getBeanWithKey:BEAN_KEY_EXTENSION_KEYBOARDING_UI_CONTROL];
    
    // We listen all text updates
    [self.textField
     addTarget:self
     action:@selector(updateValue)
     forControlEvents:UIControlEventEditingChanged];
#else
#endif
}




-(void) updateValue {
    [self.sender performSelectorOnMainThread: @selector(updateValue:) withObject:self.textField.text waitUntilDone:YES];
}

-(void)modifyComponentAfterHideErrorButtons {
    [super modifyComponentAfterHideErrorButtons];
    self.textField.frame = self.bounds;
}

-(void)modifyComponentAfterShowErrorButtons {
    
    [super modifyComponentAfterShowErrorButtons];
    CGFloat errorButtonSize = ERROR_BUTTON_SIZE;
    self.textField.frame = CGRectMake(errorButtonSize,
                                      0,
                                      self.bounds.size.width-errorButtonSize,
                                      self.bounds.size.height);
}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.textField.tag == 0) {
        [self.textField setTag:TAG_MFTEXTFIELD_TEXTFIELD];
    }
}


#pragma mark - CSS customization

-(NSArray *)customizableComponents {
    return @[
             self.textField
             ];
}

-(NSArray *)suffixForCustomizableComponents {
    return @[
             @"TextField"
             ];
}



#pragma mark - Fast Forwarding
-(id)forwardingTargetForSelector:(SEL)sel {
    return self.textField;
}

#pragma mark - KVC magic forwarding
//-(id)valueForUndefinedKey:(NSString *)key {
//    if(![key isEqualToString:@"mf."])
//    {
//        return [self.textField valueForKey:key];
//    }
//    else {
//        return [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_KEYNOTFOUND];
//    }
//}

//- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
//    [self.textField setValue:value forKey:key];
//}

#pragma mark - Delegate
-(void)setDelegate:(id<UITextFieldDelegate>)delegate {
    self.textField.delegate = delegate;
}

-(id<UITextFieldDelegate>)delegate {
    return self.textField.delegate;
}

#pragma mark - Validation API

-(NSInteger) validateWithParameters:(NSDictionary *)parameters{
    
    [super validateWithParameters:parameters];
    NSInteger length = [[self getValue] length];
    NSError *error = nil;
    // Control's errros init or reinit
    NSInteger nbOfErrors = 0;
    
    // We search the component's errors
    if(self.mf.minLength != nil && [self.mf.minLength integerValue] > length)
    {
        error = [[MFTooShortStringUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        [self addErrors:@[error]];
        [self.context addErrors:@[error]];
        nbOfErrors++;
    }
    if(self.mf.maxLength != nil && [self.mf.maxLength integerValue] != 0 && [self.mf.maxLength integerValue] < length)
    {
        error = [[MFTooLongStringUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        [self addErrors:@[error]];
        [self.context addErrors:@[error]];
        nbOfErrors++;
    }
    if(self.mf.mandatory != nil && [self.mf.mandatory integerValue] == 1 && [self getValue].length == 0){
        error = [[MFMandatoryFieldUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        [self addErrors:@[error]];
        [self.context addErrors:@[error]];
        nbOfErrors++;
    }
    
    return nbOfErrors;
}

-(void) setValue:(id) value{
    if([value isKindOfClass:[NSString class]]) {
        self.textField.text = value;
    }
    else if([value isKindOfClass:[NSAttributedString class]]){
        self.textField.attributedText = value;
    }
}

-(NSString *) getValue{
    return self.textField.text;
}

-(void)setData:(id)data {
    if(data && ![data isKindOfClass:[MFKeyNotFound class]]) {
        NSString *stringData = (NSString *)data;
        [self setValue:stringData];
    }
    else if(!data) {
        [self setValue:@""];
    }
}

+ (NSString *) getDataType {
    return @"NSString";
}

-(id)getData {
    return [self getValue];
}

-(BOOL) isActive{
    return self.textField.enabled;
}

-(void) setIsActive:(BOOL)isActive{
    self.textField.enabled = isActive;
}



#pragma mark - Specific TextField method implementation

-(void) setKeyboardType:(UIKeyboardType) type
{
    [self.textField setKeyboardType:type];
}

#pragma mark - UITextField Delegate
/**
 * @brief hide the keyboard when the done key is up
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
/**
 * @brief define the field to move to in the table when the keyboard hide a part of table
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    MFUILogVerbose(@"componentInCellAtIndexPath row section %ld %ld", (long)self.componentInCellAtIndexPath.row ,  (long)self.componentInCellAtIndexPath.section );
    [self setHasFocus:YES];
    [self scrollIfNeeded];
}

/**
 * @brief cancel the move of table
 */
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self setHasFocus:NO];
}

#pragma mark - Descriptor


-(void) setSelfDescriptor:(NSObject<MFDescriptorCommonProtocol> *)selfDescriptor
{
    
    [super setSelfDescriptor:selfDescriptor];

    // LoadConfiguration
    [self loadConfiguration:selfDescriptor.configurationName];
}


-(MFConfigurationKeyboardingUIComponent *) loadConfiguration:(NSString *) configurationName
{
    MFConfigurationKeyboardingUIComponent *config = (MFConfigurationKeyboardingUIComponent*)[super loadConfiguration:configurationName];
    if(config) {
        self.mf.maxLength = [MFUIBaseComponent getNumberConfigurationWithValue:config.maxLength andDefaultValue:self.mf.maxLength];
        self.mf.minLength = [MFUIBaseComponent getNumberConfigurationWithValue:config.minLength andDefaultValue:self.mf.minLength];
        self.mf.mandatory = [MFUIBaseComponent getBoolConfigurationWithValue:config.mandatory andDefaultValue:self.mf.mandatory];
    }
    return config;
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"MFTextField<value:%@, active: %c, mf.mandatory: %@, mf.maxLength: %@, mf.minLength: %@>", [self getValue], self.isActive ?  : NO, self.mf.mandatory ? @"YES" : @"NO", self.mf.maxLength, self.mf.minLength];
}

-(void)setMandatory:(NSNumber *)mandatory {
    self.mf.mandatory = mandatory ;
}

-(void)dealloc {
    [self.textField
     removeTarget:self
     action:@selector(updateValue)
     forControlEvents:UIControlEventEditingChanged];
    
    //QLA : Le delegate d'orientation ne suffit pas (sans savoir pourquoi) pour faire le removeObserver.
    [self.orientationChangedDelegate unregisterOrientationChanges];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - Observers
-(void)keyboardWillShow:(NSNotification *)notification {
    if(self.scrollingTableView) {
        self.contentOffset = self.scrollingTableView.contentOffset;
    }
    
    if(self.hasFocus) {
        self.keyboardHeight = MIN([[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height,
                                  [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.width);
        
        [self scrollIfNeeded];
    }
}



-(void)keyboardDidHide:(NSNotification *)notification {
    
    // Reset the frame scroll view to its original value
    self.scrollingTableView.frame = self.originalFrame;
    // Reset the scrollview to previous location
    //    self.scrollingTableView.contentOffset = self.contentOffset;
    [self.scrollingTableView setContentSize:self.originalContentSize];
    // Keyboard is no longer visible
    self.keyboardVisible = NO;
}



#pragma mark - Scrolling

/**
 * @brief Scroll if needed, the form controller of this component to show the component above the keyboard
 */
-(void) scrollIfNeeded {
    
    int scrollMargin = 15;
    UIView *currentView = self;
    //Getting the total offset for this component
    if(self.form && self.keyboardHeight != 0) {
        CGFloat offset = 0;
        
        
        [((MFBaseBindingForm *)self.form) setActiveField:self];
        while( currentView && ![@(currentView.tag) isEqualToNumber:@(FORM_BASE_TABLEVIEW_TAG)]) {
            
            offset += currentView.frame.origin.y;
            currentView = currentView.superview;
        }
        if(!self.scrollingTableView) {
            
            //Get the tableView and apply scroll
            self.scrollingTableView= (UITableView *)[currentView viewWithTag:FORM_BASE_TABLEVIEW_TAG];
            self.originalFrame = self.scrollingTableView.frame;
            self.originalContentSize = self.scrollingTableView.contentSize;
            
        }
        offset -= self.scrollingTableView.frame.size.height;
        offset += self.frame.size.height;
        offset += self.keyboardHeight;
        offset += scrollMargin;
        CGSize newContentSize = self.originalContentSize;
        newContentSize.height += self.keyboardHeight;
        [self.scrollingTableView setContentSize:newContentSize];
        [self.scrollingTableView scrollRectToVisible:CGRectMake(0, offset, currentView.frame.size.width, currentView.frame.size.height) animated:YES];
    }
    
}

-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    self.textField.enabled = ([editable isEqualToNumber:@1]) ? YES : NO;
    self.textField.placeholder = ([editable isEqualToNumber:@0]) ? nil : self.textField.placeholder;
    
}

-(void)didFinishLoadDescriptor {
    
    [super didFinishLoadDescriptor];
    
    //Biding des propriétés
    self.mf.maxLength = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:MAX_LENGTH_PARAMETER_KEY];
}

#pragma mark - Orientation Changes Delegate Methods

-(void)registerOrientationChange {
    self.currentOrientation = [[UIDevice currentDevice] orientation];
    self.orientationChangedDelegate = [[MFOrientationChangedDelegate alloc] initWithListener:self];
    [self.orientationChangedDelegate registerOrientationChanges];
}

-(void)orientationDidChanged:(NSNotification *)notification {
    if(self.orientationChangedDelegate && [self.orientationChangedDelegate checkIfOrientationChangeIsAScreenNormalRotation] &&
       self.scrollingTableView) {
        self.originalContentSize = self.scrollingTableView.contentSize;
        self.originalFrame = self.scrollingTableView.frame;
    }
    self.currentOrientation = [[UIDevice currentDevice] orientation];
}

-(void)unregisterOrientationChange{
    [self.orientationChangedDelegate unregisterOrientationChanges];
}

//-(void)setComponentAlignment:(NSNumber *)alignValue {
//    [self.textField setTextAlignment:[alignValue intValue]];
//}

#pragma mark - LiveRendering Methods

-(void)buildDesignableComponentView {
    self.textField = [[UITextField alloc] initWithFrame:self.bounds];
    self.textField.font = [UIFont systemFontOfSize:17];
    self.textField.placeholder = MFLocalizedStringFromKey(@"enterText");
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.keyboardType = UIKeyboardTypeDefault;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.textField];
    [self addInnerTextFieldConstraints];

}

-(void)renderComponentFromInspectableAttributes {
    self.textField.borderStyle = self.IB_borderStyle;
    self.textField.backgroundColor = self.IB_primaryBackgroundColor;
    self.textField.layer.borderColor = self.IB_borderColor.CGColor;
    self.textField.layer.borderWidth = self.IB_borderWidth;
    self.textField.font = [UIFont fontWithName:self.textField.font.familyName size:self.IB_textSize];
    self.textField.textColor = self.IB_textColor;
    self.textField.placeholder = self.IB_placeholder;
    self.backgroundColor = [UIColor whiteColor];
}


-(void)willLayoutSubviewsNoDesignable {
    
    CGFloat errorButtonSize = ERROR_BUTTON_SIZE;
    if(self.isValid)
        errorButtonSize = 0;
    self.textField.frame = CGRectMake(self.bounds.origin.x + errorButtonSize,
                                      self.bounds.origin.y,
                                      self.bounds.size.width - errorButtonSize,
                                      self.bounds.size.height);
    // we love the delegate after
    self.textField.delegate = self.textFieldDelegate;
}


-(void)initializeInspectableAttributes {
    [super initializeInspectableAttributes];
    self.textField.backgroundColor = [UIColor clearColor];
    self.IB_primaryBackgroundColor = [UIColor clearColor];
    self.IB_borderStyle = 0;
    self.IB_borderColor = [UIColor clearColor];
    self.IB_borderWidth = 1;
    self.IB_placeholder = MFLocalizedStringFromKey(@"Enter text...");
    self.IB_textColor = [UIColor blackColor];
    self.IB_textSize = 16;
    self.IB_unbindedText = nil;
    self.IB_textAlignment = 0;
}


-(void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    self.textField.frame = self.frame;
    self.backgroundColor = [UIColor clearColor];
    self.textField.text = self.IB_unbindedText;
}

-(void)willLayoutSubviewsDesignable {
    self.textField.textAlignment = self.IB_textAlignment;
}

-(void) addInnerTextFieldConstraints {
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    [self addConstraints:@[leftConstraint, rightConstraint, topConstraint, bottomConstraint]];
    [self setNeedsDisplay];
    
    NSString *stringRect = NSStringFromCGRect(self.textField.frame);
    NSString *fdg = nil;
    
}



@end
