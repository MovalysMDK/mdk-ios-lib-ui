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
//  MFSignature.m
//  MFUI
//
//

#import <MFCore/MFCoreI18n.h>

#import "MFSignature.h"
#import "MFSignatureHelper.h"
#import "MFSignatureDrawing.h"
#import "MFCellAbstract.h"
#import "MFVersionManager.h"
#import "MFMandatoryFieldUIValidationError.h"
#import "MFFormSearchViewController.h"

@interface MFSignature()

/**
 * @brief The popover window to display the Signature modal on iPad
 */
@property (nonatomic, strong) UIPopoverController *popoverController;

/**
 * @brief Indicates if the Signature modal view is currently displayed
 */
@property (nonatomic) BOOL isModalSignatureDrawingDisplayed;

/**
 * @brief The view of the main form controller of this component
 */
@property (nonatomic, strong) UIView *mainFormControllerView;

@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *clearButton;

@end

@implementation MFSignature
@synthesize data =_data;
@synthesize lineWidth = _lineWidth;
@synthesize strokeColor = _strokeColor;
@synthesize signaturePath = _signaturePath;
@synthesize targetDescriptors = _targetDescriptors;
#define SIGNATURE_DRAWING_WIDTH 240
#define SIGNATURE_DRAWING_HEIGHT 160


#pragma mark - Initializing


- (void) initialize {
#if !TARGET_INTERFACE_BUILDER
    [super initialize];

    _data = @"{}";
    _lineWidth = 3.0f;
    _strokeColor = [UIColor blackColor];
    
    self.isModalSignatureDrawingDisplayed = NO;
    
    
    CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                               SIGNATURE_DRAWING_WIDTH, SIGNATURE_DRAWING_HEIGHT);
    [self setFrame:frame];
    [self setBackgroundColor:[UIColor colorWithRed:242./255. green:242./255. blue:242./255. alpha:1.0]];
#endif
    
}


// Drawing has to be done here
- (void) drawRect:(CGRect)rect {
    
    // Get graphic context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Configure stroke style
    
    CGContextSetStrokeColorWithColor(context, _strokeColor.CGColor);
    CGContextSetLineWidth(context, _lineWidth);
    CGContextSetLineCap(context , kCGLineCapRound);
    
    // Draw lines
    for (NSValue *nsLine in _signaturePath) {
        struct Line couple;
        [nsLine getValue:&couple];
        [self drawLineFrom:couple.from to:couple.to context:context];
    }
    CGContextStrokePath(context);
}

- (void) drawLineFrom:(CGPoint)from to:(CGPoint)to context:(CGContextRef) context {
    CGContextMoveToPoint(context, from.x, from.y);  // Start at this point
    CGContextAddLineToPoint(context, to.x, to.y);   // Draw to this point
    [self.modalSignatureDrawingView updateConstraints];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   [[event allTouches] anyObject];
    
    //   if([self.editable isEqualToNumber:@1]) {
    [self displayModalSignatureDrawingView];
    //    }
    
}


- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                              SIGNATURE_DRAWING_WIDTH, SIGNATURE_DRAWING_HEIGHT);
    
    [self setFrame:frame];
    
    if([MFVersionManager isCurrentDeviceOfTypePhone]) {
        if (self.modalSignatureDrawingView) {
            frame = CGRectMake(self.mainFormControllerView.frame.origin.x,
                                                               self.mainFormControllerView.frame.size.height - SIGNATURE_DRAWING_HEIGHT - 50,
                                                               self.mainFormControllerView.frame.size.width,
                                                               SIGNATURE_DRAWING_HEIGHT + 50);
            
            [self.modalSignatureDrawingView setFrame:frame];
            
            frame = CGRectMake((self.mainFormControllerView.frame.size.width - SIGNATURE_DRAWING_WIDTH)/2,
                                40,
                                SIGNATURE_DRAWING_WIDTH,
                                SIGNATURE_DRAWING_HEIGHT);
            
            [self.signature setFrame:frame];
            
            frame = CGRectMake((self.mainFormControllerView.frame.size.width + SIGNATURE_DRAWING_WIDTH)/2 - 100, 0, 100.0, 30.0);
            [self.confirmButton setFrame:frame];
            frame = CGRectMake((self.mainFormControllerView.frame.size.width - SIGNATURE_DRAWING_WIDTH)/2, 0, 100.0, 30.0);
            [self.cancelButton setFrame:frame];
            frame = CGRectMake(self.mainFormControllerView.frame.size.width/2 - 50, 0, 100.0, 30.0);
            [self.clearButton setFrame:frame];
        } else {
          /*  frame = CGRectMake(self.mainFormControllerView.frame.origin.x,
                               self.mainFormControllerView.frame.size.height - SIGNATURE_DRAWING_HEIGHT - 50,
                               self.mainFormControllerView.frame.size.width,
                               SIGNATURE_DRAWING_HEIGHT + 50);
            [self.popoverController setFrame:];*/
        }
    }
    [self setNeedsDisplay];
}

