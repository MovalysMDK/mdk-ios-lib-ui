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
//  MFDatePicker.m
//  MFUI
//
//

#import <MFCore/MFCoreI18n.h>

#import "MFDatePicker.h"
#import "MFDateConverter.h"
#import "MFCellAbstract.h"
#import "MFPickerList.h"
#import "MFColorValueProcessing.h"
#import "MFUIApplication.h"

#pragma mark - Define some constants
#define PICKER_TOP_BAR_HEIGHT  40.f
#define PICKER_SEARCH_BAR_HEIGHT 40.f

#define PICKER_TOP_BAR_ITEMS_MARGIN  7.f
#define PICKER_TOP_BAR_ITEMS_HEIGHT  30.f

#define PICKER_TOP_BAR_CANCEL_WIDTH  75.f
#define PICKER_TOP_BAR_CONFIRM_WIDTH 50.f

#define PICKER_LIST_HEIGHT 164.f


@interface MFDatePicker()

/**
 * @brief Indicates if the PickerList is currently displayed
 */
@property (nonatomic) BOOL isModalPickerViewDisplayed;

/**
 * @brief The view of the main form controller of this component
 */
@property (nonatomic, strong) UIView *mainFormControllerView;

/**
 * @brief The popover window to display the PickerList on iPad
 */
@property (nonatomic, strong) UIPopoverController *popoverController;

@end

@implementation MFDatePicker
@synthesize localizedFieldDisplayName = _localizedFieldDisplayName;
@synthesize context = _context;
@synthesize transitionDelegate = _transitionDelegate;
@synthesize groupDescriptor = _groupDescriptor;
@synthesize applicationContext = _applicationContext;
@synthesize isValid = _isValid;
@synthesize form = _form;
@synthesize componentInCellAtIndexPath =_componentInCellAtIndexPath;
@synthesize data =_data;
@synthesize currentOrientation = _currentOrientation;
@synthesize defaultConstraints = _defaultConstraints;

#pragma mark - Initializing
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)initialize {
    

    
#if !TARGET_INTERFACE_BUILDER
    
    
    
    
    self.isShowing = NO;
    self.isModalPickerViewDisplayed = NO;
    
    [self.dateButton addTarget:self action:@selector(displayPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.dateButton setTextAlignment:NSTextAlignmentCenter];
    //Add observers
    //Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hidePickerModalView)
                                                 name:PICKER_NOTIFICATION_FORCE_HIDE
                                               object:nil];
    [self registerOrientationChange];
#else
#endif
    //The super should be done last, because he calls applyDefaultConstraints and needs that all "constrained" ui elements exist.
    [super initialize];
    
}

