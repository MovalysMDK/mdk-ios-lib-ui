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
//  MFPhotoViewModel.h
//  MFUI
//
//

#import "MFUIControlPhoto.h"
#import "MFPositionViewModel.h"

@interface MFPhotoViewModel : MFUIBaseViewModel

#pragma mark - Properties

/*!
 * @brief identifier
 */

@property (nonatomic, strong) NSNumber *identifier;

/*!
 * @brief name (title)
 */

@property (nonatomic, strong) NSString *titre;

/*!
 * @brief description
 */

@property (nonatomic, strong) NSString *descr;

/*!
 * @brief URI of remote or local photo
 */

@property (nonatomic, strong) NSString *uri;

/*!
 * @brief date
 */

@property (nonatomic, strong) NSDate *date;

/*!
 * @brief state
 */

@property (nonatomic, strong) MFPhotoState *photoState;

/*!
 * @brief photo position
 */

@property (nonatomic, strong) MFPositionViewModel *position;


#pragma mark - Methods

/*!
 * @brief Retourne la date du view model en string au format dd/MM/yyyy hh:mm
 */

- (NSString *) getDateStringFormat:(NSString *)dateFormat;

/*!
 * @brief convert MFPhotoVoProtocol to MFPhotoViewModel instance
 * @param vo position value
 * @param parentVm parent viewmodel
 * @param parentPropertyName property name in the parent holding the position viewmodel
 */
+(MFPhotoViewModel *) toViewModel:(id<MFPhotoVoProtocol>)vo parentVm:(id<MFUIBaseViewModelProtocol>)parentVm parentPropertyName:(NSString *)parentPropertyName;

/*!
 * @brief Converts a PhotoViewModel to a PhotoObject
 * @param vm The PhotoViewModel to convert
 * @return The Photo object 
 */
+(id<MFPhotoVoProtocol>) convertViewModel:(MFPhotoViewModel *)vm toComponent:(id<MFPhotoVoProtocol>)vo;

/*!
 * @brief Indicates if the PhotoViewModel is empty or not
 * @return YES if the PhotoViewModel is empty, NO otherwhise.
 */
-(BOOL) isEmpty;


@end
