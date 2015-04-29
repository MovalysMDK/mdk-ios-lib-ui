//
//  MFLabel.m
//  MFUI
//
//  Created by Quentin Lagarde on 28/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//


@import MFCore.MFBeansKeys;

#import "MFLabel.h"
#import "MFLabelStyle.h"
#import "MFKeyNotFound.h"
#import "MFUIError.h"
#import "MFConfigurationHandler.h"
#import "MFLocalizedString.h"


@interface MFLabel ()


/**
 * @brief Cette propriété permet de personnaliser le texte de la mension "obligatoire"
 */
@property (nonatomic, strong) NSString *mandatoryIndicator;

@end

@implementation MFLabel
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

NSString * const MF_MANDATORY_INDICATOR = @"MandatoryIndicator";

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
    [self.styleClass applyStandardStyleOnComponent:self];
    self.errors = [NSMutableArray new];
    if(!self.sender) {
        self.sender = self;
    }
    MFConfigurationHandler *registry = [[MFApplication getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER];
    self.mandatoryIndicator = [registry getStringProperty:MF_MANDATORY_INDICATOR];
    self.backgroundColor = [UIColor clearColor];
}


-(void)setIsValid:(BOOL) isValid {
    [self.bindingDelegate setIsValid:isValid];
}


#pragma mark - MDK

-(void)setCustomStyleClass:(Class)customStyleClass {
    _customStyleClass = customStyleClass;
    self.styleClass = [customStyleClass new];
}

- (void)setI18nKey:(NSString *) defaultValue {
    [self setData:defaultValue];
}

-(void)didLoadFieldDescriptor:(MFFieldDescriptor *)fieldDescriptor {
    _selfDescriptor = fieldDescriptor;
}

-(id<MFStyleProtocol>)styleClass {
    if(!_styleClass) {
        _styleClass = self.customStyleClass ? [self.customStyleClass new] : [NSClassFromString([NSString stringWithFormat:@"%@Style", self.class] ) new];
    }
    return _styleClass;
}

+(NSString *)getDataType {
    return @"NSString";
}


-(void)setData:(id)data {
    NSString *fixedData = nil;
    if(data && ![data isKindOfClass:[MFKeyNotFound class]]) {
        fixedData = data;
    }
    else {
        NSString *defaultValue = self.selfDescriptor.name;
        if(((MFFieldDescriptor *)self.selfDescriptor).i18nKey) {
            defaultValue = MFLocalizedStringFromKey(((MFFieldDescriptor *)self.selfDescriptor).i18nKey);
        }
        fixedData = defaultValue;
    }
    fixedData = [self insertOrRemoveMandatoryIndicator:fixedData];
    [self setDisplayComponentValue:fixedData];
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
    
    [self.errors removeAllObjects];
    if(parameters) {
        // Do some treatments with specific
    }
    NSInteger length = [[self displayComponentValue] length];
    NSError *error = nil;
    // Control's errros init or reinit
    NSInteger nbOfErrors = 0;
    

    
    return nbOfErrors;
    
}

-(void)setEditable:(NSNumber *)editable {
    _editable = editable;
    self.userInteractionEnabled = [editable boolValue];
}

-(NSString *) insertOrRemoveMandatoryIndicator:(NSString *)data {
    //Vérification de l'état actuel du label (mandatory affiché ou non) et mise à jour du contenu du label
    if([self.mandatory isEqual: @1] && [data rangeOfString:self.mandatoryIndicator].location == NSNotFound) {
        data = [data stringByAppendingString:[NSString stringWithFormat:@" %@",self.mandatoryIndicator]];
    }
    else if ([self.mandatory isEqual: @0] && [self  .text rangeOfString:self.mandatoryIndicator].location != NSNotFound ) {
        data = [data stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@",self.mandatoryIndicator] withString:@""];
    }
    return data;
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
    [self.styleClass applyStandardStyleOnComponent:self];
    
    if(self.onError_MDK) {
        [self.styleClass applyErrorStyleOnComponent:self];
    }
    else {
        [self.styleClass applyValidStyleOnComponent:self];
    }
}

@end