-(void)applyDefaultConstraints {
    if(self.dateButton) {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.dateButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *topDateLabelConstraint = [NSLayoutConstraint constraintWithItem:self.dateButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint *bottomDateLabelConstraint = [NSLayoutConstraint constraintWithItem:self.dateButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    NSLayoutConstraint *leftDateLabelConstraint = [NSLayoutConstraint constraintWithItem:self.dateButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    
    NSLayoutConstraint *rightDateLabelConstraint = [NSLayoutConstraint constraintWithItem:self.dateButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    //    NSLayoutConstraint *centerXDateLabelConstraint = [NSLayoutConstraint constraintWithItem:self.dateButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:0.75 constant:0];
    //
    //    NSLayoutConstraint *centerYDateLabelConstraint = [NSLayoutConstraint constraintWithItem:self.dateButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:0.75 constant:0];
    
    [self addConstraints:@[
                           topDateLabelConstraint, bottomDateLabelConstraint, leftDateLabelConstraint, rightDateLabelConstraint
                           ]];
    }
}


#pragma mark - Class lifecycle

-(void)layoutSubviews {
    [super layoutSubviews];
    if(!self.currentDate) {
        self.currentDate = [NSDate date];
    }
    [self setButtonDateTitle:self.currentDate];
}

/**
 * @brief Dealloc this class. remove observers
 */
- (void)dealloc
{
    //QLA : Le delegate d'orientation ne suffit pas (sans savoir pourquoi) pour faire le removeObserver.
    [self.orientationChangedDelegate unregisterOrientationChanges];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.dateButton.tag == 0) {
        [self.dateButton setTag:TAG_MFDATEPICKER_DATEBUTTON];
    }
    if (self.datePicker.tag == 0) {
        [self.datePicker setTag:TAG_MFDATEPICKER_DATEPICKER];
    }
    if (self.confirmButton.tag == 0) {
        [self.confirmButton setTag:TAG_MFDATEPICKER_CONFIRMBUTTON];
    }
    if (self.cancelButton.tag == 0) {
        [self.cancelButton setTag:TAG_MFDATEPICKER_CANCELBUTTON];
    }
}


#pragma mark - Specific methods for this component

/**
 * @brief This method builds and shows the pickerView in an ActionSheet (iPhone) or in a PopoverViewController (iPad)
 */
-(void) displayPickerView:(id)sender {
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    if(self.isModalPickerViewDisplayed) {
        return;
    }
    
    //Get FormViewController parent
    self.mainFormControllerView = self;
    while(self.mainFormControllerView.tag != NSIntegerMax) {
        self.mainFormControllerView = self.mainFormControllerView.superview;
    }
    
    int pickerListWidth = MIN([MFVersionManager isCurrentDeviceOfTypePhone] ? self.mainFormControllerView.frame.size.width : self.mainFormControllerView.frame.size.width/2, 400);
    int pickerListOriginX = 0;
    if([MFVersionManager isCurrentDeviceOfTypePhone]) {
        pickerListOriginX = self.mainFormControllerView.frame.size.width/2 - pickerListWidth/2;
    }
    
    //Build the actionSheet
    self.modalPickerView = [[UIScrollView alloc] init];
    [self.modalPickerView setTag:PICKER_VIEW_TAG];
    
    //Build and initialize the pickerView
    self.datePicker = [[UIDatePicker alloc] init];
    
    [self setUIDatePickerMode];
    
    if(!self.data) {
        self.data = [NSDate date];
    }
    self.datePicker.date = self.currentDate;
    
    //Build and initialize the topBar of the pickerView
    self.confirmButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:MFLocalizedStringFromKey(PICKER_NOTIFICATION_BUTTON_SAVE_TITLE)]];
    self.confirmButton.frame = CGRectMake(pickerListOriginX +pickerListWidth - PICKER_TOP_BAR_CONFIRM_WIDTH - PICKER_TOP_BAR_ITEMS_MARGIN,
                                          PICKER_TOP_BAR_ITEMS_MARGIN,
                                          PICKER_TOP_BAR_CONFIRM_WIDTH,
                                          PICKER_TOP_BAR_ITEMS_HEIGHT);
    
    self.confirmButton.segmentedControlStyle = UISegmentedControlStyleBar;
    
    UIColor *okButtonColor = [MFColorValueProcessing processColorFromString:[[((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:PICKER_PARAMETER_OK_BUTTON_COLOR_KEY] stringByAppendingString:@"Color"]];
    if(!okButtonColor) {
        okButtonColor = [UIColor blackColor];
    }
    self.confirmButton.tintColor = okButtonColor;
    [self.confirmButton addTarget:self action:@selector(dismissPickerViewAndSave) forControlEvents:UIControlEventValueChanged];
    
    //Build and initialize the topBar of the pickerView
    self.cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:MFLocalizedStringFromKey(PICKER_NOTIFICATION_BUTTON_CANCEL_TITLE)]];
    self.cancelButton.frame = CGRectMake(pickerListOriginX + PICKER_TOP_BAR_ITEMS_MARGIN,
                                         PICKER_TOP_BAR_ITEMS_MARGIN,
                                         PICKER_TOP_BAR_CANCEL_WIDTH,
                                         PICKER_TOP_BAR_ITEMS_HEIGHT);
    
    self.cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
    UIColor *cancelButtonColor = [MFColorValueProcessing processColorFromString:[[((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:PICKER_PARAMETER_CANCEL_BUTTON_COLOR_KEY] stringByAppendingString:@"Color"]];
    if(!cancelButtonColor) {
        cancelButtonColor = [UIColor blueColor];
    }
    self.cancelButton.tintColor = cancelButtonColor;
    
    [self.cancelButton addTarget:self action:@selector(dismissPickerViewAndCancel) forControlEvents:UIControlEventValueChanged];
    
    //Show the actionSheet
    [self.modalPickerView addSubview:self.confirmButton];
    [self.modalPickerView  addSubview:self.cancelButton];
    [self.modalPickerView  addSubview:self.datePicker];
    
    //Specific code for iPhone/iPad : to display a PickerView, you need to display it in a popover
    if([MFVersionManager isCurrentDeviceOfTypePhone]) //iPhone
    {
        
        float whiteDegree = 1.0;
        if(SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            whiteDegree = 0.0;
        }
        
        [self.modalPickerView setBackgroundColor:[UIColor colorWithWhite:whiteDegree alpha:0.9]];
        
        //Set pickerFrame
        int pickerYHeight = (PICKER_TOP_BAR_HEIGHT + PICKER_LIST_HEIGHT);
        [self.datePicker setFrame:CGRectMake(pickerListOriginX, PICKER_TOP_BAR_HEIGHT, pickerListWidth, PICKER_LIST_HEIGHT)];
        
        CGRect modalPickerViewFrame = CGRectMake(self.mainFormControllerView.frame.origin.x,
                                                 self.mainFormControllerView.frame.size.height - pickerYHeight,
                                                 self.mainFormControllerView.frame.size.width,
                                                 pickerYHeight);
        
        CGRect initialPickerModalPosition = modalPickerViewFrame;
        initialPickerModalPosition.origin.y  = self.mainFormControllerView.frame.size.height;
        [self.modalPickerView setFrame:initialPickerModalPosition];
        [self showPickerModalViewInFrame:modalPickerViewFrame inView:self.mainFormControllerView];
        
        
    }
    else { //iPad
        [self.datePicker setFrame:CGRectMake(0,
                                             PICKER_TOP_BAR_HEIGHT,
                                             pickerListWidth,
                                             PICKER_LIST_HEIGHT)];
        
        UIView *view = [[UIView alloc] init];
        [view addSubview:self.datePicker];
        [view addSubview:self.cancelButton];
        [view addSubview:self.confirmButton];
        
        
        UIViewController *vc = [[UIViewController alloc] init];
        [vc setView:view];
        int contentViewHeight = self.datePicker.frame.size.height + PICKER_TOP_BAR_HEIGHT;
        [vc setContentSizeForViewInPopover:CGSizeMake(self.datePicker.frame.size.width,contentViewHeight)];
        
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
        MFCellAbstract *parentCell = (MFCellAbstract *)self.cellContainer;
        MFFormBaseViewController *parentForm = (MFFormBaseViewController *)parentCell.formController;
        
        [self.popoverController presentPopoverFromRect:self.mainFormControllerView.frame inView:parentForm.view permittedArrowDirections:0 animated:YES];
    }
    
    //init the PickerView
    self.isShowing = YES;
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self setButtonDateTitle:self.datePicker.date];
        
}




#pragma mark - Show/Dismiss/Orientation events

/**
 * @brief This method shows the modal PickerView with an animation
 */
-(void) showPickerModalViewInFrame:(CGRect)frame inView:(UIView *)view{
    self.isModalPickerViewDisplayed = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_NOTIFICATION_SHOW object:nil userInfo:nil];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    [view addSubview:self.modalPickerView];
    [UIView animateWithDuration:0.25 animations:^{
        [self.modalPickerView setFrame:frame];
        
    } completion:^(BOOL finished) {
        [self.modalPickerView setHidden:NO];
    }];
}

/**
 * @brief This method hides the modal PickerView with an animation
 */
-(void) hidePickerModalView {
    self.isModalPickerViewDisplayed = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_NOTIFICATION_HIDE object:nil userInfo:nil];
    
    CGRect currentFrame = self.modalPickerView.frame;
    currentFrame.origin.y += currentFrame.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        [self.modalPickerView setFrame:currentFrame];
        
    } completion:^(BOOL finished) {
        [self.modalPickerView setHidden:YES];
        [self.modalPickerView removeFromSuperview];
    }];
}

