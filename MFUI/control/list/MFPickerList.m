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
//  MFPickerList.m
//  MFUI
//
//

//MFCore iumports
#import <MFCore/MFCoreI18n.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreConfig.h>
#import <MFCore/MFCoreFormConfig.h>


//Picker imports
#import "MFPickerList.h"
#import "MFPickerListSelectionIndicator.h"
#import "MFPickerControllerDelegate.h"

//Cells
#import "MFCellAbstract.h"

//Import Binding
#import "MFFormBaseViewController.h"

//Import Utils
#import "MFColorValueProcessing.h"
#import "MFVersionManager.h"

//Import Exception
#import  <MFCore/MFCoreError.h>
#import "MFUIBaseListViewModel.h"



#pragma mark - Define some constants

#define PICKER_TOP_BAR_HEIGHT  40.f
#define PICKER_SEARCH_BAR_HEIGHT 40.f
#define PICKER_TOP_BAR_ITEMS_MARGIN  7.f
#define PICKER_TOP_BAR_ITEMS_HEIGHT  30.f
#define PICKER_TOP_BAR_CANCEL_WIDTH  75.f
#define PICKER_TOP_BAR_CONFIRM_WIDTH 50.f
#define PICKER_LIST_HEIGHT 164.f

//Parameters keys
NSString *const PICKER_PARAMETER_SEARCH_KEY = @"search";
NSString *const PICKER_PARAMETER_VALUES_KEY= @"pickerValuesKey";
NSString *const PICKER_PARAMETER_SELECTION_INDICATOR_COLOR_KEY = @"selectionIndicatorColor";
NSString *const PICKER_PARAMETER_OK_BUTTON_COLOR_KEY = @"okButtonColor";
NSString *const PICKER_PARAMETER_CANCEL_BUTTON_COLOR_KEY = @"cancelButtonColor";
NSString *const PICKER_PARAMETER_SELECTED_VIEW_FORM_DESCRIPTOR_NAME_KEY = @"selectedViewFormDescriptorName";
NSString *const PICKER_PARAMETER_LIST_ITEM_VIEW_FORM_DESCRIPTOR_NAME_KEY = @"lstItemViewFormDescriptorName";
NSString *const PICKER_PARAMETER_EMPTY_VIEW_NIB_NAME = @"emptyViewNibName";

//Notifications keys
NSString *const PICKER_NOTIFICATION_FORCE_HIDE = @"pickerViewExternalForceHide";
NSString *const PICKER_NOTIFICATION_SHOW = @"pickerViewShow";
NSString *const PICKER_NOTIFICATION_HIDE = @"pickerViewHide";
NSString *const PICKER_NOTIFICATION_BUTTON_SAVE_TITLE = @"MFPickerListSaveButtonTitle";
NSString *const PICKER_NOTIFICATION_BUTTON_CANCEL_TITLE = @"MFPickerListCancelButtonTitle";

//Constants
const int PICKER_VIEW_TAG = INT16_MAX;
const int NO_LAST_INDEX = -1;



#pragma mark - Interface

@interface MFPickerList()


/**
 * @brief The index of the last selection state, needed to restore the value if the user
 */
@property (nonatomic) NSInteger lastIndex;

/**
 * @brief The popover window to display the PickerList on iPad
 */
@property (nonatomic, strong) UIPopoverController *popoverController;

/**
 * @brief Indicates if the component shoul displaye the searchBar
 */
@property (nonatomic) BOOL hasSearch;

/**
 * @brief Indicates if the constraints between the storyboard and the pickerlist have been added
 */
@property (nonatomic) BOOL constraintsAdded;

/**
 * @brief Indicates if the PickerList is currently displayed
 */
@property (nonatomic) BOOL isModalPickerViewDisplayed;

/**
 * @brief The view of the main form controller of this component
 */
@property (nonatomic, strong) UIView *mainFormControllerView;

/**
 * @brief The picker controller delegate that manages data of the inner pickerview
 */
@property (nonatomic, strong) MFPickerControllerDelegate *controllerDelegate;

/**
 * @brief An instance of the configurationHandler
 */
@property (nonatomic, strong) MFConfigurationHandler *configurationHandlerInstance;

/**
 * @brief Le tableau contenant les données de la Liste éditable
 */
@property (nonatomic, strong) MFUIBaseViewModel *data;

@end

@implementation MFPickerList
@synthesize data = _data;
@synthesize  staticView = _staticView;
@synthesize currentOrientation = _currentOrientation;

