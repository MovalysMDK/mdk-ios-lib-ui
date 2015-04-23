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

#import "MFUITextField.h"
#import "MFTextFieldExtension.h"
#import "MFUIBaseViewModel.h"
#import "MFBaseBindingForm.h"
#import "MFCellAbstract.h"


@interface MFUITextField()

/**
 * @brief The extension for this component
 */
@property (nonatomic, strong) MFTextFieldExtension *extension;

/**
 * @brief The UITextFieldDelegate that should manage the changes of this inner textField.
 * @discussion If this component is embeded in another component we need to forward this
 * UITextField events on the parent component
 */
@property (nonatomic, strong) id<UITextFieldDelegate> textFieldDelegate;

/**
 * @brief This property is the current keyboard height. this property is update
 * after configurayion changes
 */
@property (nonatomic) CGFloat keyboardHeight;

/**
 * @brief The tableView if it exists that embed this component
 */
@property (nonatomic, weak) UITableView *scrollingTableView;

@property (nonatomic) CGSize originalContentSize;

@property (nonatomic) CGRect originalFrame;

@end



@implementation MFUITextField
@synthesize currentOrientation;

#pragma mark - Component Lifecycle

-(void)initialize {
    
    [super initialize];
#if !TARGET_INTERFACE_BUILDER
    
    //Initialize component extension
    self.extension = [MFTextFieldExtension new];
    
    //Initialize the target UITextfield delegate for this inner textfield
    if(self.sender && [self.sender conformsToProtocol:@protocol(UITextFieldDelegate)]) {
        self.textFieldDelegate = (id<UITextFieldDelegate>)self.sender;
    }
    else {
        self.sender = self;
    }
    //    self.textField.delegate = self.textFieldDelegate;
    
    //Set default state of this component
    self.isValid = YES;
    
    //Register orientation changes
    [self registerOrientationChange];
    
    //Add keyboard observers
    [self addKeyboardObservers];
    
    //Automatic tests
    
#else
#endif
}



- (void)didInitializeOutlets {
    [self.textField
     addTarget:self
     action:@selector(updateValue)
     forControlEvents:UIControlEventEditingChanged];
}

-(void)dealloc {
    [self.textField removeTarget:self action:@selector(updateValue) forControlEvents:UIControlEventEditingChanged];
    //QLA : Le delegate d'orientation ne suffit pas (sans savoir pourquoi) pour faire le removeObserver.
    [self.orientationChangedDelegate unregisterOrientationChanges];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void) updateValue {
    [self.sender performSelectorOnMainThread: @selector(updateValue:) withObject:[self displayComponentValue] waitUntilDone:YES];
}

-(void)didLoadFieldDescriptor:(MFFieldDescriptor *)fieldDescriptor  {
    self.extension.maxLength = [fieldDescriptor.parameters objectForKey:PARAMETER_TEXTFIELD_MAXLENGTH_KEY];
    self.extension.minLength = [fieldDescriptor.parameters objectForKey:PARAMETER_TEXTFIELD_MINLENGTH_KEY];
}



#pragma mark - Delegate
-(void)setDelegate:(id<UITextFieldDelegate>)delegate {
    self.textField.delegate = delegate;
}

-(id<UITextFieldDelegate>)delegate {
    return self.textField.delegate;
}

#pragma mark - Validation

-(NSInteger) validateWithParameters:(NSDictionary *)parameters{
    
    [super validateWithParameters:parameters];
    NSInteger length = [[self displayComponentValue] length];
    NSError *error = nil;
    // Control's errros init or reinit
    NSInteger nbOfErrors = 0;
    
    // We search the component's errors
    if(self.extension.minLength != nil && [self.extension.minLength integerValue] > length)
    {
        error = [[MFTooShortStringUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        [self addErrors:@[error]];
        nbOfErrors++;
    }
    if(self.extension.maxLength != nil && [self.extension.maxLength integerValue] != 0 && [self.extension.maxLength integerValue] < length)
    {
        error = [[MFTooLongStringUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        [self addErrors:@[error]];
        nbOfErrors++;
    }
    if(self.mandatory != nil && [self.mandatory integerValue] == 1 && ((NSString *)[self displayComponentValue]).length == 0){
        error = [[MFMandatoryFieldUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        [self addErrors:@[error]];
        nbOfErrors++;
    }
    
    return nbOfErrors;
}


#pragma mark - Managing data

-(void)setData:(id)data {
    id fixedData = data;
    if(data && ![data isKindOfClass:[MFKeyNotFound class]]) {
        NSString *stringData = (NSString *)data;
        fixedData = stringData;
    }
    else if(!data) {
        fixedData = @"";
    }
    [super setData:fixedData];
}

+ (NSString *) getDataType {
    return @"NSString";
}

-(id)getData {
    return [self displayComponentValue];
}

-(NSString *)displayComponentValue {
    return self.textField.text;
}

-(void)setDisplayComponentValue:(id)value {
    if([value isKindOfClass:[NSString class]]) {
        self.textField.text = value;
    }
    else if([value isKindOfClass:[NSAttributedString class]]){
        self.textField.attributedText = value;
    }  
}

#pragma mark - Specific TextField method implementation

-(void) setKeyboardType:(UIKeyboardType) type
{
    [self.textField setKeyboardType:type];
}

-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    self.textField.enabled = ([editable isEqualToNumber:@1]) ? YES : NO;
    self.textField.placeholder = ([editable isEqualToNumber:@0]) ? nil : self.textField.placeholder;
}

-(BOOL) isActive{
    return self.textField.enabled;
}

-(void) setIsActive:(BOOL)isActive{
    self.textField.enabled = isActive;
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
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    MFUILogVerbose(@"componentInCellAtIndexPath row section %ld %ld", (long)self.componentInCellAtIndexPath.row ,  (long)self.componentInCellAtIndexPath.section );
    [self scrollIfNeeded];
}

/**
 * @brief cancel the move of table
 */
- (void)textFieldDidEndEditing:(UITextField *)textField{
}


#pragma mark - Keyboard and scrolling management

-(void) addKeyboardObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (keyboardDidHide:)
                                                 name: UIKeyboardDidHideNotification
                                               object:nil];
}

-(void)keyboardWillShow:(NSNotification *)notification {
    
//    if(self.hasFocus) {
//        self.keyboardHeight = MIN([[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height,
//                                  [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.width);
//        
//        [self scrollIfNeeded];
//    }
}



-(void)keyboardDidHide:(NSNotification *)notification {
    
    // Reset the frame scroll view to its original value
    self.scrollingTableView.frame = self.originalFrame;
    // Reset the scrollview to previous location
    //    self.scrollingTableView.contentOffset = self.contentOffset;
    [self.scrollingTableView setContentSize:self.originalContentSize];
}


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





#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.textField.tag == 0) {
        [self.textField setTag:TAG_MFTEXTFIELD_TEXTFIELD];
    }
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

@end


#pragma mark -
#pragma mark MFUIExternalTextField
@implementation MFUIExternalTextField

@end


#pragma mark -
#pragma mark MFUIInternalTextField
@implementation MFUIInternalTextField

@end

