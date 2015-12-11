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


#import "MFTextView.h"

#define HEIGHT_WHEN_KEYBOARD 60

@interface MFTextView()

@property (nonatomic, strong) NSDate *date;

@property (nonatomic) CGFloat keyboardHeight;

@property (nonatomic) BOOL keyboardVisible;

@property (nonatomic, weak) UITableView *scrollingTableView;

@property (nonatomic) CGSize originalContentSize;

@property (nonatomic) CGRect originalFrame;

@property (nonatomic) CGPoint contentOffset;

@property (nonatomic, strong) UIToolbar *keyboardToolBar;

@property (nonatomic) CGFloat hauteurInitiale;

@end

@implementation MFTextView
@synthesize currentOrientation = _currentOrientation;
@synthesize mandatory = _mandatory;
@synthesize textView = _textView;
@synthesize targetDescriptors = _targetDescriptors;
@synthesize isValid = _isValid;
@synthesize tooltipView= _tooltipView;
@synthesize errors = _errors;
@synthesize controlAttributes = _controlAttributes;
@synthesize editable = _editable;
@synthesize visible = _visible;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)initialize {
    
    
    
    self.textView = [[UITextView alloc] init];
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textView.delegate = self;
    self.textView.userInteractionEnabled = YES;
    self.textView.keyboardType = UIKeyboardTypeDefault;
    
    self.isValid = YES;
    
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self registerOrientationChange];
    
    //On créé la barre de boutons personnalisée pour l'ajouter au clavier
    //Cette barre contiendra, pour l'iPhone seulement, le bouton "OK" qui permet de masquer le clavier
    //une fois la saisie effectuée.
    //En effet, le bouton "retour" est utilisé pour insérer un retour à la ligne
    //dans la text view et le clavier iPhone ne dispose pas de bouton supplémentaire
    //pour masquer le clavier.
    //Elle contiendra également, sur iPhone et iPad, un bouton pour effacer le contenu de la textview.
    //En effet, un UITextView ne propose pas de bouton déjà prêt pour effacer son contenu.
    self.keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                       0.0f,
                                                                       self.frame.size.width,
                                                                       44.0f)];
    
    
    self.keyboardToolBar.tintColor = [UIColor colorWithRed:0.56f
                                                     green:0.59f
                                                      blue:0.63f
                                                     alpha:1.0f];
    
    self.keyboardToolBar.translucent = NO;
    
    UIBarButtonItem *okButton = [[UIBarButtonItem alloc] initWithTitle:MFLocalizedStringFromKey(@"okButton")
                                                         style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(barButtonDismissKeyboard:)];
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:MFLocalizedStringFromKey(@"clearButton")
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(barButtonClearText:)];
    
    
    //Pour l'Ipad, le bouton d'effacement suffit
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    
        
        
        self.keyboardToolBar.items =   @[clearButton,
                                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:nil]];
        
    //Sinon, il faut les deux boutons
    } else {
        
        self.keyboardToolBar.items =   @[clearButton,
                                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:nil
                                                                                       action:nil],
                                         okButton];

    }

    
    //Le textview est ajouté au composant
    self.textView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.textView];
    [super initialize];

}

/**
 * @brief Cette méthode permet d'écouter chaque modification
 *
 */

- (void)textViewDidChange:(UITextView *)textView {
    
    
    //Correction d'un bug sur iOS 7 : la text view ne scroll pas jusqu'à la dernière ligne lorsqu'on insère
    //une nouvelle ligne et que la hauteur du bloc de texte dépasse la hauteur de la zone de saisie (le texte qui est
    //rédigé n'est alors pas visible).
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
    
    
    [self valueChanged:textView];
}



/**
 * @brief Méthode appelée lors du clic sur le bouton pour effacer tout le texte associé au clavier
 *
 */

-(IBAction)barButtonClearText:(UIBarButtonItem*)sender
{
    if ([self.textView isFirstResponder]) {
        //Le texte est supprimé
        self.textView.text = @"";
        //Mise à jour du view modèle car la méthode de delegate textViewDidChange n'est pas appelée lorsque la valeur du texte
        //est modifiée programmaticallement
    }
}


/**
 * @brief Méthode appelée lors du clic sur le bouton "OK" associé au clavier
 *
 */

-(IBAction)barButtonDismissKeyboard:(UIBarButtonItem*)sender
{
    if ([self.textView isFirstResponder]) {
        //Le clavier est masqué
        [self.textView endEditing:YES];
    }
}


-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat errorButtonSize = ERROR_BUTTON_SIZE;

    self.textView.frame = CGRectMake(self.bounds.origin.x + errorButtonSize,
                                      self.bounds.origin.y,
                                      self.bounds.size.width - 4 - errorButtonSize,
                                      self.bounds.size.height);
    // we love the delegate after
    self.textView.delegate = self;
    
}




#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.textView.tag == 0) {
        [self.textView setTag:TAG_MFTEXTVIEW_TEXTVIEW];
    }
}



