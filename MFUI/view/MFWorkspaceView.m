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
//  MFWorkspaceView.m
//  Pods
//
//
//

#import "MFWorkspaceView.h"
#import "MFWorkspaceViewController.h"
#import "MFPickerList.h"
#import "MFUILog.h"

#define POR_COLUMN_NUMBER 1
#define PAY_COLUMN_NUMBER 2
#define POR_IDAP_COLUMN_NUMBER 2
#define PAY_IDAP_COLUMN_NUMBER 4


@interface MFWorkspaceView ()

/**
 * @brief The dictionary that contains references of the columns of the workspace
 */
@property (nonatomic, strong) NSMutableDictionary *columnsReferencesDictionary;

/**
 * @brief The constraint that specifies the width of the container
 */
@property (nonatomic, strong) NSLayoutConstraint *containerWidth;

/**
 * @brief The identifier of the master column
 */
@property (nonatomic, strong) NSString *masterIdentifier;

@end

NSString *const WORKSPACE_VIEW_DID_SCROLL_NOTIFICATION_KEY = @"workspaceViewDidScroll";


@implementation MFWorkspaceView
@synthesize currentOrientation = _currentOrientation;
@synthesize defaultConstraints = _defaultConstraints;
@synthesize savedConstraints = _savedConstraints;


#pragma mark - Initialization

-(id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}


- (void) initialize
{
    self.pagingEnabled = YES;
    self.delegate = self;
    [self registerOrientationChange];
    
    self.containerView = [[UIView alloc] init];
    [self.containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.containerView];
    
    self.showsHorizontalScrollIndicator = YES;
    [self setBounces:NO];
    
    [self applyDefaultConstraints];
}

-(void)applyDefaultConstraints {
    
    NSMutableDictionary *viewsDictionary = [[NSMutableDictionary alloc] init];
    [viewsDictionary setObject:self.containerView forKey:@"containerView"];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[containerView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[containerView]|" options:0 metrics: 0 views:viewsDictionary]];
    
}

-(void)dealloc {
    //QLA : Le delegate d'orientation ne suffit pas (sans savoir pourquoi) pour faire le removeObserver.
    [self.orientationChangedDelegate unregisterOrientationChanges];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Custom Methods

- (void) addColumnFromSegue:(MFWorkspaceColumnSegue *)columnSegue
{
    NSString *columnName = columnSegue.identifier;
    
    //Initialisation du dictionnaire des références des colonnes.
    if(!self.columnsReferencesDictionary) {
        self.columnsReferencesDictionary = [NSMutableDictionary dictionary];
    }
    
    // getView and add to ViewRefs
    UIView *columnView = ((UIViewController *)columnSegue.destinationViewController).view;
    [columnView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.columnsReferencesDictionary setObject:columnView forKey:columnName];
    
    // add dest VC View to container
    [self.containerView addSubview:columnView];
    
    // constraint on column
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[%@]|", columnSegue.identifier] options:0 metrics:0 views:self.columnsReferencesDictionary]];
    
    // donne la taille tu contener
    [self columnFactorSize];
    
}


-(void) columnFactorSize
{
    NSUInteger numberOfColumn = [self.columnsReferencesDictionary count];
    
    //    ceil(1.0001) // 2
    
    MFUILogVerbose(@"current scroll : %f", (self.contentOffset.x / self.frame.size.width));
    
    // positionnement du scroll sur une page entiere
    float floatPage = self.contentOffset.x/self.frame.size.width;
    if ( floatPage != floor(floatPage) ) {
        self.contentOffset = CGPointMake( self.frame.size.width * ceil(floatPage) , self.contentOffset.y );
    }
    
    MFUILogVerbose(@"Number of Columns = %lu", (unsigned long)numberOfColumn);
    
    // varient suivant l'orientation, les preferences, ...
    float numberOfColumnToDisplay = 1;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            numberOfColumnToDisplay = POR_IDAP_COLUMN_NUMBER;
        } else {
            numberOfColumnToDisplay = POR_COLUMN_NUMBER;
        }
        
    } else {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            numberOfColumnToDisplay = PAY_IDAP_COLUMN_NUMBER;
        } else {
            numberOfColumnToDisplay = PAY_COLUMN_NUMBER;
        }
    }
    
    if (numberOfColumnToDisplay > numberOfColumn) {
        numberOfColumnToDisplay = numberOfColumn;
    }
    
    MFUILogVerbose(@"factor to apply to container = %f", numberOfColumn/numberOfColumnToDisplay);
    
    [self dimn:(numberOfColumn/numberOfColumnToDisplay) and:0];
}

