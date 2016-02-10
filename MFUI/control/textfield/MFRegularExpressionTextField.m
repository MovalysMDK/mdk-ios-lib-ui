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
//  MFRegularExpressionTextField.m
//  MFUI
//
//

#import <MFCore/MFCoreFoundationExt.h>

#import "MFRegularExpressionTextField.h"
#import "MFUIBaseComponent.h"

#import "MFConverterProtocol.h"

@implementation MFRegularExpressionTextField

CGFloat const MFRETFWAB_DEFAULT_ACTION_BUTTON_WIDTH = 44;
CGFloat const MFRETFWAB_DEFAULT_ACTION_BUTTON_LEFT_MARGIN = 4;


#pragma mark - BaseComponent methods

-(void)initialize {
    [super initialize];
    
#if !TARGET_INTERFACE_BUILDER

    self.regularExpressionTextField.applySelfStyle = NO;
    self.regularExpressionTextField.sender= self.sender;
    
    [self setAllTags];
    
    
    self.mf = [self.applicationContext getBeanWithType:@protocol(MFExtensionKeyboardingUIControlWithRegExpProtocol)];
    
    
        self.actionButton.applySelfStyle = NO;
    [self.actionButton addTarget:self action:@selector(verify) forControlEvents:UIControlEventTouchUpInside];
    
    self.actionButton.hidden = ![self useActionButton];
    
    [self setAllTags];
    
    self.actionButtonWidth = MFRETFWAB_DEFAULT_ACTION_BUTTON_WIDTH;
    self.actionButtonLeftMargin = MFRETFWAB_DEFAULT_ACTION_BUTTON_LEFT_MARGIN;
    
    self.matchingOptions = NSMatchingWithoutAnchoringBounds;
    self.regularExpressionOptions = NSRegularExpressionAnchorsMatchLines;
    // We create the default error block.
    self.errorBuilderBlock = ^MFNoMatchingValueUIValidationError*(NSString *localizedFieldName, NSString *technicalFieldName){
        return [[MFNoMatchingValueUIValidationError alloc] initWithLocalizedFieldName:localizedFieldName technicalFieldName:technicalFieldName];
    };
    
#else
#endif
}

