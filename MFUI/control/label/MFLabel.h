//
//  MFLabel.h
//  MFUI
//
//  Created by Quentin Lagarde on 28/04/2015.
//  Copyright (c) 2015 Lagarde Quentin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFStyleProtocol.h"
#import "MFUIComponentProtocol.h"


FOUNDATION_EXPORT NSString * const MF_MANDATORY_INDICATOR;

IB_DESIGNABLE
@interface MFLabel : UILabel <MFUIComponentProtocol>

#pragma mark - Properties

@property (nonatomic) IBInspectable BOOL onError_MDK;

@property (nonatomic) Class customStyleClass;

@property (nonatomic, strong) NSMutableArray *errors;


@property (nonatomic, strong) id<MFUIComponentProtocol> sender;


#pragma mark - Methods
-(void)setIsValid:(BOOL) isValid;

/**
 * @brief A method that is called at the initialization of the component
 * to do some treatments.
 */
-(void) initializeComponent;


/**
 * @brief This method allows to add some views to the TextField
 * @param accessoryViews A dictionary that contains key/value pairs as follow :
 * key is a NSString  custom identifier object that correspond to a
 * UIView accessory view value to add to the component.
 * @discussion The key NSString-typed identifiers should be defined
 * in a MDK style class (that implements MFStyleProtocol).
 * @see MFStyleProtocol
 */
-(void) addAccessories:(NSDictionary *) accessoryViews;


-(void) onErrorButtonClick:(id)sender;

-(void) setSender:(id<MFUIComponentProtocol>)sender ;

@end