/**
 * @brief Dismiss this pickerView
 */
-(void) dismissPickerViewAndSave {
    self.data = self.datePicker.date;
    [self updateValue];
    
    if([MFVersionManager isCurrentDeviceOfTypePhone])
    {
        [self hidePickerModalView];
    }
    else {
        if(self.popoverController && [self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:YES];
        }
    }
    [self setButtonDateTitle:self.currentDate];
    
}

/**
 * @brief Dismiss this pickerView
 */
-(void) dismissPickerViewAndCancel {
    self.datePicker.date = self.data;
    //Obligation d'appeller l'évènement soi-même pour la mise à jour du VM car la méthode "selectRow" ne le fait pas (cf. doc Apple).
    [self performSelector:@selector(dismissPickerViewAndSave) withObject:nil afterDelay:0.35];
}


#pragma mark - Date Changed Event

-(void) dateChanged:(id)sender {
    self.currentDate = self.datePicker.date;
    [self setButtonDateTitle:self.datePicker.date];
}

-(void) setButtonDateTitle:(NSDate *)date {
    NSDictionary *customParameters = ((MFFieldDescriptor *)self.selfDescriptor).parameters;
    if(customParameters && [customParameters objectForKey:@"dateFormat"]) {
        self.dateButton.text = [MFDateConverter toString:date withCustomFormat:[customParameters objectForKey:@"dateFormat"]];
    }
    else {
        self.dateButton.text = [MFDateConverter toString:date withMode:self.datePickerMode];
    }
}





