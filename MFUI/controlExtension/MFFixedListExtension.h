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

/*!
 * @typedef MFFixedListEditMode
 * @brief Cette structure définit le mode d'édition de la liste
 * @constant MFFixedListEditModePopup La liste est éditable via une popup
 * @constant MFFixedListEditModeDirect La liste est directement éditable.
 */
typedef enum {
    MFFixedListEditModePopup=0,
    MFFixedListEditModeDirect=1
} MFFixedListEditMode;

@interface MFFixedListExtension : NSObject

@property (nonatomic) BOOL canAddItem;
@property (nonatomic) BOOL canEditItem;
@property (nonatomic) BOOL canDeleteItem;
@property (nonatomic) BOOL isPhotoFixedList;
@property (nonatomic) MFFixedListEditMode editMode;

@end
