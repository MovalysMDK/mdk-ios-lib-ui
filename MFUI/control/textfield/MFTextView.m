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
//  MFTextView.m
//  MFUI
//
//

#import "MFTextView.h"

#define HEIGHT_WHEN_KEYBOARD 60

@interface MFTextView()

@property (nonatomic, strong) NSDate *date;

@property (nonatomic) BOOL hasACustomColor;

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

@synthesize textView = _textView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)initialize {
    [super initialize];
    
    
    
    self.textView = [[UITextView alloc] init];
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textView.delegate = self;
    self.textView.userInteractionEnabled = YES;
    self.hasFocus = NO;
    self.hasACustomColor = NO;
    self.textView.keyboardType = UIKeyboardTypeDefault;
    
    self.applicationContext = [MFApplication getInstance];
    self.isValid = YES;
    self.mf = [self.applicationContext getBeanWithKey:BEAN_KEY_EXTENSION_KEYBOARDING_UI_CONTROL];
    
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

    
    //Gestion du déplacement lors de l'apparition/disparition du clavier
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (keyboardDidHide:)
                                                 name: UIKeyboardDidHideNotification
                                               object:nil];
    
    //L'ajout de la toolbar est géré au niveau du setter de l'attribut editable.
    
    //Le textview est ajouté au composant
    [self addSubview:self.textView];

}

/**
 * @brief Cette méthode permet d'écouter chaque modification
 *
 */

- (void)textViewDidChange:(UITextView *)textView {
    
    [self updateValue];
    
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
        [self updateValue];
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


-(void) updateValue {
    [self.sender performSelectorOnMainThread: @selector(updateValue:) withObject:self.textView.text waitUntilDone:YES];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat errorButtonSize = ERROR_BUTTON_SIZE;
    if(self.isValid) {
        errorButtonSize = 0;
    }
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
-(id)forwardingTargetForSelector:(SEL)sel {
    return self.textView;
}

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
    if(self.mandatory != nil && [self.mandatory integerValue] == 1 && [self getValue].length == 0){
        error = [[MFMandatoryFieldUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:self.selfDescriptor.name];
        [self addErrors:@[error]];
        [self.context addErrors:@[error]];
        nbOfErrors++;
    }
    
    return nbOfErrors;
}

-(void) setValue:(NSString *) value{
    
    self.textView.text = value;
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
    [self setHasFocus:YES];
}

/**
 * @brief cancel the move of table
 */
- (void)textFieldDidEndEditing:(UITextView *)textField
{
    [self setHasFocus:NO];
}

#pragma mark - Descriptor


-(void) setSelfDescriptor:(NSObject<MFDescriptorCommonProtocol> *)selfDescriptor
{
    [super setSelfDescriptor:selfDescriptor];
}


-(NSString *) description
{
    return [NSString stringWithFormat:@"MFTextView<value:%@, active: %c, mf.mandatory: %@, mf.maxLength: %@, mf.minLength: %@>", [self getValue], self.isActive ?  : NO, self.mandatory ? @"YES" : @"NO", self.mf.maxLength, self.mf.minLength];
}

-(void)setMandatory:(NSNumber *)mandatory {
    self.mandatory = mandatory ;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    //    self.hasACustomColor = YES;
    //    self.privateBackgroundColor = backgroundColor;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.textView setBackgroundColor:backgroundColor];;
    });
    
}

-(void)setTextColor:(UIColor *)textColor {
    if(textColor) {
        [self.textView setTextColor:textColor];
    }
}


#pragma mark - Observers
-(void)keyboardWillShow:(NSNotification *)notification {
    if(self.scrollingTableView) {
        self.contentOffset = self.scrollingTableView.contentOffset;
    }

    self.keyboardHeight = MIN([[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height,
                              [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.width);

    [self scrollIfNeeded];
}



-(void)keyboardDidHide:(NSNotification *)notification {
    
    //Sur iPhone, en mode paysage : la textview reprend sa hauteur initiale quand le clavier disparait
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.hauteurInitiale);
    }
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
    
    int scrollMargin = 0;
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
        
        //Sur iPhone, en mode paysage : la textview est redimensionnée quand le clavier est affiché.
        //Cela permet d'éviter qu'elle soit déplacée et que la partie du haut ne soit plus visible
        //(dans le cas où l'utilisateur est en train de saisir du texte au début de la text view,
        //il ne verrait plus ce qu'il écrit et serait obliger de défiler vers le haut)
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            self.hauteurInitiale = self.frame.size.height;
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, HEIGHT_WHEN_KEYBOARD);
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
    self.textView.editable = ([editable isEqualToNumber:@1]) ? YES : NO;
    //La barre de boutons personnalisée est ajoutée au clavier si le composant est éditable
    //Cela permet d'éviter l'apparition de la barre de boutons seule dans le cas où le composant
    //n'est pas éditable mais qu'on double clique sur le texte.
    self.textView.inputAccessoryView = ([editable isEqualToNumber:@1]) ? self.keyboardToolBar : nil;
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


@end