#pragma mark -  MFOrientationChangedDelegate

-(void)orientationDidChanged:(NSNotification *)notification {
    if(self.orientationChangedDelegate && [self.orientationChangedDelegate checkIfOrientationChangeIsAScreenNormalRotation] &&
       self.isModalPickerViewDisplayed) {
        self.currentDate = self.datePicker.date;
        [self hidePickerModalView];
        [self performSelector:@selector(displayPickerView:) withObject:self afterDelay:0.75];
    }
    self.currentOrientation = [[UIDevice currentDevice] orientation];
}

-(void)registerOrientationChange {
    self.currentOrientation = [[UIDevice currentDevice] orientation];
    self.orientationChangedDelegate = [[MFOrientationChangedDelegate alloc] initWithListener:self];
    [self.orientationChangedDelegate registerOrientationChanges];
}


#pragma mark - Picker mode binding from PLIST property

-(void) didFinishLoadDescriptor {
    
    [super didFinishLoadDescriptor];
    
    //Biding de la propriété qui spécifie le type de picker (date, datetime ou time)
    NSNumber *pickerMode = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:@"datePickerMode"];
    //Récupération du type de picker
    self.datePickerMode = [pickerMode intValue];
    
}

#pragma mark - Custom setters for class properties



-(void)setCurrentDate:(NSDate *)currentDate {
    _currentDate = currentDate;
    [self setButtonDateTitle:currentDate];
}

-(void) setUIDatePickerMode {
    switch(self.datePickerMode) {
        case MFDatePickerModeDate :
            self.datePicker.datePickerMode = UIDatePickerModeDate;
            break;
        case MFDatePickerModeTime :
            self.datePicker.datePickerMode = UIDatePickerModeTime;
            break;
        case MFDatePickerModeDateTime :
            self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
            break;
        default:
            self.datePicker.datePickerMode = UIDatePickerModeDate;
            break;
    }
}

-(void) setTextColor:(UIColor *)color {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dateButton setTextColor:color];
    });
}




#pragma mark - MFUIBasecomponent base methods

-(void)setData:(id)data {
    _data = data;
    self.currentDate = data;
}

-(id)getData {
    return self.data;
}

+(NSString *)getDataType {
    return @"NSDate";
}

-(void) updateValue {
    [self performSelectorOnMainThread: @selector(updateValue:) withObject:self.data waitUntilDone:YES];
}

-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    if([self.editable isEqualToNumber:@0]) {
        [self.dateButton removeTarget:self action:@selector(displayPickerView:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [self.dateButton addTarget:self action:@selector(displayPickerView:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.dateButton setEditable:editable];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    if(self.isModalPickerViewDisplayed) {
        [self dismissPickerViewAndCancel];
    }
}

#pragma mark - LiveRendering Methods







@end
