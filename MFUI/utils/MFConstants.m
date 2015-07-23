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
//  MFConstants.m
//  MFCore
//
//

#import "MFConstants.h"

/**
 * Cette classe définit des constantes nécessaires dans le Framework
 */


NSString *const CONVERTER_LIST_REGISTRY_KEY                 = @"Converters";

#pragma mark - Tags

NSInteger const FORM_BASE_TABLEVIEW_TAG                     = (long)&FORM_BASE_TABLEVIEW_TAG;
NSInteger const FORM_BASE_VIEW_TAG                          = (long)&FORM_BASE_VIEW_TAG;
NSInteger const SECTION_INDEXPATH_IDENTIFIER                = (long)&SECTION_INDEXPATH_IDENTIFIER;
NSInteger const HEADER_INDEXPATH_IDENTIFIER                 = (long)&HEADER_INDEXPATH_IDENTIFIER;

NSInteger const SCREEN_INDEXPATH_SECTION_IDENTIFIER         =(long)&SCREEN_INDEXPATH_SECTION_IDENTIFIER;
NSInteger const SCREEN_INDEXPATH_ROW_IDENTIFIER             =(long)&SCREEN_INDEXPATH_ROW_IDENTIFIER;

NSString const *MDK_XIB_IDENTIFIER                          = @"MDK_";

//Parameters keys
NSString *const PICKER_PARAMETER_SEARCH_KEY = @"search";
NSString *const PICKER_PARAMETER_VALUES_KEY= @"pickerValuesKey";
NSString *const PICKER_PARAMETER_SELECTION_INDICATOR_COLOR_KEY = @"selectionIndicatorColor";
NSString *const PICKER_PARAMETER_OK_BUTTON_COLOR_KEY = @"okButtonColor";
NSString *const PICKER_PARAMETER_CANCEL_BUTTON_COLOR_KEY = @"cancelButtonColor";
NSString *const PICKER_PARAMETER_SELECTED_VIEW_FORM_DESCRIPTOR_NAME_KEY = @"selectedViewFormDescriptorName";
NSString *const PICKER_PARAMETER_LIST_ITEM_VIEW_FORM_DESCRIPTOR_NAME_KEY = @"lstItemViewFormDescriptorName";
NSString *const PICKER_PARAMETER_EMPTY_VIEW_NIB_NAME = @"emptyViewNibName";

//Notifications keys
NSString *const PICKER_NOTIFICATION_FORCE_HIDE = @"pickerViewExternalForceHide";
NSString *const PICKER_NOTIFICATION_SHOW = @"pickerViewShow";
NSString *const PICKER_NOTIFICATION_HIDE = @"pickerViewHide";
NSString *const PICKER_NOTIFICATION_BUTTON_SAVE_TITLE = @"MFPickerListSaveButtonTitle";
NSString *const PICKER_NOTIFICATION_BUTTON_CANCEL_TITLE = @"MFPickerListCancelButtonTitle";

//Constants
const int PICKER_VIEW_TAG = INT16_MAX;
