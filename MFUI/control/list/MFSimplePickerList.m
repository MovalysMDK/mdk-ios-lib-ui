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
//  MFSimplePickerList.m
//  MFUI
//
//

// MFCore imports
#import <MFCore/MFCoreI18n.h>

// Custom imports
#import "MFSimplePickerList.h"
#import "MFCellAbstract.h"
#import "MFPickerList.h"
#import "MFVersionManager.h"
#import "MFFormSearchViewController.h"

#pragma mark - Define some constants
#define PICKER_TOP_BAR_HEIGHT  40.f
#define PICKER_SEARCH_BAR_HEIGHT 40.f

#define PICKER_TOP_BAR_ITEMS_MARGIN  7.f
#define PICKER_TOP_BAR_ITEMS_HEIGHT  30.f

#define PICKER_TOP_BAR_CANCEL_WIDTH  75.f
#define PICKER_TOP_BAR_CONFIRM_WIDTH 50.f

#define PICKER_LIST_HEIGHT 164.f

NSString *const PICKER_PARAMETER_ENUM_CLASS_NAME_KEY = @"enumClassName";


@interface MFSimplePickerList()

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

@implementation MFSimplePickerList
@synthesize localizedFieldDisplayName = _localizedFieldDisplayName;


@synthesize isValid = _isValid;
@synthesize componentInCellAtIndexPath =_componentInCellAtIndexPath;
@synthesize data =_data;
@synthesize currentOrientation = _currentOrientation;
@synthesize controlAttributes = _controlAttributes;
@synthesize targetDescriptors = _targetDescriptors;

#pragma mark - Initializing

-(void)initialize {
    [super initialize];
    self.mf = [MFEnumExtension new];
    self.pickerButton = [[MFButton alloc] init];
    self.pickerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.pickerButton];
    
    self.isShowing = NO;
    self.isModalPickerViewDisplayed = NO;
    
    [self.pickerButton addTarget:self action:@selector(displayPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerButton setEnabled:YES];
    
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
}