-(void) dimn:(float) n and:(int) k {
    if (self.containerWidth) [self removeConstraint:self.containerWidth];
    
    // avec n un nombre > 1 mais pas forcement entier
    self.containerWidth = [NSLayoutConstraint  constraintWithItem:self.containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:n constant:k];
    [self addConstraint:self.containerWidth];
}

-(void) refreshViewFromSegues:(NSArray *)columnSegues {
    NSString *columnsFormat = @"H:|";
    for( UIStoryboardSegue *columnSegue in columnSegues) {
        
        NSString *columnName = columnSegue.identifier;
        if([columnSegue.destinationViewController conformsToProtocol:@protocol(MFWorkspaceMasterColumnProtocol)]) {
            self.masterIdentifier = columnName;
        }
        
        columnsFormat = [columnsFormat stringByAppendingString:[NSString stringWithFormat:@"[%@]", columnName]];
        
        [self addConstraint:[NSLayoutConstraint  constraintWithItem:[self.columnsReferencesDictionary objectForKey:columnName] attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint  constraintWithItem:[self.columnsReferencesDictionary objectForKey:columnName] attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeWidth multiplier:(1.0f/[self.columnsReferencesDictionary count]) constant:0]];
        
    }
    columnsFormat = [columnsFormat stringByAppendingString:@"|"];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:columnsFormat options:0 metrics:0 views:self.columnsReferencesDictionary]];
    
}



#pragma mark -  MFOrientationChangedDelegate

-(void) orientationDidChanged:(NSNotification *)notification {
    
    MFUILogVerbose(@"orientation changed");
    
    if(self.orientationChangedDelegate && [self.orientationChangedDelegate checkIfOrientationChangeIsAScreenNormalRotation]) {
        [self columnFactorSize];
    }
    self.currentOrientation = [[UIDevice currentDevice] orientation];
}

-(void) registerOrientationChange {
    self.currentOrientation = [[UIDevice currentDevice] orientation];
    self.orientationChangedDelegate = [[MFOrientationChangedDelegate alloc] initWithListener:self];
    [self.orientationChangedDelegate registerOrientationChanges];
}

#pragma mark - Visual workspace management

-(void) scrollToMasterColumn {
    CGRect frame = self.frame;
    frame.origin.x = frame.size.width * 0;
    frame.origin.y = 0;
    [self scrollRectToVisible:frame animated:YES];

}

-(void) scrollToDetailColumnWithIndex:(int)index {
    CGRect frame = self.frame;
    frame.origin.x = frame.size.width * index;
    frame.origin.y = 0;
    [self flashScrollIndicators];
    [self scrollRectToVisible:frame animated:YES];
}

-(BOOL) isColumnWithNameVisible:(NSString *)columnName{
    UIView *requestedColumnView = (UIView*)[self.columnsReferencesDictionary objectForKey:columnName];
    if(CGRectContainsPoint(requestedColumnView.frame, self.contentOffset)) {
        return YES;
    }
    return NO;
}

-(BOOL) isMasterColumnVisible {
    if(self.masterIdentifier) {
        return [self isColumnWithNameVisible:self.masterIdentifier];
    }
    return NO;
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:WORKSPACE_VIEW_DID_SCROLL_NOTIFICATION_KEY object:nil userInfo:nil];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hideAnyModalInput];
}

// Avoid conflits with the sliding Menu
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gesture shouldReceiveTouch:(UITouch *)touch {
    float originX = [touch locationInView:self].x;
    return (originX > 20);
}

/**
 * @brief Permet de cacher toute fenêtre modale qui permet de saisir une valeur (clavier, picker...)
 */
-(void) hideAnyModalInput {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_NOTIFICATION_FORCE_HIDE object:nil userInfo:nil];
}

#pragma mark - Memory management
-(void) unregisterColumnsReferences {
    [self.columnsReferencesDictionary removeAllObjects];
    self.columnsReferencesDictionary = nil;
}



@end