#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.signature.tag == 0) {
        [self.signature setTag:TAG_MFSIGNATURE_SIGNATURE];
    }
    if (self.confirmButton.tag == 0) {
        [self.confirmButton setTag:TAG_MFSIGNATURE_CONFIRMBUTTON];
    }
    if (self.cancelButton.tag == 0) {
        [self.cancelButton setTag:TAG_MFSIGNATURE_CANCELBUTTON];
    }
    if (self.clearButton.tag == 0) {
        [self.clearButton setTag:TAG_MFSIGNATURE_CLEARBUTTON];
    }
}



- (void) displayModalSignatureDrawingView {
    if (self.isModalSignatureDrawingDisplayed) {
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
    
    self.modalSignatureDrawingView = [[UIView alloc] init];
    [self.modalSignatureDrawingView setBackgroundColor:[UIColor colorWithRed:215./255. green:218./255. blue:222./255. alpha:1.0]];
    
    //[self.modalSignatureDrawingView setOpaque:YES];
    
    CGRect signatureDrawingViewFrame = CGRectMake((self.mainFormControllerView.frame.size.width - SIGNATURE_DRAWING_WIDTH)/2,
                                                  40,
                                                  SIGNATURE_DRAWING_WIDTH,
                                                  SIGNATURE_DRAWING_HEIGHT);
    
    self.signature = [[MFSignatureDrawing alloc] init];
    [self.signature setBackgroundColor:[UIColor whiteColor]];
    [self.signature setFrame:signatureDrawingViewFrame];
    
    NSString *cancelTitle = [MFLocalizedString localizableStringFromKey:@"MFSignatureCancelButtonTitle"];
    NSString *okTitle     = [MFLocalizedString localizableStringFromKey:@"MFSignatureSaveButtonTitle"];
    NSString *clearTitle  = [MFLocalizedString localizableStringFromKey:@"MFSignatureClearButtonTitle"];
    
    // Init validate and cancel button
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.confirmButton setTitle:okTitle forState:UIControlStateNormal];
    self.confirmButton.frame = CGRectMake((self.mainFormControllerView.frame.size.width + SIGNATURE_DRAWING_WIDTH)/2 - 100, 0, 100.0, 30.0);
    [self.confirmButton addTarget:self action:@selector(dismissSignatureViewAndSave) forControlEvents:UIControlEventTouchDown];
    self.confirmButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
    self.cancelButton.frame = CGRectMake((self.mainFormControllerView.frame.size.width - SIGNATURE_DRAWING_WIDTH)/2, 0, 100.0, 30.0);
    [self.cancelButton addTarget:self action:@selector(dismissSignatureViewAndCancel) forControlEvents:UIControlEventTouchDown];
    self.cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    self.clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.clearButton setTitle:clearTitle forState:UIControlStateNormal];
    self.clearButton.frame = CGRectMake(self.mainFormControllerView.frame.size.width/2 - 50, 0, 100.0, 30.0);
    [self.clearButton addTarget:self action:@selector(clearSignatureView) forControlEvents:UIControlEventTouchDown];
    self.clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    
    // Fill in the modal view
    [self.modalSignatureDrawingView addSubview:self.signature];
    [self.modalSignatureDrawingView addSubview:self.cancelButton];
    [self.modalSignatureDrawingView addSubview:self.clearButton];
    [self.modalSignatureDrawingView addSubview:self.confirmButton];
    
   
    
    /*
    signatureConstraint =[NSLayoutConstraint
                          constraintWithItem:self.cancelButton
                          attribute:NSLayoutAttributeLeft
                          relatedBy:NSLayoutRelationEqual
                          toItem:self.modalSignatureDrawingView
                          attribute:NSLayoutAttributeLeft
                          multiplier:0.0
                          constant:10];
    [self.modalSignatureDrawingView addConstraint:signatureConstraint];*/
    
   
    self.signature.signaturePath = [MFSignatureHelper convertFromStringToLines:_data width:self.bounds.size.width originX:0 originY:0];
    
    
    
    if([MFVersionManager isCurrentDeviceOfTypePhone]) {
        
        CGRect modalSignatureDrawingViewFrame = CGRectMake(self.mainFormControllerView.frame.origin.x,
                                                           self.mainFormControllerView.frame.size.height - SIGNATURE_DRAWING_HEIGHT - 50,
                                                           self.mainFormControllerView.frame.size.width,
                                                           SIGNATURE_DRAWING_HEIGHT + 50);
        
        
        CGRect initialModalSignatureDrawingViewFrame = modalSignatureDrawingViewFrame;
        initialModalSignatureDrawingViewFrame.origin.y  = self.mainFormControllerView.frame.size.height;
        [self.modalSignatureDrawingView setFrame:initialModalSignatureDrawingViewFrame];
        
    /*    NSLayoutConstraint *signatureConstraint =[NSLayoutConstraint
                                                  constraintWithItem:self.signature
                                                  attribute:NSLayoutAttributeCenterX
                                                  relatedBy:NSLayoutRelationEqual
                                                  toItem:self.modalSignatureDrawingView
                                                  attribute:NSLayoutAttributeCenterX
                                                  multiplier:1.0
                                                  constant:0];
        [self.modalSignatureDrawingView addConstraint:signatureConstraint];
        
        signatureConstraint =[NSLayoutConstraint
                                                  constraintWithItem:self.signature
                                                  attribute:NSLayoutAttributeHeight
                                                  relatedBy:NSLayoutRelationEqual
                                                  toItem:self.modalSignatureDrawingView
                                                  attribute:NSLayoutAttributeHeight
                                                  multiplier:1
                                                  constant:0];
        [self.modalSignatureDrawingView addConstraint:signatureConstraint];
        
        signatureConstraint =[NSLayoutConstraint
                              constraintWithItem:self.signature
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.modalSignatureDrawingView
                              attribute:NSLayoutAttributeWidth
                              multiplier:1
                              constant:0];
        [self.modalSignatureDrawingView addConstraint:signatureConstraint];
        
        signatureConstraint =[NSLayoutConstraint
                              constraintWithItem:self.signature
                              attribute:NSLayoutAttributeCenterY
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.modalSignatureDrawingView
                              attribute:NSLayoutAttributeCenterY
                              multiplier:1.0
                              constant:0];
        [self.modalSignatureDrawingView addConstraint:signatureConstraint];
        
        [self.modalSignatureDrawingView updateConstraints]; */
        
        
        
        
        [self showModalSignatureDrawingViewInFrame:modalSignatureDrawingViewFrame inView:self.mainFormControllerView];
    } else {
     //   self.signature.signaturePath = [MFSignatureHelper convertFromStringToLines:_data width:500 originX:0 originY:0];
        
        UIViewController *vc = [[UIViewController alloc] init];
        [vc setView:self.modalSignatureDrawingView];
        [vc setPreferredContentSize:CGSizeMake(self.mainFormControllerView.frame.size.width,
                                                      self.bounds.size.height + 50)];
        
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
        UIViewController *parentForm = self.topParentViewController;
        //CGRect parentCellRect = [parentForm.tableView rectForRowAtIndexPath:self.componentInCellAtIndexPath];
        
        CGRect modalSignatureDrawingViewFrame = CGRectMake((self.mainFormControllerView.frame.size.width - SIGNATURE_DRAWING_WIDTH - 50)/2,
                                                           (self.mainFormControllerView.frame.size.height - SIGNATURE_DRAWING_HEIGHT - 50)/2,
                                                           SIGNATURE_DRAWING_WIDTH + 50,
                                                           SIGNATURE_DRAWING_HEIGHT + 50);
       
        [self.popoverController presentPopoverFromRect:modalSignatureDrawingViewFrame inView:parentForm.view permittedArrowDirections:0 animated:YES];
    }
}

