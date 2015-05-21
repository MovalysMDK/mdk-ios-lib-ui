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

#import "MFTextField.h"
#import "MFTextFieldStyle+ErrorView.h"
#import "MFTextFieldStyle+TextLayouting.h"
#import "MFBackgroundViewProtocol.h"
#import "MFKeyNotFound.h"
#import "MFUIError.h"
#import "MFUIControlExtension.h"
#import "MFFormBaseViewController.h"
#import "MFAlertViewManager.h"

@interface MFTextField ()

@property (nonatomic, strong) MFTextFieldExtension *extension;



@end

@implementation MFTextField
@synthesize styleClass = _styleClass;
@synthesize form = _form;
@synthesize componentInCellAtIndexPath = _componentInCellAtIndexPath;
@synthesize transitionDelegate = _transitionDelegate;
@synthesize localizedFieldDisplayName = _localizedFieldDisplayName;
@synthesize selfDescriptor = _selfDescriptor;
@synthesize groupDescriptor = _groupDescriptor;
@synthesize inInitMode = _inInitMode;
@synthesize bindingDelegate = _bindingDelegate;
@synthesize isValid = _isValid;
@synthesize mandatory = _mandatory;
@synthesize visible = _visible;
@synthesize editable = _editable;
@synthesize tooltipView= _tooltipView;
@synthesize cellContainer = _cellContainer;
@synthesize styleClassName = _styleClassName;
@synthesize componentValidation = _componentValidation;


#pragma mark - Initialization
-(instancetype)init {
    self = [super init];
    if(self) {
        [self initializeComponent];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initializeComponent];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self initializeComponent];
    }
    return self;
}

-(void) initializeComponent {
    self.bindingDelegate = [[MFComponentBindingDelegate alloc] initWithComponent:self];
    self.errors = [NSMutableArray new];
    self.extension = [[MFTextFieldExtension alloc] init];
    if(!self.sender) {
        self.sender = self;
    }
    self.componentValidation = YES;
    [self addTarget:self action:@selector(textDidChange) forControlEvents:UIControlEventEditingChanged|UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignFirstResponder) name:ALERTVIEW_FAILED_SAVE_ACTION object:nil];
    
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TextField Methods

-(void)setIsValid:(BOOL) isValid {
    [self.bindingDelegate setIsValid:isValid];
}

-(CGRect)textRectForBounds:(CGRect)bounds {
    [super textRectForBounds:bounds];
    return [((MFTextFieldStyle *)self.styleClass) textRectForBounds:bounds onComponent:self];
}

-(CGRect)editingRectForBounds:(CGRect)bounds {
    [super editingRectForBounds:bounds];
    return [((MFTextFieldStyle *)self.styleClass) editingRectForBounds:bounds onComponent:self];
}

-(CGRect)clearButtonRectForBounds:(CGRect)bounds {
    bounds = [super clearButtonRectForBounds:bounds];
    return [((MFTextFieldStyle *)self.styleClass) clearButtonRectForBounds:bounds onComponent:self];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    bounds = [super textRectForBounds:bounds];
    return [((MFTextFieldStyle *)self.styleClass) placeholderRectForBounds:bounds onComponent:self];
}

-(CGRect)borderRectForBounds:(CGRect)bounds {
    bounds = [super borderRectForBounds:bounds];
    return [((MFTextFieldStyle *)self.styleClass) borderRectForBounds:bounds onComponent:self];
    
}


#pragma mark - Target Actions
-(void)textDidChange {
    [self.sender performSelector:@selector(updateValue)];
}


#pragma mark - MDK


-(void) addAccessories:(NSDictionary *) accessoryViews {
    for(UIView *view in accessoryViews.allValues) {
        [self addSubview:view];
        [self bringSubviewToFront:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *constraintsToAdd = [((MFTextFieldStyle *)self.styleClass) defineConstraintsForAccessoryView:view withIdentifier:[[accessoryViews allKeysForObject:view] firstObject] onComponent:self];
        [self addConstraints:constraintsToAdd];
    }
}



+(NSString *)getDataType {
    return @"NSString";
}


-(void)setData:(id)data {
    id fixedData = data;
    if(data && ![data isKindOfClass:[MFKeyNotFound class]]) {
        NSString *stringData = (NSString *)data;
        fixedData = stringData;
    }
    else if(!data) {
        fixedData = @"";
    }
    self.text = fixedData;
}

-(id)getData {
    return [self displayComponentValue];
}

-(NSString *)displayComponentValue {
    return self.text;
}

-(void)setDisplayComponentValue:(id)value {
    if([value isKindOfClass:[NSString class]]) {
        self.text = value;
    }
    else if([value isKindOfClass:[NSAttributedString class]]){
        self.attributedText = value;
    }
}

-(NSInteger)validateWithParameters:(NSDictionary *)parameters {
    
    if(!self.componentValidation) {
        return 0;
    }
    [self.errors removeAllObjects];
    if(parameters) {
        // Do some treatments with specific
    }
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

-(void)didLoadFieldDescriptor:(MFFieldDescriptor *)fieldDescriptor {
    self.extension.maxLength = [fieldDescriptor.parameters objectForKey:PARAMETER_TEXTFIELD_MAXLENGTH_KEY];
    self.extension.minLength = [fieldDescriptor.parameters objectForKey:PARAMETER_TEXTFIELD_MINLENGTH_KEY];
}

-(void)setEditable:(NSNumber *)editable {
    _editable = editable;
    self.userInteractionEnabled = [editable boolValue];
    [self applyStandardStyle];
}

#pragma mark - Forwarding to binding delegate

-(void) updateValue {
    [self.bindingDelegate performSelectorOnMainThread: @selector(updateValue:) withObject:[self displayComponentValue] waitUntilDone:YES];
}

-(BOOL) isValid {
    return ([self validateWithParameters:nil] == 0);
}

-(NSArray *)getErrors {
    return [self.bindingDelegate getErrors];
}

-(void)addErrors:(NSArray *)errors {
    [self.bindingDelegate addErrors:errors];
}

-(void)clearErrors {
    [self.bindingDelegate clearErrors];
}

-(void)showError:(BOOL)showError {
    [self.bindingDelegate setIsValid:!showError];
}

-(void) onErrorButtonClick:(id)sender {
    [self.bindingDelegate onErrorButtonClick:sender];
}

-(void)prepareForInterfaceBuilder {
    [self applyStandardStyle];

    if(self.onError_MDK) {
        [self applyErrorStyle];
    }
    else {
        [self applyValidStyle];
    }
}

-(void)setUseCustomBackgroundView_MDK:(BOOL)useCustomBackgroundView_MDK {
    _useCustomBackgroundView_MDK = useCustomBackgroundView_MDK;
    if(_useCustomBackgroundView_MDK) {
        [self.styleClass performSelector:@selector(displayBackgroundViewOnComponent:) withObject:self];
    }
    else {
        [self.styleClass performSelector:@selector(removeBackgroundViewOnComponent:) withObject:self];
    }
}

-(void)setVisible:(NSNumber *)visible {
    _visible = visible;
    [self.bindingDelegate setVisible:visible];
}


@end
