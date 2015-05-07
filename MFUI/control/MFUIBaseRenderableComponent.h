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

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "UIView+Styleable.h"
#import "MFUIBaseComponent.h"


#pragma mark MFUIBaseRenderableComponent

/*!
 * @class MFBaseRenderableComponent
 * @brief This class represents a basic MDK iOS renderable component.
 * @discussion This class that inherits from MFUIBaseComponent treat only with
 * renderable and styleable attributes of the component.
 * @discussion It describes also our specific UI architecture of our components :
 * @discussion A MFBaseRenderableComponent can be :
 * @discussion 1. An "ExternalView" used as a container of the real component view
 * @discussion 2. An "InternalView" that represents the real component. The InternalView
 * is a property of an "ExternalView" and loads it from a given XIB file.
 * @discussion "ExternalView" and "InternalView" are specfied with the "MFInternalComponent"
 * and "MFExternalComponent" described below in this file.
 * @see MFExternalComponent
 * @see MFInternalComponent
 */
IB_DESIGNABLE
@interface MFUIBaseRenderableComponent : MFUIBaseComponent

#pragma mark - Base Inspectable Attributes
/*!
 * @brief The border color of the component
 */
@property (nonatomic, strong) IBInspectable UIColor *borderColor_MDK;

/*!
 * @brief The border width of the component
 */
@property (nonatomic) IBInspectable NSInteger borderWidth_MDK;

/*!
 * @brief The corner radius of the component
 */
@property (nonatomic) IBInspectable NSInteger cornerRadius_MDK;

/*!
 * @brief Indicates on InterfaceBuilder if the component should be displayed with error style or not.
 */
@property (nonatomic) IBInspectable BOOL onError_MDK;

/*!
 * @brief The background color of the error tooltip view
 */
@property (nonatomic, strong) IBInspectable UIColor *tooltipColor_MDK;



#pragma mark - Properties
/*!
 * @brief The InternalView that this component should contain.
 * @discussion A MFBaseRenderableComponent can be :
 * @discussion 1. An external view that contains an internal view loaded from a XIB file
 * @discussion 2. An internal view loaded from a XIB file and displayed in an external view.
 * @discussion This property is nil if this component is already an internal view.
 */
@property (nonatomic, strong) MFUIBaseRenderableComponent *internalView;

/*!
 * @brief The parent container of this view
 */
@property (nonatomic, weak) MFUIBaseRenderableComponent *externalView;

/*!
 * @brief The style class that can be filled in Used Defined Runtime Attributes in InterfaceBuilder
 * @discussion This property aims to specify a custom class style for this component
 */
@property (nonatomic, strong) NSString *styleClass;

/*!
 * @brief The class abstract object this component should used to apply style.
 * @discussion This property is computed at runtime following the style's priority.
 */
@property  (nonatomic) Class baseStyleClass;


#pragma mark - Methods

/*!
 * @brief Retrieves a custom XIB if defined in InterfaceBuilder.
 * @return The name of the custom XIB to load
 */
-(NSString *) retrieveCustomXIB ;


/*!
 * @brief Retrieves a custom XIB if defined in InterfaceBuilder.
 * @return The name of the custom XIB to load
 */
-(NSString *) retrieveCustomErrorXIB ;

/*!
 * @brief Renders the component using the specific renderable properties.
 * @discussion In this MFBaseRenderableComoponent class, the base inspectable properties are used
 * to render the global appearence of the component.
 * @discussion This method should be used to increase the rendering on components that intherits from
 * this base class
 * @discussion This method is called in the (drawRect:) UIView's method
 * @param view The renderable component view to render using specific inspectable properties
 */
-(void) renderComponent:(MFUIBaseRenderableComponent *)view ;