// USER ACTIONS
- (void) dismissSignatureViewAndSave {
    [self setData:[MFSignatureHelper convertFromLinesToString:self.signature.signaturePath
                                                        width:self.signature.bounds.size.width
                                                      originX:0 originY:0]];
    [self hideModalSignatureDrawingView];
    [self valueChanged:self];
}

- (void) dismissSignatureViewAndCancel {
    [self hideModalSignatureDrawingView];
}

- (void) clearSignatureView {
    [self.signature clear];
}


// MODAL WIEW SHOW/HIDE
-(void) showModalSignatureDrawingViewInFrame:(CGRect)frame inView:(UIView *)view{
    [view addSubview:self.modalSignatureDrawingView];
    
    self.isModalSignatureDrawingDisplayed = YES;
   
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.modalSignatureDrawingView setFrame:frame];
    } completion:^(BOOL finished) {
        [self.modalSignatureDrawingView setHidden:NO];
    }];
}


- (void) hideModalSignatureDrawingView {
    if([MFVersionManager isCurrentDeviceOfTypePhone]) {
        self.isModalSignatureDrawingDisplayed = NO;
        CGRect currentFrame = self.modalSignatureDrawingView.frame;
        currentFrame.origin.y += currentFrame.size.height;
        [UIView animateWithDuration:0.25 animations:^{
            [self.modalSignatureDrawingView setFrame:currentFrame];
        } completion:^(BOOL finished) {
            [self.modalSignatureDrawingView setHidden:YES];
            [self.modalSignatureDrawingView removeFromSuperview];
        }];
    } else {
        if(self.popoverController && [self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:YES];
        }
    }
}