#pragma mark - Initializing and view lifecycle

-(void)initialize {
    [super initialize];
    
    self.controllerDelegate = [[MFPickerControllerDelegate alloc] initWithPickerList:self];
    
    //Initialize
    self.isShowing = NO;
    self.lastIndex = NO_LAST_INDEX;
    self.isModalPickerViewDisplayed = NO;
    self.constraintsAdded = NO;
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
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
    
    self.configurationHandlerInstance = [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    
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





#pragma mark - Manage UI

-(void) addCustomConstraints {
    if(self.staticView) {
        
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.staticView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.staticView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.staticView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.staticView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        [self addConstraints:@[topConstraint, leftConstraint, rightConstraint, bottomConstraint]];
        self.constraintsAdded = YES;
        
    }
}






#pragma mark - MFUIBaseComponent methods

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

-(void)setData:(MFUIBaseViewModel *)data {
    _data = data;
    [self.controllerDelegate setContent];
}


#pragma mark - GestureRecognizers methods

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    
    UIView *currentView = touch.view;
    while (currentView) {
        if([self.staticView isEqual:touch.view]) {
            if([self.editable isEqualToNumber:@1]) {
                [self displayPickerView];
                [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
            }
            break;
        }
        currentView = currentView.superview;
    }
    
}


#pragma mark - Tags for automatic testing

-(void) setAllTags {
    if (self.pickerView.tag == 0) {
        [self.pickerView setTag:TAG_MFPICKERLIST_PICKERVIEW];
    }
    if (self.confirmButton.tag == 0) {
        [self.confirmButton setTag:TAG_MFPICKERLIST_CONFIRMBUTTON];
    }
    if (self.cancelButton.tag == 0) {
        [self.cancelButton setTag:TAG_MFPICKERLIST_CANCELBUTTON];
    }
}

#pragma mark - Specific methods for this component
/**
 * @brief This method builds and shows the pickerView in an ActionSheet (iPhone) or in a PopoverViewController (iPad)
 */
-(void) displayPickerView {
    if(self.isModalPickerViewDisplayed) {
        return;
    }
    
    [self.controllerDelegate reinitBinding];
    
    self.hasSearch = [[((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:PICKER_PARAMETER_SEARCH_KEY] boolValue];
    
    //Get FormViewController parent
    //    UIView *topView = self;
    //
    //    while(topView.superview) {
    //        topView = topView.superview;
    //    }
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
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.showsSelectionIndicator = NO;
    
    //Build and initialize the searchBar if needed
    if(self.hasSearch) {
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(pickerListOriginX,
                                                                       PICKER_LIST_HEIGHT+PICKER_TOP_BAR_HEIGHT,
                                                                       pickerListWidth,
                                                                       PICKER_SEARCH_BAR_HEIGHT)];
        [self.searchBar setBarStyle:UIBarStyleBlackTranslucent];
        self.searchBar.delegate = self;
        
        //Set "Done" title instead of "Search" in the keyboard
        for (UIView *searchBarSubview in [self.searchBar subviews]) {
            if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
                [(UITextField *)searchBarSubview setReturnKeyType:UIReturnKeyDone];
            }
        }
    }
    
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
    self.cancelButton.tintColor = cancelButtonColor ;
    [self.cancelButton addTarget:self action:@selector(dismissPickerViewAndCancel) forControlEvents:UIControlEventValueChanged];
    
    //Show the actionSheet
    [self.modalPickerView addSubview:self.confirmButton];
    [self.modalPickerView  addSubview:self.cancelButton];
    [self.modalPickerView  addSubview:self.searchBar];
    [self.modalPickerView  addSubview:self.pickerView];
    [self.modalPickerView  bringSubviewToFront:self.searchBar];
    
    //Specific code for iPhone/iPad : to display a PickerView, you need to display it in a popover
    if([MFVersionManager isCurrentDeviceOfTypePhone]) //iPhone
    {
        [self displayPickerOniPhoneWithPickerListOriginX:pickerListOriginX andWithPickerListWidth:pickerListWidth];
    }
    else { //iPad
        [self displayPickerViewOniPadWithPickerListWidth:pickerListWidth];
    }
    [self initPicker];
    
}

-(void) displayPickerOniPhoneWithPickerListOriginX:(float)pickerListOriginX andWithPickerListWidth:(float)pickerListWidth{
    float whiteDegree = 1.0;
    if(SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        whiteDegree = 0.0;
    }
    
    [self.modalPickerView setBackgroundColor:[UIColor colorWithWhite:whiteDegree alpha:0.9]];
    
    //Set pickerFrame
    int pickerYHeight = self.hasSearch ? PICKER_SEARCH_BAR_HEIGHT : 0;
    pickerYHeight += (PICKER_TOP_BAR_HEIGHT + PICKER_LIST_HEIGHT);
    [self.pickerView setFrame:CGRectMake(pickerListOriginX, PICKER_TOP_BAR_HEIGHT, pickerListWidth, PICKER_LIST_HEIGHT)];
    
    
    if(self.hasSearch) {
        [self.searchBar resignFirstResponder];
    }
    
    CGRect modalPickerViewFrame = CGRectMake(self.mainFormControllerView.frame.origin.x,
                                             self.mainFormControllerView.frame.size.height - pickerYHeight,
                                             self.mainFormControllerView.frame.size.width,
                                             pickerYHeight);
    
    CGRect initialPickerModalPosition = modalPickerViewFrame;
    initialPickerModalPosition.origin.y  = self.mainFormControllerView.frame.size.height;
    [self.modalPickerView setFrame:initialPickerModalPosition];
    [self showPickerModalViewInFrame:modalPickerViewFrame inView:self.mainFormControllerView];
}

-(void) displayPickerViewOniPadWithPickerListWidth:(float)pickerListWidth {
    [self saveCurrentIndex];
    
    [self.pickerView setFrame:CGRectMake(0,
                                         PICKER_TOP_BAR_HEIGHT,
                                         pickerListWidth,
                                         PICKER_LIST_HEIGHT)];
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:self.pickerView];
    [view addSubview:self.cancelButton];
    [view addSubview:self.confirmButton];
    if(self.hasSearch) {
        [view addSubview:self.searchBar];
    }
    
    UIViewController *vc = [[UIViewController alloc] init];
    [vc setView:view];
    int contentViewHeight = self.hasSearch ? PICKER_SEARCH_BAR_HEIGHT : 0;
    contentViewHeight +=  self.pickerView.frame.size.height + PICKER_TOP_BAR_HEIGHT;
    [vc setContentSizeForViewInPopover:CGSizeMake(self.pickerView.frame.size.width,contentViewHeight)];
    
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
    MFCellAbstract *parentCell = (MFCellAbstract *)self.cellContainer;
    MFFormBaseViewController *parentForm = (MFFormBaseViewController *)parentCell.formController;
    
    [self.popoverController presentPopoverFromRect:self.mainFormControllerView.frame inView:parentForm.view permittedArrowDirections:0 animated:YES];
    
}

/**
 * @see MFPickerList.h
 */
-(CGRect) pickerFrame {
    return self.pickerView.frame;
}


/**
 * @brief Dismiss this pickerView
 */
-(void) dismissPickerViewAndSave {
    
    // Avant on sélectionne le vm
    NSInteger row = [self.pickerView selectedRowInComponent:0] ;
    [self.controllerDelegate selectViewModel:row] ;
    if([self pickerListViewModel].viewModels.count > 0) {
        _data = [[self pickerListViewModel].viewModels objectAtIndex:[self.pickerView selectedRowInComponent:0]];
    }
    else {
        _data = nil;
    }
    [self updateValue:_data];
    if([MFVersionManager isCurrentDeviceOfTypePhone])
    {
        [self hidePickerModalView];
        [self.searchBar resignFirstResponder];
    }
    else {
        if(self.popoverController && [self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:YES];
        }
    }
    //    [self.controllerDelegate unregisterAllComponents];
}

/**
 * @brief Dismiss this pickerView
 */
-(void) dismissPickerViewAndCancel {
    if([self pickerListViewModel].viewModels.count > 0) {
        [self.pickerView selectRow:self.lastIndex inComponent:0 animated:YES];
    }
    
    //Obligation d'appeller l'évènement soi-même pour la mise à jour du VM car la méthode "selectRow" ne le fait pas (cf. doc Applle).
    if(self.hasSearch) {
        [((id<MFSearchDelegate>)self.controllerDelegate) updateFilterWithText:@""];
    }
    
    if([self pickerListViewModel].viewModels.count > 0) {
        [self.controllerDelegate pickerView:self.pickerView didSelectRow:self.lastIndex inComponent:0];
    }
    [self performSelector:@selector(dismissPickerViewAndSave) withObject:nil afterDelay:0.35];
}


/**
 * @brief Adds the static view to the component
 * @param staticView The static view to add
 */
-(void)setStaticView:(MFBindingViewAbstract *)staticView {
    
    if(!_staticView || ![_staticView isEqual:staticView]) {
        if(_staticView) {
            [_staticView removeFromSuperview];
        }
        _staticView = (MFBindingViewAbstract *)staticView;
        
        [self setNeedsDisplay];
        //Dans la vue sélectionnée, les champs ne sont pas éditables
        for(UIView * view in staticView.subviews) {
            view.userInteractionEnabled = NO;
        }
        [self addSubview:_staticView];
        [_staticView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addCustomConstraints];
        [self updateConstraints];
    }
}


/**
 * Selects The row in the pickerView corresponding to the selected viewModel
 */
-(NSUInteger) selectCorrectRow {
    if (_data != nil) {
        if([self pickerListViewModel].viewModels && (![[self pickerListViewModel].viewModels count] == 0))
        {
            return [[self pickerListViewModel].viewModels indexOfObject:_data];
        }
    }
    return 0;
}

/**
 * Adds a custom selection indicator to the pickerView
 */
-(void) addCustomSelectionIndicatorViewWithOffset:(int)offset {
    CGFloat itemViewHeight = [self.controllerDelegate itemView].frame.size.height;
    
    UIColor *selectionIndicatorColor = [MFColorValueProcessing processColorFromString:[[((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:PICKER_PARAMETER_SELECTION_INDICATOR_COLOR_KEY] stringByAppendingString:@"Color"]];
    if(!selectionIndicatorColor) {
        selectionIndicatorColor = [UIColor blueColor];
    }
    MFPickerListSelectionIndicator *customSelectionIndicator =
    [[MFPickerListSelectionIndicator alloc] initWithFrame:CGRectMake(self.pickerFrame.origin.x,
                                                                     self.pickerFrame.size.height / 2 - itemViewHeight/2 + offset,
                                                                     self.pickerFrame.size.width,
                                                                     itemViewHeight) andColor:selectionIndicatorColor];
    
    customSelectionIndicator.userInteractionEnabled = NO;
    if([MFVersionManager isCurrentDeviceOfTypePhone])
    {
        [self.modalPickerView addSubview:customSelectionIndicator];
    }
    else {
        [self.popoverController.contentViewController.view addSubview:customSelectionIndicator];
    }
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
        self.pickerView = nil;
        self.modalPickerView = nil;
    }];
}


/**
 * @brief This method shows the modal PickerView with an animation
 */
-(void) showPickerModalViewInFrame:(CGRect)frame inView:(UIView *)view{
    
    if([self pickerListViewModel].viewModels.count > 0) {
        [self saveCurrentIndex];
        
        [view addSubview:self.modalPickerView];
        
        self.isModalPickerViewDisplayed = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_NOTIFICATION_SHOW object:nil userInfo:nil];
        
        [UIView animateWithDuration:0.25 animations:^{
            [self.modalPickerView setFrame:frame];
            
        } completion:^(BOOL finished) {
            [self.modalPickerView setHidden:NO];
        }];
    }
    else {
        UIAlertView *noDataAlert = [[UIAlertView alloc] initWithTitle:MFLocalizedStringFromKey(@"MFPickerList_noData_title") message:MFLocalizedStringFromKey(@"MFPickerList_noData_message")  delegate:self cancelButtonTitle:MFLocalizedStringFromKey(@"MFPickerList_noData_button")  otherButtonTitles:nil];
        [noDataAlert show];
    }
}

