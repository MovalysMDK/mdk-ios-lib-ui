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
@protocol MFObjectWithListenerProtocol;
@class MFListenerDescriptorManager;

/*!
 * @typedef MFListenerEventType
 * @brief Enumerates the types of event that can be listened
 * @constant MFListenerEventTypeViewModelPropertyChanged
 * @constant MFListenerEventTypeActionCallbackSuccess
 * @constant MFListenerEventTypeActionCallbackFail
 * @constant MFListenerEventTypeActionCallbackProgress
 */
typedef NS_ENUM(NSInteger, MFListenerEventType) {
    MFListenerEventTypeViewModelPropertyChanged,
    MFListenerEventTypeActionCallbackSuccess,
    MFListenerEventTypeActionCallbackFail,
    MFListenerEventTypeActionCallbackProgress
};


/*!
 * @class MFListenerDescriptor
 * @brief Represent a listener descriptor
 * @discussion A listener descriptor describes, for an given event type, a structure that will
 * be used by the object that listens
 */
@interface MFListenerDescriptor : NSObject

#pragma mark - Initialization

/*!
 * @brief Initializes a new listener descriptor with a given event type and a given format,
 * and returns it to the caller
 * @param eventType A value of MFListenerEventType that represent the type of the event 
 * that he listener describes by this object listen to.
 * @return The MFListenerDescriptor built object
 */
+(instancetype) listenerDescriptorForType:(MFListenerEventType)eventType withFormat:(NSString *)format,... NS_REQUIRES_NIL_TERMINATION;


#pragma mark - Accessors
/*!
 * @brief Returns an array of callbacks for a given keyPath
 * @param keyPath A given keypath used to retrieves the callback associated to.
 * @return An array of callbacks as NSString objects.
 */
-(NSArray *) callbackForKeyPath:(NSString *) keyPath ;

/*!
 * @brief Sets the target of the callback for this listener
 * @discussion The target must conform the MFObjectWithListenerProtocol protocol
 * @param object The target object of callbacks for the listener describes by this object.
 * @see MFObjectWithListenerProtocol
 */
-(void) setTarget:(id<MFObjectWithListenerProtocol>)object;

/*!
 * @brief Indicates if the listener describes by this object, listen to the given type of event
 * @param eventType The value of the event type
 * @return YES if the listener described by this object listen to the given type of event, NO otherwhise
 */
-(BOOL) listenEventType:(MFListenerEventType)eventType;

@end


/*!
 * @protocol MFObjectWithListenerProtocol
 * @brief This protocol identfy a object that have listeners
 */
@protocol MFObjectWithListenerProtocol <NSObject>

/*!
 * @brief The manager of Listener Descriptors for the object that conforms this protocol
 */
@property (nonatomic, strong) MFListenerDescriptorManager *listenerDecriptorManager;

@end