#pragma mark - Class lifecycle

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect pickerButtonFrame = self.bounds;
    pickerButtonFrame.size.width /= 2;
    pickerButtonFrame.size.height /= 2;
    self.pickerButton.frame = pickerButtonFrame;
    self.pickerButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    MFUILogVerbose(@"layoutSubviews - self.data=%@ (avant)", self.data);
    if(!self.data) {
        // Initialise self.data avec la valeur par défaut de l'enum
        
        
        NSString *sEnumClassHelperName = [MFHelperType getClassHelperOfClassWithKey:self.mf.enumClassName]; // Nom de la classe Helper de l'Enum
        Class cEnumHelper = NSClassFromString(sEnumClassHelperName); // Classe Helper de l'Enum
        int idEnumValue = (int)[cEnumHelper performSelector:@selector(enumFromText:) withObject:@""]; // Enum de la valeur souhaitée l'Enum
        self.data = (id<MFEnumHelperProtocol>)[NSNumber numberWithInt:idEnumValue];
    }
    MFUILogVerbose(@"layoutSubviews - self.data=%@ (apres)", self.data);
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
    if (self.pickerButton.tag == 0) {
        [self.pickerButton setTag:TAG_MFSIMPLEPICKERLIST_PICKERBUTTON];
    }
    if (self.pickerView.tag == 0) {
        [self.pickerView setTag:TAG_MFSIMPLEPICKERLIST_PICKERVIEW];
    }
    if (self.confirmButton.tag == 0) {
        [self.confirmButton setTag:TAG_MFSIMPLEPICKERLIST_CONFIRMBUTTON];
    }
    if (self.cancelButton.tag == 0) {
        [self.cancelButton setTag:TAG_MFSIMPLEPICKERLIST_CANCELBUTTON];
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
    if([self.parentViewController isKindOfClass:[MFFormSearchViewController class]]) {
        self.mainFormControllerView = ((UIViewController *)self.parentViewController).view;
    }
    else {
        while(self.mainFormControllerView.tag != NSIntegerMax) {
            self.mainFormControllerView = self.mainFormControllerView.superview;
        }
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
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    //Build and initialize the topBar of the pickerView
    self.confirmButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:MFLocalizedStringFromKey(PICKER_NOTIFICATION_BUTTON_SAVE_TITLE)]];
    self.confirmButton.frame = CGRectMake(PICKER_TOP_BAR_ITEMS_MARGIN,
                                          PICKER_TOP_BAR_ITEMS_MARGIN,
                                          PICKER_TOP_BAR_CONFIRM_WIDTH,
                                          PICKER_TOP_BAR_ITEMS_HEIGHT);
    
    self.confirmButton.tintColor = [UIColor blackColor];
    [self.confirmButton addTarget:self action:@selector(dismissPickerViewAndSave) forControlEvents:UIControlEventValueChanged];
    
    //Build and initialize the topBar of the pickerView
    self.cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:MFLocalizedStringFromKey(PICKER_NOTIFICATION_BUTTON_CANCEL_TITLE)]];
    self.cancelButton.frame = CGRectMake(PICKER_TOP_BAR_ITEMS_MARGIN + PICKER_TOP_BAR_ITEMS_MARGIN + PICKER_TOP_BAR_CONFIRM_WIDTH,
                                         PICKER_TOP_BAR_ITEMS_MARGIN,
                                         PICKER_TOP_BAR_CANCEL_WIDTH,
                                         PICKER_TOP_BAR_ITEMS_HEIGHT);
    
    self.cancelButton.tintColor = [UIColor blueColor];
    [self.cancelButton addTarget:self action:@selector(dismissPickerViewAndCancel) forControlEvents:UIControlEventValueChanged];
    
    //Show the actionSheet
    [self.modalPickerView addSubview:self.confirmButton];
    [self.modalPickerView addSubview:self.cancelButton];
    [self.modalPickerView addSubview:self.pickerView];
    
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
        [self.pickerView setFrame:CGRectMake(pickerListOriginX, PICKER_TOP_BAR_HEIGHT, pickerListWidth, PICKER_LIST_HEIGHT)];
        
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
        [self.pickerView setFrame:CGRectMake(0,
                                             PICKER_TOP_BAR_HEIGHT,
                                             pickerListWidth,
                                             PICKER_LIST_HEIGHT)];
        
        UIView *view = [[UIView alloc] init];
        [view addSubview:self.pickerView];
        [view addSubview:self.cancelButton];
        [view addSubview:self.confirmButton];
        
        
        UIViewController *vc = [[UIViewController alloc] init];
        [vc setView:view];
        int contentViewHeight = self.pickerView.frame.size.height + PICKER_TOP_BAR_HEIGHT;
        [vc setPreferredContentSize:CGSizeMake(self.pickerView.frame.size.width,contentViewHeight)];
        
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
        UIViewController *parentForm = self.topParentViewController;
        
        [self.popoverController presentPopoverFromRect:self.mainFormControllerView.frame inView:parentForm.view permittedArrowDirections:0 animated:YES];
    }
    
    NSString *sEnumClassHelperName = [MFHelperType getClassHelperOfClassWithKey:self.mf.enumClassName]; // Nom de la classe Helper de l'Enum
    Class cEnumHelper = NSClassFromString(sEnumClassHelperName); // Classe Helper de l'Enum
    
    NSNumber *nsnEnum = [NSNumber numberWithInt:self.currentEnumValue]; // Conversion objet pour utilisation avec @selector
    NSString *sEnumText = [cEnumHelper performSelector:@selector(textFromEnum:) withObject:nsnEnum]; // Texte de l'Enum
    NSArray *aEnumTexts = [cEnumHelper performSelector:@selector(valuesToTexts) withObject:nil]; // Textes de l'Enum
    NSInteger nsiRow = [aEnumTexts indexOfObject:sEnumText]; // indice de l'Enum
    
    @try                     { [self.pickerView selectRow:nsiRow inComponent:0 animated:NO];  }
    @catch (id theException) { [self.pickerView selectRow:0      inComponent:0 animated:NO];
        [self pickerView:self.pickerView didSelectRow:0 inComponent:0];}
    
    self.isShowing = YES;
}


#pragma mark - Show/Dismiss/Orientation events