#pragma mark - Fast Forwarding
//-(id)forwardingTargetForSelector:(SEL)sel {
//    return self.textView;
//}

#pragma mark - KVC magic forwarding
-(id)valueForUndefinedKey:(NSString *)key {
    if(![key isEqualToString:@"mf."])
    {
        return [self.textView valueForKey:key];
    }
    else {
        return [[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_KEYNOTFOUND];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    [self.textView setValue:value forKey:key];
}

#pragma mark - Delegate
-(void)setDelegate:(id<UITextViewDelegate>)delegate {
    self.textView.delegate = delegate;
}

-(id<UITextViewDelegate>)delegate {
    return self.textView.delegate;
}


-(void) setValue:(NSString *) value{
    self.textView.text = value;
    [self validate];
}

-(NSString *) getValue{
    return self.textView.text;
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
    return self.textView.editable;
}

-(void) setIsActive:(BOOL)isActive{
    self.textView.editable = isActive;
}

#pragma mark - Validation
-(void)setIsValid:(BOOL) isValid {
    [self.controlDelegate setIsValid:isValid];
}

-(BOOL) isValid {
    return ([self validate] == 0);
}

-(NSArray *)controlValidators {
    return @[];
}

- (NSInteger)validate {
    return [self.controlDelegate validate];
}

#pragma mark - Errors
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

-(void)onMessageButtonClick:(id)sender {
    [self.controlDelegate onMessageButtonClick:sender];
}



#pragma mark - Control attributes
-(void)setControlAttributes:(NSDictionary *)controlAttributes {
    _controlAttributes = controlAttributes;
    self.mandatory = controlAttributes[@"mandatory"] ? controlAttributes[@"mandatory"] : @1;
    if(self.associatedLabel) {
        self.associatedLabel.mandatory = self.mandatory;
    }
    self.editable = controlAttributes[@"editable"] ? controlAttributes[@"editable"] : @1;
    self.visible = controlAttributes[@"visible"] ? controlAttributes[@"visible"] : @1;
}

-(void)addControlAttribute:(id)controlAttribute forKey:(NSString *)key {
    [self.controlDelegate addControlAttribute:controlAttribute forKey:key];
}


#pragma mark - Properties
-(void)setMandatory:(NSNumber *)mandatory {
    _mandatory = mandatory;
    if(self.associatedLabel) {
        self.associatedLabel.mandatory = _mandatory;
    }
}
//-(void)setEditable:(NSNumber *)editable {
//    _editable = editable;
//    self.userInteractionEnabled = [editable boolValue];
//    [self applyStandardStyle];
//}

-(void)setVisible:(NSNumber *)visible {
    _visible = visible;
    [self.controlDelegate setVisible:visible];
}


#pragma mark - Specific TextField method implementation

-(void) setKeyboardType:(UIKeyboardType) type
{
    [self.textView setKeyboardType:type];
}

#pragma mark - UITextView Delegate

/**
 * @brief define the field to move to in the table when the keyboard hide a part of table
 */
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    MFUILogVerbose(@"componentInCellAtIndexPath row section %ld %ld", (long)self.componentInCellAtIndexPath.row ,  (long)self.componentInCellAtIndexPath.section );
}

/**
 * @brief cancel the move of table
 */
- (void)textFieldDidEndEditing:(UITextView *)textField
{
}

#pragma mark - Descriptor


-(NSString *) description
{
    return [NSString stringWithFormat:@"MFTextView<value:%@, active: %c, mf.mandatory: %@, mf.maxLength: %@, mf.minLength: %@>", [self getValue], self.isActive ?  : NO, self.mandatory ? @"YES" : @"NO", self.mf.maxLength, self.mf.minLength];
}



#pragma mark - Scrolling


-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
    self.textView.editable = ([editable isEqualToNumber:@1]) ? YES : NO;
    //La barre de boutons personnalisée est ajoutée au clavier si le composant est éditable
    //Cela permet d'éviter l'apparition de la barre de boutons seule dans le cas où le composant
    //n'est pas éditable mais qu'on double clique sur le texte.
    self.textView.inputAccessoryView = ([editable isEqualToNumber:@1]) ? self.keyboardToolBar : nil;
    [self applyStandardStyle];
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

-(void)unregisterOrientationChange {
    [self.orientationChangedDelegate unregisterOrientationChanges];
}

-(void)dealloc {
    
    //QLA : Le delegate d'orientation ne suffit pas (sans savoir pourquoi) pour faire le removeObserver.
    [self.orientationChangedDelegate unregisterOrientationChanges];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Value Changed targets

-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    MFControlChangedTargetDescriptor *commonCCTD = [MFControlChangedTargetDescriptor new];
    commonCCTD.target = target;
    commonCCTD.action = action;
    self.targetDescriptors = @{@(self.textView.hash) : commonCCTD};
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
    [self addSubview:innerDescriptionLabel];
    self.backgroundColor = [UIColor colorWithRed:0.98f green:0.88f blue:0.82f alpha:1.0f];
    
}

@end