-(void) initPicker {
    
    //init the PickerView
    NSUInteger currentSelectedRow = [self selectCorrectRow];
    [self.controllerDelegate fillSelectedViewWithViewModel:_data];
    if(self.lastIndex == NO_LAST_INDEX) {
        self.lastIndex = currentSelectedRow;
    }
    
    self.isShowing = YES;
    
    if(SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addCustomSelectionIndicatorViewWithOffset:PICKER_TOP_BAR_HEIGHT];
        });
    }
    
    if(self.hasSearch ) {
        [((id<MFSearchDelegate>)self.controllerDelegate) updateFilterWithText:@""];
    }
    [self.pickerView selectRow:currentSelectedRow inComponent:0 animated:YES];
}

/**
 * @brief Sauve l'état actuel du picket, pour restauré l'item sélectionné lorsque l'utilisateurt appuie sur "Annuler"
 */
-(void)saveCurrentIndex {
    self.lastIndex = [self selectCorrectRow];
}

-(id) getValues {
    MFUIBaseListViewModel *values = nil;
    NSString *valuesPropertyName = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:PICKER_PARAMETER_VALUES_KEY];
    if(!valuesPropertyName) {
        //                [MFException throwExceptionWithName:@"Missing field"
        //                                          andReason:[NSString stringWithFormat:@"The field %@ is missing in the parameters of the PLIST for the component %@", PICKER_PARAMETER_VALUES_KEY, self.selfDescriptor.name]
        //                                        andUserInfo:nil];
    }
    else {
        MFUIBaseViewModel *formViewModel = (MFUIBaseViewModel *)[((MFFormBaseViewController *)((MFCellAbstract *)self.form)) getViewModel];
        id object = [formViewModel valueForKeyPath:valuesPropertyName];
        if(object && [object isKindOfClass:[MFUIBaseListViewModel class]]) {
            values = (MFUIBaseListViewModel *) object;
        }
    }
    return values;
}