#pragma mark - MFUIComponentProtocol base methods

+(NSString *)getDataType {
    return @"NSString";
}

-(void)setData:(id)data {
    if (data) {
        _data = data;
    }
    
    _signaturePath = [MFSignatureHelper convertFromStringToLines:_data width:self.bounds.size.width originX:0 originY:0];
    [self setNeedsDisplay];
}

-(id)getData {
    return self.data;
}


//-(NSInteger)validateWithParameters:(NSDictionary *)parameters {
//    int numberOfErrors = [super validateWithParameters:parameters];
//    if([self.mandatory isEqualToNumber:@1] && [[self getData] isEqualToString:[MFSignatureHelper convertFromLinesToString:@[] width:1 originX:0 originY:0]]) {
//        MFMandatoryFieldUIValidationError *error = [[MFMandatoryFieldUIValidationError alloc] initWithLocalizedFieldName:self.localizedFieldDisplayName technicalFieldName:NSStringFromClass(self.class)];
//        [self addErrors:@[error]];
//        numberOfErrors++;
//    }
//    return numberOfErrors;
//}

#pragma mark - Value Changed targets

-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    MFControlChangedTargetDescriptor *commonCCTD = [MFControlChangedTargetDescriptor new];
    commonCCTD.target = target;
    commonCCTD.action = action;
    self.targetDescriptors = @{@(self.hash) : commonCCTD};
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
    self.backgroundColor = [UIColor colorWithRed:0.86f green:0.87f blue:0.65f alpha:1.0f];
    
}


@end
