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
//  MFPhotoVoProtocol.h
//  MFUI
//
//

@protocol MFPhotoVoProtocol <NSObject>


/**
 * @brief identifier
 */

@property (nonatomic, strong) NSNumber *identifier;

/**
 * @brief name (title)
 */

@property (nonatomic, strong) NSString *titre;

/**
 * @brief description
 */

@property (nonatomic, strong) NSString *desc;

/**
 * @brief URI of remote or local photo
 */

@property (nonatomic, strong) NSString *uri;

/**
 * @brief date
 */

@property (nonatomic, strong) NSDate *date;

/**
 * @brief state
 */

@property (nonatomic, strong) NSString *photostate;


@end
