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
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MFBinding+Dispatcher.h"


@protocol MFObjectWithBindingProtocol;


/*!
 * @class AbstractControlWrapper
 * @brief Represents an abstract component wrapper.
 * @discussion The component wrapper is used by binding and ViewControllers to display and bind
 * some components.
 */
@interface MFAbstractControlWrapper : NSObject

#pragma mark - Properties

/*!
 * @brief The object with binding that own the component associated to this wrapper
 */
@property (nonatomic, weak) NSObject<MFObjectWithBindingProtocol> *objectWithBinding;

/*!
 * @brief The fictive indexPath to the component that is owned by this wrapper
 */
//FIXME: Pourquoi fictive
@property (nonatomic, strong) NSIndexPath *wrapperIndexPath;

/*!
 * @brief The component owned by this wrapper
 */
@property (nonatomic, weak, readonly) UIView *component;


#pragma mark - Initialization

/**
 * @brief Set the data of the component associated to this wrapper
 * @param data The data to set on the component
 */
-(void)setComponentValue:(id)value forKeyPath:(NSString *)keyPath;

/*!
 * @brief Initializes a new wrapper with a given component, and returns it to the caller
 * @param component The component associated to this wrapper
 * @return The new AbstractControlWrapper nuilt instance
 */
-(instancetype) initWithComponent:(UIView *)component;

/*!
 * @brief A dictionary that describes the values to return for some selectors of the component.
 * @discussion This method must be implemented in wrappers which the component main value will get a 
 * primitive type and not an object, like UISlider.
 * @return A dictionary that describes the value to return instead of nil for given selector of the component.
 */

//FIXME: refaire description pourquoi nil
-(NSDictionary *) nilValueBySelector;

/*!
 * @brief Dispatch to the view hold by the wrapper that its binded
 */
-(void) dispatchDidBinded;

@end