/**
 * @brief This method shows the modal PickerView with an animation
 */
-(void) showPickerModalViewInFrame:(CGRect)frame inView:(UIView *)view{
    self.isModalPickerViewDisplayed = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_NOTIFICATION_SHOW object:nil userInfo:nil];
    
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
    
    self.data = (id)[NSNumber numberWithInt:self.currentEnumValue];
    
    if([MFVersionManager isCurrentDeviceOfTypePhone])
    {
        [self hidePickerModalView];
    }
    else {
        if(self.popoverController && [self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:YES];
        }
    }
    [self valueChanged:self.pickerButton];
}

/**
 * @brief Dismiss this pickerView
 */
-(void) dismissPickerViewAndCancel {
    
    MFUILogVerbose(@"dismissPickerViewAndCancel - self.currentEnumValue=%i (avant)", self.currentEnumValue);
    self.currentEnumValue = [(NSNumber *) self.data intValue];
    
    NSString *sEnumClassHelperName = [MFHelperType getClassHelperOfClassWithKey:self.mf.enumClassName]; // Nom de la classe Helper de l'Enum
    Class cEnumHelper = NSClassFromString(sEnumClassHelperName); // Classe Helper de l'Enum
    
    NSNumber *nsnEnum = [NSNumber numberWithInt:self.currentEnumValue]; // Conversion objet pour utilisation avec @selector
    NSString *sEnumText = [cEnumHelper performSelector:@selector(textFromEnum:) withObject:nsnEnum]; // Texte de l'Enum
    NSArray *aEnumTexts = [cEnumHelper performSelector:@selector(valuesToTexts) withObject:nil]; // Textes de l'Enum
    NSInteger nsiRow = [aEnumTexts indexOfObject:sEnumText]; // indice de l'Enum
    
    @try                     { [self.pickerView selectRow:nsiRow inComponent:0 animated:YES]; }
    @catch (id theException) {                                                                }
    
    MFUILogVerbose(@"dismissPickerViewAndCancel - self.currentEnumValue=%i (apres)", self.currentEnumValue);
    
    
    //Obligation d'appeller l'évènement soi-même pour la mise à jour du VM car la méthode "selectRow" ne le fait pas (cf. doc Apple).
    [self performSelector:@selector(dismissPickerViewAndSave) withObject:nil afterDelay:0.35];
}


#pragma mark - Enum Changed Event

-(void) setPickerButtonTitle:(int)enumValue {
    if(!enumValue) {
        [self.pickerButton setTitle:@"NONE" forState:UIControlStateNormal];
        
    } else {
        NSString *sEnumClassHelperName = [MFHelperType getClassHelperOfClassWithKey:self.mf.enumClassName]; // Nom de la classe Helper de l'Enum
        Class cEnumHelper = NSClassFromString(sEnumClassHelperName); // Classe Helper de l'Enum
        NSNumber *nsnEnum = [NSNumber numberWithInt:enumValue]; // Conversion objet pour utilisation avec @selector
        NSString *sEnumText = [cEnumHelper performSelector:@selector(textFromEnum:) withObject:nsnEnum]; // Texte de l'Enum
        [self.pickerButton setTitle:sEnumText forState:UIControlStateNormal];
    }
}





#pragma mark -  MFOrieentationChangedDelegate

