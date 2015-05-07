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
//  MFPositionViewModel.h
//  MFUI
//
//

#import "MFUIControl.h"

#import "MFUIBaseViewModel.h"

@interface MFPositionViewModel : MFUIBaseViewModel

@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;

/*!
 * @brief convert MFPositionVoProtocol to MFPositionViewModel instance
 * @param vo position value
 * @param parentVm parent viewmodel
 * @param parentPropertyName property name in the parent holding the position viewmodel
 */
+(MFPositionViewModel *) toViewModel:(id<MFPositionVoProtocol>)vo parentVm:(id<MFUIBaseViewModelProtocol>)parentVm parentPropertyName:(NSString *)parentPropertyName;

+(MFPositionViewModel *) convertViewModel:(MFPositionViewModel *)vm toComponent:(id<MFPositionVoProtocol>)vo;

@end