-(NSString *)selectedViewFormDescriptorName {
    NSString *localSelectedViewFormDescriptorName = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:PICKER_PARAMETER_SELECTED_VIEW_FORM_DESCRIPTOR_NAME_KEY];
    if([self.configurationHandlerInstance getFormDescriptorProperty:localSelectedViewFormDescriptorName]) {
        [self.configurationHandlerInstance loadFormWithName:localSelectedViewFormDescriptorName];
    }
    return localSelectedViewFormDescriptorName;
}

-(NSString *)lstItemViewFormDescriptorName {
    NSString *localLstItemViewFormDescriptorName = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:PICKER_PARAMETER_LIST_ITEM_VIEW_FORM_DESCRIPTOR_NAME_KEY];
    return localLstItemViewFormDescriptorName;
}



#pragma mark - Search Bar Delegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [((id<MFSearchDelegate>)self.controllerDelegate) updateFilterWithText:searchText];
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self dismissPickerViewAndSave];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissPickerViewAndCancel];
}

-(void) selectSpecificRow:(NSNumber *)oldSelectedRow {
    [self.pickerView selectRow:[oldSelectedRow integerValue] inComponent:0 animated:TRUE] ;
}


#pragma mark - MFOrientationChangedDelegate

-(void)registerOrientationChange {
    self.currentOrientation = [[UIDevice currentDevice] orientation];
    self.orientationChangedDelegate = [[MFOrientationChangedDelegate alloc] initWithListener:self];
    [self.orientationChangedDelegate registerOrientationChanges];
}