-(void)orientationDidChanged:(NSNotification *)notification {
    if(self.orientationChangedDelegate && [self.orientationChangedDelegate checkIfOrientationChangeIsAScreenNormalRotation] &&
       self.isModalPickerViewDisplayed) {
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



#pragma mark - Custom setters for class properties

-(void)setCurrentEnumValue:(int)currentEnumValue {
    _currentEnumValue = currentEnumValue;
    [self setPickerButtonTitle:self.currentEnumValue];
}



#pragma mark - MFUIComponentProtocol base methods

+(NSString *) getDataType {
    return @"NSNumber";
}

-(void)setData:(id)data {
    _data = data;
    self.currentEnumValue = [data intValue];
    [self setPickerButtonTitle:self.currentEnumValue];
}

-(id)getData {
    return self.data;
}


-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    if([self.editable isEqualToNumber:@0]) {
        [self.pickerButton removeTarget:self action:@selector(displayPickerView:) forControlEvents:UIControlEventTouchUpInside];
        [self.pickerButton setEditable:@0];
    }
    else {
        [self.pickerButton addTarget:self action:@selector(displayPickerView:) forControlEvents:UIControlEventTouchUpInside];
        [self.pickerButton setEditable:@1];
    }
}

#pragma mark - UIPickerView base methods

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSString *sEnumClassHelperName = [MFHelperType getClassHelperOfClassWithKey:self.mf.enumClassName]; // Nom de la classe Helper de l'Enum
    Class cEnumHelper = NSClassFromString(sEnumClassHelperName); // Classe Helper de l'Enum
    
    // Appel méthode : valuesCount
    NSUInteger nsuiEnumValuesCount = (NSUInteger)[cEnumHelper performSelector:@selector(valuesCount) withObject:nil]; // Nombre de valeurs de l'Enum
    
    return nsuiEnumValuesCount;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 45)];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    NSString *sEnumClassHelperName = [MFHelperType getClassHelperOfClassWithKey:self.mf.enumClassName]; // Nom de la classe Helper de l'Enum
    Class cEnumHelper = NSClassFromString(sEnumClassHelperName); // Classe Helper de l'Enum
    NSArray *aEnumValues = [cEnumHelper performSelector:@selector(valuesToTexts) withObject:nil]; // Valeurs de l'Enum
    label.text = [aEnumValues objectAtIndex:row]; // Utilisation de la valeur souhaitée de l'Enum
    
    return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    // Mémorisation seulement, utilisation dans dismissPickerViewAndSave/dismissPickerViewAndCancel
    
    
    NSString *sEnumClassHelperName = [MFHelperType getClassHelperOfClassWithKey:self.mf.enumClassName]; // Nom de la classe Helper de l'Enum
    Class cEnumHelper = NSClassFromString(sEnumClassHelperName); // Classe Helper de l'Enum
    NSArray *aEnumTexts = [cEnumHelper performSelector:@selector(valuesToTexts) withObject:nil]; // Valeurs de l'Enum
    NSString *sEnumText = [aEnumTexts objectAtIndex:row]; // Texte de l'Enum
    int idEnum = (int)[cEnumHelper performSelector:@selector(enumFromText:) withObject:sEnumText]; // Enum souhaitée
    
    MFUILogVerbose(@"pickerView: didSelectRow:%ld - self.currentEnumValue=%i (avant)", (long)row, self.currentEnumValue);
    self.currentEnumValue = idEnum;
    MFUILogVerbose(@"pickerView: didSelectRow:%ld - self.currentEnumValue=%i (apres)", (long)row, self.currentEnumValue);
}


/**
 * @brief Event called when the keyboard is displayed
 * The method changes the position of the pickerView to be not hidden by the keyboard
 */
- (void)keyboardWasShown:(NSNotification *)notification {
    if(self.isModalPickerViewDisplayed) {
        [self dismissPickerViewAndCancel];
    }
}

#pragma mark - Set control attributes
-(void)setControlAttributes:(NSDictionary *)controlAttributes {
    [super setControlAttributes:controlAttributes];
    if(controlAttributes[PICKER_PARAMETER_ENUM_CLASS_NAME_KEY]) {
        self.mf.enumClassName = controlAttributes[PICKER_PARAMETER_ENUM_CLASS_NAME_KEY];
    }
}

#pragma mark - Override targets
-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    MFControlChangedTargetDescriptor *commonCCTD = [MFControlChangedTargetDescriptor new];
    commonCCTD.target = target;
    commonCCTD.action = action;
    self.targetDescriptors = @{@(self.pickerButton.hash) : commonCCTD};
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
    UILabel *innerDescriptionLabel = [[UILabel alloc] initWithFrame:self.bounds];
    innerDescriptionLabel.text = [[self class] description];
    innerDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    innerDescriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    innerDescriptionLabel.backgroundColor = [UIColor colorWithRed:0.84 green:0.96 blue:0.97 alpha:0.8];
    [self addSubview:innerDescriptionLabel];
}

@end
