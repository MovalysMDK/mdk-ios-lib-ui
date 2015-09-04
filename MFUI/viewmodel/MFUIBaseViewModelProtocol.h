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



@protocol MFFormViewControllerProtocol;
@protocol MFObjectWithBindingProtocol;
@protocol MFCommonFormProtocol;


@protocol MFUIBaseViewModelProtocol <NSObject>

#pragma mark - Properties
/*!
 * @brief This property is the ViewController that manages the binding between the ViewModel and the components owned by this form.
 */
@property (nonatomic, weak) id<MFCommonFormProtocol> form;

/*!
 * @brief Indicates this ViewModel has changed. It's necessary to know if it should be saved.
 */
@property (nonatomic) BOOL hasChanged;


@property (nonatomic, weak) NSObject<MFObjectWithBindingProtocol> *objectWithBinding;


#pragma mark - Methods


/*!
 * @brief Returns the form associated to this ViewModel
 * @return A id<MFCommonFormProtocol> object.
 */
-(id<MFCommonFormProtocol>) getForm;

/*!
 * @brief get child viewmodels (property names)
 */
-(NSArray *)getChildViewModels;

/*!
 * @brief Indicates if this ViewModel is valid
 * @return YES if the view model is considered valid, NO otherwise
 */
-(BOOL) validate ;

/*!
 * @brief Indicates that this ViewModel has no more changes
 */
-(void) resetChanged;


#pragma mark - Inherited methods

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

-(id)valueForKeyPath:(NSString *)keyPath;

-(void)setValue:(id)value forKeyPath:(NSString *)keyPath;


@end


