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
#import "MFLabel.h"
#import "MFUIFieldValidator.h"

@interface MFTextField ()

@property (nonatomic, strong) MFTextFieldExtension *extension;



@end

@implementation MFTextField
@synthesize styleClass = _styleClass;
@synthesize componentInCellAtIndexPath = _componentInCellAtIndexPath;
@synthesize transitionDelegate = _transitionDelegate;
@synthesize localizedFieldDisplayName = _localizedFieldDisplayName;
@synthesize selfDescriptor = _selfDescriptor;
@synthesize inInitMode = _inInitMode;
@synthesize controlDelegate = _bindingDelegate;
@synthesize isValid = _isValid;
@synthesize mandatory = _mandatory;
@synthesize visible = _visible;
@synthesize editable = _editable;
@synthesize tooltipView= _tooltipView;
@synthesize styleClassName = _styleClassName;
@synthesize componentValidation = _componentValidation;
@synthesize controlAttributes = _controlAttributes;
@synthesize associatedLabel = _associatedLabel;
@synthesize targetDescriptors = _targetDescriptors;
@synthesize errors = _errors;
@synthesize lastUpdateSender = _lastUpdateSender;
@synthesize privateData = _privateData;


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
    self.controlDelegate = [[MFCommonControlDelegate alloc] initWithComponent:self];
    self.errors = [NSMutableArray new];
    self.extension = [[MFTextFieldExtension alloc] init];
    if(!self.sender) {
        self.sender = self;
    }
    self.componentValidation = YES;
    [self addTarget:self action:@selector(innerTextDidChange:) forControlEvents:UIControlEventEditingChanged|UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignFirstResponder) name:ALERTVIEW_FAILED_SAVE_ACTION object:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.targetDescriptors = nil;
}

#pragma mark - TextField Methods

-(void)setIsValid:(BOOL) isValid {
    [self.controlDelegate setIsValid:isValid];
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
-(void)textDidChange:(id)sender {
//    [self valueChanged:sender];
}

-(void)innerTextDidChange:(id)sender {
    [self valueChanged:sender];
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
    [self validate];
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


-(void)setEditable:(NSNumber *)editable {
    _editable = editable;
    self.userInteractionEnabled = [editable boolValue];
    [self applyStandardStyle];
}

#pragma mark - Forwarding to binding delegate


-(BOOL) isValid {
    return ([self validate] == 0);
}

-(NSArray *)getErrors {
    return [self.controlDelegate getErrors];
}

-(void)addErrors:(NSArray *)errors {
    [self.controlDelegate addErrors:errors];
}

-(void)clearErrors {
    [self.controlDelegate clearErrors];
}

-(void)showError:(BOOL)showError {
    [self.controlDelegate setIsValid:!showError];
}

-(void) onErrorButtonClick:(id)sender {
    [self.controlDelegate onErrorButtonClick:sender];
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void)setUseCustomBackgroundView_MDK:(BOOL)useCustomBackgroundView_MDK {
    _useCustomBackgroundView_MDK = useCustomBackgroundView_MDK;
    if(_useCustomBackgroundView_MDK) {
        [self.styleClass performSelector:@selector(displayBackgroundViewOnComponent:) withObject:self];
    }
    else {
        [self.styleClass performSelector:@selector(removeBackgroundViewOnComponent:) withObject:self];
    }
}
#pragma clang diagnostic pop


-(void)setVisible:(NSNumber *)visible {
    _visible = visible;
    [self.controlDelegate setVisible:visible];
}

-(void)setControlAttributes:(NSDictionary *)controlAttributes {
    _controlAttributes = controlAttributes;
    self.mandatory = controlAttributes[@"mandatory"] ? controlAttributes[@"mandatory"] : @1;
    if(self.associatedLabel) {
        self.associatedLabel.mandatory = self.mandatory;
    }
    self.editable = controlAttributes[@"editable"] ? controlAttributes[@"editable"] : @1;
    self.visible = controlAttributes[@"visible"] ? controlAttributes[@"visible"] : @1;
}

-(void)setMandatory:(NSNumber *)mandatory {
    _mandatory = mandatory;
    if(self.associatedLabel) {
        self.associatedLabel.mandatory = _mandatory;
    }
}


-(void)setAssociatedLabel:(MFLabel *)associatedLabel {
    _associatedLabel = associatedLabel;
    self.associatedLabel.mandatory = self.mandatory;
}

-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    if(![self isEqual:target]) {
        MFControlChangedTargetDescriptor *commonCCTD = [MFControlChangedTargetDescriptor new];
        commonCCTD.target = target;
        commonCCTD.action = action;
        self.targetDescriptors = @{@(self.hash) : commonCCTD};
    }
    else {
        [super addTarget:target action:action forControlEvents:controlEvents];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(void) valueChanged:(UIView *)sender {
    if([self.controlDelegate validate] == 0) {
        MFControlChangedTargetDescriptor *cctd = self.targetDescriptors[@(sender.hash)];
        [cctd.target performSelector:cctd.action withObject:self];
    }
}
#pragma clang diagnostic pop


-(NSArray *)controlValidators {
    return @[];
}

-(NSInteger)validate {
    return [self.controlDelegate validate];
}

-(void)addControlAttribute:(id)controlAttribute forKey:(NSString *)key {
    [self.controlDelegate addControlAttribute:controlAttribute forKey:key];
}


@end
