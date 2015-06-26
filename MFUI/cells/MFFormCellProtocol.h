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


#import "MFUITransitionDelegate.h"

@protocol MFUIComponentProtocol;
/*!
 * @brief A protocol defining some basic methods and attributes for framework cells.
 * @discussion This protocol should be used by any cell that should be binded or used by the framework
 */
@protocol MFFormCellProtocol


#pragma mark - Properties
@required

/*
 UI Transition Delegate Manager.
 */
@property(nonatomic, weak) id<MFUITransitionDelegate> transitionDelegate;

/*!
 * @brief L'indexPath de cette cellule
 */
@property (nonatomic, strong) NSIndexPath *cellIndexPath;


@end