-(void)orientationDidChanged:(NSNotification *)notification {
    if(self.orientationChangedDelegate && [self.orientationChangedDelegate checkIfOrientationChangeIsAScreenNormalRotation]) {
        if(self.isModalPickerViewDisplayed) {
            //Save the old selected value to display the good one after the re-creation
            NSNumber* oldSelectedRow =[NSNumber numberWithInteger:[self.pickerView selectedRowInComponent:0]];
            
            [self hidePickerModalView];
            if([self.editable isEqualToNumber:@1]) {
                [self performSelector:@selector(displayPickerView) withObject:nil afterDelay:0.75];
            }
            
            [self performSelector:@selector(selectSpecificRow:) withObject:oldSelectedRow afterDelay:1.00];
            
        }
        self.staticView = _staticView;
    }
    self.currentOrientation = [[UIDevice currentDevice] orientation];
}


#pragma mark - Observers selectors

/**
 * @brief Event called when the keyboard is displayed
 * The method changes the position of the pickerView to be not hidden by the keyboard
 */
- (void)keyboardWasShown:(NSNotification *)notification {
    if(self.isModalPickerViewDisplayed && !self.hasSearch) {
        [self dismissPickerViewAndCancel];
    }
}



-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
}

-(void)setPickerView:(UIPickerView *)pickerView {
    _pickerView = pickerView;
    _pickerView.delegate = self.controllerDelegate;
    _pickerView.dataSource = self.controllerDelegate;
}


-(void)didFinishLoadDescriptor {
    self.emptyViewNibName = [((MFFieldDescriptor *)self.selfDescriptor).parameters objectForKey:PICKER_PARAMETER_EMPTY_VIEW_NIB_NAME];
    [self.controllerDelegate fillSelectedViewWithViewModel:[[NSClassFromString(@"MFEmptyViewModel") alloc] init]];
}

-(MFUIBaseListViewModel *) pickerListViewModel {
    return (MFUIBaseListViewModel *)[self getValues];
}

@end