/*!
 * @brief This required method must forward specific renderable properties on
 * the internal view.
 * @discussion Due to the different possible types for IBInspectable attributes, it's actually not possible
 * to forward automatically the IBInspectable attributes from the external view to the internal view.
 * @discussion Forwarding these properties allows you to used them both on the XIB that represents the Internal view
 * and the Storyboard that contains the external view.
 * @discussion This method is called when this MFBaseRenderableComponent is an external view only.
 */
-(void) forwardSpecificRenderableProperties;

/*!
 * @brief Required method that should update inner components of this MDK iOS Component
 * from the given data.
 * @param value The data this component manages
 */
-(void) setDisplayComponentValue:(id)value;

/*!
 * @brief Required method that should retrieve the value the component is currently displaying
 * @return The value the componeznt is currently displaying
 */
-(id) displayComponentValue;

/*!
 * @brief This method describes the treatment to do when the user click the error button of this component
 * @discussion By default, this method displays the error information
 */
-(void) doOnErrorButtonClicked;

/*!
 * @brief This method allows to do some treatments on outlets of this view
 * @discussion It is called at the end of awakeFromNib method 
 */
-(void)didInitializeOutlets;

/*!
 * @brief Returns the class name. This method is used to build the baseStyleClass of the component
 * @return The class name
 */
-(NSString *) className;

-(void) definePositionOfErrorViewWithParameters:(NSDictionary *)parameters whenShown:(BOOL)isShown;

extern const struct ErrorPositionParameters_Struct
{
    __unsafe_unretained NSString *ErrorView;
    __unsafe_unretained NSString *ParentView;
    __unsafe_unretained NSString *InternalViewLeftConstraint;
    __unsafe_unretained NSString *InternalViewTopConstraint;
    __unsafe_unretained NSString *InternalViewRightConstraint;
    __unsafe_unretained NSString *InternalViewBottomConstraint;
    
    //@non-generated-start[custom-structproperties][X]
    //@non-generated-end
} ErrorPositionParameters;
@end


#pragma mark -
#pragma mark MFInternalComponent

/*!
 * @protocol MFInternalComponent
 * @brief This protocol is used to specify that a MFBaseRenderableComponent
 * is used an "InternalView".
 * @see MFBaseRenderableComponent
 */
@protocol MFInternalComponent <NSObject>

@optional
/*!
 * @brief This method is optional and already implemented in MFBaseRenderableComponent.
 * It allows to forward outlets from this "InternalView" to the "ExternalView". This forward
 * is automatic, but this method should be overloaded if the developer want to forward others
 * unforwarded outlets.
 * @param receiver The receiver of the forward
 */
-(void) forwardOutlets:(MFUIBaseRenderableComponent *)receiver;

@end


#pragma mark -
#pragma mark MFExternalComponent
/*!
 * @protocol MFInternalComponent
 * @brief This protocol is used to specify that a MFBaseRenderableComponent
 * is used an "ExternalView".
 */
@protocol MFExternalComponent <NSObject>

#pragma mark - Methods
/*!
 * @brief This required method must return the name of the XIB that represents this component.
 * @discussion The XIB is the default XIB fileName (without the .xib extension) to use by defaulkt to
 * design this component; it can be override with the (NSString *)customXIBName method.
 * @return The name of the default XIB file to use to design this component.
 */
@required
-(NSString *) defaultXIBName;

/*!
 * @brief This optional method must not be implemented. It only allows
 * the MFBaseRenderableComponent class that implements this protocol to access
 * the customXIBName inspectable attribute declared on classes that inherit this class
 */
@optional
-(NSString *) customXIBName;


/*!
 * @brief This optional method must not be implemented. It only allows
 * the MFBaseRenderableComponent class that implements this protocol to access
 * the customXIBName inspectable attribute declared on classes that inherit this class
 */
@optional
-(NSString *) defaultErrorXIBName;

/*!
 * @brief This optional method must not be implemented. It only allows
 * the MFBaseRenderableComponent class that implements this protocol to access
 * the customXIBName inspectable attribute declared on classes that inherit this class
 */
@optional
-(NSString *) customErrorXIBName;

@end