-(void) defineAndAddConstraints {
    self.regularExpressionTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *textFieldMarginLeftConstraint = [NSLayoutConstraint constraintWithItem:self.regularExpressionTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft  multiplier:1  constant:0];
    
    NSLayoutConstraint *textFieldWidthConstraint = [NSLayoutConstraint constraintWithItem:self.regularExpressionTextField  attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:[self useActionButton] ? 0.85 : 1 constant:0];

    
    NSLayoutConstraint *verticalSpacingBetweenTextFieldAndActionButtonConstraint = [NSLayoutConstraint constraintWithItem:self.regularExpressionTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.actionButton attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    
    NSLayoutConstraint *textFieldTopMarginConstraint = [NSLayoutConstraint constraintWithItem:self.regularExpressionTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];

    
    NSLayoutConstraint *textFieldBottomMarginConstraint = [NSLayoutConstraint constraintWithItem:self.regularExpressionTextField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    NSLayoutConstraint *textFieldAndActionButtonHeightsEqualityConstraint = [NSLayoutConstraint constraintWithItem:self.regularExpressionTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.actionButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    
    NSLayoutConstraint *actionButtonTopMarginConstraint = [NSLayoutConstraint constraintWithItem:self.actionButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint *actionButtonMarginRightConstraint = [NSLayoutConstraint constraintWithItem:self.actionButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self addConstraints:@[
                           textFieldMarginLeftConstraint,
                           textFieldWidthConstraint,
                           actionButtonMarginRightConstraint,
                           verticalSpacingBetweenTextFieldAndActionButtonConstraint,
                           textFieldTopMarginConstraint,
                           actionButtonTopMarginConstraint,
                           textFieldBottomMarginConstraint,
                           textFieldAndActionButtonHeightsEqualityConstraint
                           ]];
}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.regularExpressionTextField.textField.tag == 0
        || self.regularExpressionTextField.textField.tag == (int)TAG_MFTEXTFIELD_TEXTFIELD) {
        [self.regularExpressionTextField.textField setTag:TAG_MFREGULAREXPRESSIONTEXTFIELD_TEXTFIELD];
    }
    if (self.actionButton.tag == 0) {
        [self.actionButton setTag:TAG_MFREGULAREXPRESSIONTEXTFIELD_ACTIONBUTTON];
    }
}


#pragma mark - CSS customization

-(NSArray *)customizableComponents {
    return @[
             self.regularExpressionTextField.textField,
             self.actionButton
             ];
}

-(NSArray *)suffixForCustomizableComponents {
    return @[
             @"TextField",
             @"Button"
             ];
}


-(void) verify
{
    if([self validate] == 0)
    {
        [self doAction];
    }
    else
    {
        [self showErrors];
    }
}

-(void)doAction
{
    // Nothing to do here
}

#pragma mark - MFUIComponentProtocol implementation

-(NSString *) getValue
{
    return [self.regularExpressionTextField getValue];
}

-(void) setValue:(NSString *)value
{
    [self.regularExpressionTextField setValue:value];
}

+(NSString *)getDataType {
    return @"NSString";
}

-(void)setData:(id)data {
    NSString *stringData = (NSString *)data;
    [self.regularExpressionTextField setData:stringData];
}

-(id)getData {
    return [self getValue];
}

-(NSArray *) getErrors
{
    return [self.regularExpressionTextField getErrors];
}

-(BOOL) isActive
{
    return self.regularExpressionTextField.isActive;
}

-(void) setIsActive:(BOOL)isActive{
    self.regularExpressionTextField.isActive = isActive;
}

/*
 Validate the ui component value.
 @param parameters - parameters from the page
 
 @return Number of errors detected by the UI component
 */
-(NSInteger) validateWithParameters:(NSDictionary *) parameters
{
    NSInteger nbOfErrors = [super validateWithParameters:parameters];
    //Il faut effacer aussi les erreurs contenues dans le text field du composant
    //En effet, c'est dans celui-ci que les erreurs sont ajoutées.
    [self.regularExpressionTextField.baseErrors removeAllObjects];
    
    if(self.mf.mandatory != nil && [self.mf.mandatory integerValue] == 1 && [self getValue].length == 0){
        NSError *error = [[MFMandatoryFieldUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        [self addErrors:@[error]];
        [self.context addErrors:@[error]];
        nbOfErrors++;
    }
    
    if (self.regularExpressionTextField.text.length > 0) {
        
        if(![self match])
        {
            NSError *error = [self buildError];
            [self addErrors:@[error]];
            nbOfErrors++;
        }
        
    }
    
    return nbOfErrors;
}

/*
 Clean all component errors
 */
-(void) clearErrors
{
    [self.regularExpressionTextField clearErrors];
}

/*
 Clean all component errors
 */
-(void) clearErrors:(BOOL)anim
{
    [self.regularExpressionTextField clearErrors:anim];
}

/*
 Add errors to component.
 */
-(void) addErrors:(NSArray *) errors
{
    if(errors != nil) {
        [self.regularExpressionTextField addErrors:errors];
    }
}


-(void) setLocalizedFieldDisplayName:(NSString *)localizedFieldDisplayName
{
    [super setLocalizedFieldDisplayName:localizedFieldDisplayName];
    self.regularExpressionTextField.localizedFieldDisplayName = localizedFieldDisplayName;
}

//
//-(void) setFormDescriptor:(MFFormDescriptor *)formDescriptor
//{
//    [super setFormDescriptor:formDescriptor];
//    self.regularExpressionTextField.formDescriptor = formDescriptor;
//}
//

-(void) setGroupDescriptor:(MFGroupDescriptor *)groupDescriptor
{
    [super setGroupDescriptor:groupDescriptor];
    self.regularExpressionTextField.groupDescriptor = groupDescriptor;
}

#pragma mark - Fast Forwarding
-(id)forwardingTargetForSelector:(SEL)sel {
    return self.regularExpressionTextField;
}

#pragma mark - KVC magic forwarding
-(id)valueForUndefinedKey:(NSString *)key {
    if(![key isEqualToString:@"mf."]) {
        return [self.regularExpressionTextField valueForKey:key];
    }
    return [self valueForKey:key];
}

-(void) setValue:(id)value forUndefinedKey:(NSString *)key {
    [super setValue:value forUndefinedKey:key];
}

-(id)valueForKey:(NSString *)key {
    id obj = [super valueForKey:key];
    return obj;
}

#pragma mark - Regular expression text field specific functions


/*
 Set an image at button's center for normal ui control state.
 */
-(void) setButtonImage:(NSString *) imageName
{
    UIImage *buttonImage = [UIImage imageNamed:imageName];
    [self.actionButton setImage:buttonImage forState:UIControlStateNormal];
    [self.actionButton setImage:buttonImage forState:UIControlStateApplication];
    [self setNeedsDisplay];
}

/*
 Set an image in button's bakground for normal ui control state.
 */
-(void) setButtonBackground:(NSString *) imageName{
    UIImage *buttonImage = [UIImage imageNamed:@"envelope.png"];
    [self.actionButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self setNeedsDisplay];
}

#pragma mark - specific function for regex

/*
 Show error message to user.
 */
-(void) showErrors
{
    [self.regularExpressionTextField showErrorButtons];
    [self.regularExpressionTextField showErrorTooltips];
}

-(id<UITextFieldDelegate>) delegate
{
    return self.regularExpressionTextField.delegate;
}

-(void) setDelegate:(id<UITextFieldDelegate>)delegate
{
    self.regularExpressionTextField.delegate = delegate;
}

#pragma mark - Specific text field functions or properties

-(void) setKeyboardType:(UIKeyboardType) type
{
    [self.regularExpressionTextField setKeyboardType:type];
}

#pragma mark - Control extension

-(void) setMf:(id<MFExtensionKeyboardingUIControlWithRegExpProtocol>)mf
{
    self.regularExpressionTextField.mf = mf;
}

-(id<MFExtensionKeyboardingUIControlWithRegExpProtocol>) mf
{
    return (id<MFExtensionKeyboardingUIControlWithRegExpProtocol>)self.regularExpressionTextField.mf;
}

#pragma mark - Descriptor


-(void) setSelfDescriptor:(NSObject<MFDescriptorCommonProtocol> *)selfDescriptor
{
    [super setSelfDescriptor:selfDescriptor];
}

/**
 * Check if the component value and the pattern match.
 * @param options - matching options (see NSMatchingOptions for more informations)
 * @return YES if the component value and the pattern match one and only one time.
 */
-(BOOL) matchWithOptions: (NSMatchingOptions) options{
    NSError *error = nil;
    // We compile the regular expression with options
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:([NSString isNilOrEmpty:self.mf.regularExpression] ? self.pattern : self.mf.regularExpression) options:self.regularExpressionOptions error:&error];
    // We check matching
    NSUInteger numberOfMatches = 0;
    if([self getValue] != nil)
    {
        numberOfMatches = [regularExpression numberOfMatchesInString:[self getValueToMatch]
                                                             options:options
                                                               range:NSMakeRange(0, [[self getValueToMatch] length])];
    }
    // We check error
    if(error != nil){
        // If the regular expression can't be built, this component is out of service.
        // So we prefer to throw an exception to alert developer more early as possible.
        @throw([NSException exceptionWithName:error.domain reason:[NSString stringWithFormat:@"Field named '%@' throws the following error : %@", self.selfDescriptor.name, error.localizedDescription] userInfo:error.userInfo]);
    }
    return numberOfMatches > 0;
}

-(NSString *) getValueToMatch {
    NSString *valueToReturn = [self getValue];
    NSDictionary *converterData = ((MFFieldDescriptor *)self.selfDescriptor).converter;
    if(converterData) {
        NSString *converterType = [converterData objectForKey:@"type"];
        NSString *converterClassName = [NSString stringWithFormat:@"MF%@Converter", [converterType capitalizedString]];
        id<MFConverterProtocol> converter = [[NSClassFromString(converterClassName) alloc] init];
        if(converter) {
            if([NSClassFromString(converterClassName) respondsToSelector:@selector(toStringForValidation:)]) {
                valueToReturn = [NSClassFromString(converterClassName) toStringForValidation:[self getData]];
            }
        }
    }
    
    return valueToReturn;
}

/**
 * Check if the component value and the pattern match.
 * Apply the matching options defined by self.matchingOptions.
 * @return YES if the component value and the pattern match one and only one time.
 */
-(BOOL) match{
    return [self matchWithOptions:self.matchingOptions];
}

/*
 Build the error which means control's value doesn't match with pattern.
 */
-(MFNoMatchingValueUIValidationError *) buildError
{
    return self.errorBuilderBlock(self.localizedFieldDisplayName, self.selfDescriptor.name);
}

-(MFConfigurationKeyboardingRegularExpressionUIComponent *) loadConfiguration:(NSString *) configurationName
{
    MFConfigurationKeyboardingRegularExpressionUIComponent *config = (MFConfigurationKeyboardingRegularExpressionUIComponent*) [super loadConfiguration:configurationName];
    if(config) {
        //Nothing to do here for now
    }
    return config;
}

-(void) displayButton:(BOOL)shouldBeDisplayed {
    //On affiche ou non le bouton
    [self.actionButton setHidden:!shouldBeDisplayed];
    
    //On redimensionne les éléments graphiques après affichage ou masquage du bouton
    if(shouldBeDisplayed) {
        self.actionButtonWidth = MFRETFWAB_DEFAULT_ACTION_BUTTON_WIDTH;
        self.actionButtonLeftMargin = MFRETFWAB_DEFAULT_ACTION_BUTTON_LEFT_MARGIN;
    }
    else {
        self.actionButtonWidth = 0;
        self.actionButtonLeftMargin = 0;
    }
    [self setNeedsDisplay];
}

-(void)setMandatory:(NSNumber *)mandatory {
    //Non implémenté
}

/**
 * give the index path to the component too
 */
-(void) setComponentInCellAtIndexPath:(NSIndexPath *)componentInCellAtIndexPath {
    [super setComponentInCellAtIndexPath:componentInCellAtIndexPath];
    [self.regularExpressionTextField setComponentInCellAtIndexPath:componentInCellAtIndexPath];
}
/**
 * give the form controller to the component too
 */
-(void)setForm:(id<MFComponentChangedListenerProtocol> )formController {
    [super setForm:formController];
    [self.regularExpressionTextField  setForm:formController];
}
-(void)dealloc {
    self.regularExpressionTextField.sender = nil;
}

-(void)setIsValid:(BOOL)isValid {
    [self.regularExpressionTextField setIsValid:isValid];
}

-(BOOL) isValid {
    return [self.regularExpressionTextField isValid];
}

-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    [self.regularExpressionTextField setEditable:editable];
}

-(BOOL)useActionButton {
    return YES;
}

-(void)setComponentAlignment:(NSNumber *)alignValue {
    [self.regularExpressionTextField setTextAlignment:[alignValue intValue]];
}

-(void) setTextColor:(UIColor *)color {
    [self.regularExpressionTextField setTextColor:color];
}


#pragma mark - LiveRendering Methods


-(void)buildDesignableComponentView {
    self.regularExpressionTextField = [[MFTextField alloc] initWithFrame:self.bounds withSender:self];
    self.actionButton = [[MFButton  alloc] init];
    [self addSubview:self.regularExpressionTextField];
    [self addSubview:self.actionButton];
    [self defineAndAddConstraints];
}

-(void)initializeInspectableAttributes {
    [super initializeInspectableAttributes];
    self.IB_TextSize = 16;
    self.IB_TextColor = [UIColor blackColor];
    self.IB_primaryBackgroundColor = [UIColor clearColor];
    self.IB_secondaryTintColor = [UIColor clearColor];
}

-(void)willLayoutSubviewsNoDesignable {
}

-(void)renderComponentFromInspectableAttributes {
    self.regularExpressionTextField.textColor = self.IB_TextColor;
    self.regularExpressionTextField.font = [UIFont fontWithName:self.regularExpressionTextField.textField.font.familyName size:self.IB_TextSize];
    self.regularExpressionTextField.text = self.IB_uText;
    self.actionButton.backgroundColor = [UIColor orangeColor];
//    self.actionButton.backgroundColor = self.IB_primaryBackgroundColor;

    self.regularExpressionTextField.backgroundColor = self.IB_primaryBackgroundColor;

}

-(void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    self.regularExpressionTextField.textField.frame = self.frame;
    if(!self.IB_enableIBStyle) {
        [self.actionButton setImage:[UIImage imageNamed:@"gps"] forState:UIControlStateNormal];
        self.actionButton.backgroundColor = [UIColor purpleColor];
        self.actionButton.button.backgroundColor = [UIColor orangeColor];
    }
}


@end
