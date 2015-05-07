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


#import "MFFormValidationDelegate.h"

@interface MFFormViewControllerValidationDelegate : MFFormValidationDelegate

/*!
 * @brief validation on form close
 * @param isAlert display an alert if vm has changes
 * @param autoSave automatic save if viewmodel has changes
 * @return BOOL true if form can be closed
 */
-(BOOL) onCloseFormDoAlert:(BOOL)isAlert andSave:(BOOL)autoSave;

@end
