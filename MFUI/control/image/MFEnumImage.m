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

#import <MFCore/MFCoreI18n.h>

#import "MFEnumImage.h"
#import "MFCellAbstract.h"

#import "MFUILogging.h"

#pragma mark - Define some constants
#define PICKER_TOP_BAR_HEIGHT  40.f
#define PICKER_SEARCH_BAR_HEIGHT 40.f

#define PICKER_TOP_BAR_ITEMS_MARGIN  7.f
#define PICKER_TOP_BAR_ITEMS_HEIGHT  30.f

#define PICKER_TOP_BAR_CANCEL_WIDTH  75.f
#define PICKER_TOP_BAR_CONFIRM_WIDTH 50.f

#define PICKER_LIST_HEIGHT 164.f

NSString *const ENUMIMAGE_PARAMETER_ENUM_CLASS_NAME_KEY = @"enumClassName";


@interface MFEnumImage()

/**
 * @brief The view of the main form controller of this component
 */
@property (nonatomic, strong) UIView *mainFormControllerView;

/**
 * @brief The popover window to display the PickerList on iPad
 */
@property (nonatomic, strong) UIPopoverController *popoverController;

@end

@implementation MFEnumImage
@synthesize localizedFieldDisplayName = _localizedFieldDisplayName;
@synthesize transitionDelegate = _transitionDelegate;
@synthesize selfDescriptor = _selfDescriptor;
@synthesize isValid = _isValid;
@synthesize form = _form;
@synthesize componentInCellAtIndexPath =_componentInCellAtIndexPath;
@synthesize data =_data;
@synthesize currentOrientation = _currentOrientation;


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
    [super initialize];
    self.backgroundColor = [UIColor clearColor];
    self.imageView = [[UIImageView alloc] init];
    self.label = [[UILabel alloc] init];
    
    
    NSLayoutConstraint *imageViewTop = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *imageViewLeft = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *imageViewBottom = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *imageViewRight = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self addConstraints:@[imageViewBottom, imageViewLeft, imageViewRight, imageViewTop]];
    
    
    NSLayoutConstraint *labelTop = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *labelLeft = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *labelBottom = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *labelRight = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self addConstraints:@[labelTop, labelLeft, labelBottom, labelRight]];

    [self addSubview:self.imageView];
    [self addSubview:self.label];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self registerOrientationChange];
}

#pragma mark - Class lifecycle


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
    if (self.imageView.tag == 0) {
        [self.imageView setTag:TAG_MFENUMIMAGE_IMAGEVIEW];
    }
}



#pragma mark -  MFOrieentationChangedDelegate

-(void)orientationDidChanged:(NSNotification *)notification {
    if(self.orientationChangedDelegate && [self.orientationChangedDelegate checkIfOrientationChangeIsAScreenNormalRotation]) {
        
        // Au changement d'orientation, on effectue à nouveau le rendu de l'enum car la dimension du composant à changée
        NSString *sEnumClassName = nil;
        //PROTODO : au dessus, retrouver nom enum ENUMIMAGE_PARAMETER_ENUM_CLASS_NAME_KEY
        
        
        NSString *sEnumClassHelperName = [MFHelperType getClassHelperOfClassWithKey:sEnumClassName]; // Nom de la classe Helper de l'Enum
        Class cEnumHelper = NSClassFromString(sEnumClassHelperName); // Classe Helper de l'Enum
        NSNumber *nsnEnum = (NSNumber *)_data; // Conversion objet pour utilisation avec @selector
        NSString *sEnumText = [cEnumHelper performSelector:@selector(textFromEnum:) withObject:nsnEnum]; // Texte de l'Enum
        
        [self renderEnumFromText:sEnumText];

    }
    self.currentOrientation = [[UIDevice currentDevice] orientation];
}

-(void)registerOrientationChange {
    self.currentOrientation = [[UIDevice currentDevice] orientation];
    self.orientationChangedDelegate = [[MFOrientationChangedDelegate alloc] initWithListener:self];
    [self.orientationChangedDelegate registerOrientationChanges];
}



#pragma mark - MFUIComponentProtocol base methods

+(NSString *) getDataType {
    return @"NSNumber";
}

-(void)setData:(id)data {
    _data = data;
    
    NSString *sEnumClassName = nil;
    //PROTODO : idem mais essayer de centraliser
    
    
    NSString *sEnumClassHelperName = [MFHelperType getClassHelperOfClassWithKey:sEnumClassName]; // Nom de la classe Helper de l'Enum
    Class cEnumHelper = NSClassFromString(sEnumClassHelperName); // Classe Helper de l'Enum
    NSNumber *nsnEnum = data; // Conversion objet pour utilisation avec @selector
    NSString *sEnumText = [cEnumHelper performSelector:@selector(textFromEnum:) withObject:nsnEnum]; // Texte de l'Enum

    [self renderEnumFromText:sEnumText];
}

-(id)getData {
    return self.data;
}



-(void)setEditable:(NSNumber *)editable {
    [super setEditable:editable];
}


#pragma mark - Custom method for class

-(void) renderEnumFromText:(NSString *)sText {
    
    // Tente de charger l'image à partir du fichier
    NSString *sEnumClassName = nil;
    
    //PROTODO : idem
    
    NSString *sImageName = [[NSString stringWithFormat:@"enum_%@_%@", sEnumClassName, sText] lowercaseString];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateDisplayFromImageName:sImageName];
    });

}

-(void) updateDisplayFromImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.hidden = (image == nil);
    self.label.hidden = (image != nil);
    
    if(image) {
        self.imageView.image = image;
    }
    else {
        self.label.text = [[imageName componentsSeparatedByString:@"_"] objectAtIndex:2];
    }
}

@end
