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
//  JDFSequentialTooltipManager.h
//  JoeTooltips
//
//  Created by Joe Fryer on 17/11/2014.
//  Copyright (c) 2014 Joe Fryer. All rights reserved.
//

#import "JDFTooltipManager.h"


/*!
 *  JDFSequentialTooltipManager is a subclass of JDFTooltipManager that allows you to show tooltips sequentially instead of all at-once.
 
 *  By default, tapping a tooltip or the backdrop triggers @c showNextTooltip (showing the next tooltip, or finishing the sequence and hiding everything).
 */
@interface JDFSequentialTooltipManager : JDFTooltipManager

#pragma mark - Options

/*!
 *  Indicates whether a tap on the backdropView triggers an action. For JDFSequentialTooltipManager, this action is showNextTooltip. Default is YES.
 */
@property (nonatomic) BOOL backdropTapActionEnabled;


#pragma mark - Showing Tooltips
/*!
 *  Hides the manager's current tooltip (if there is a tooltip currently showing) and shows the next one.
 
 *  Tooltips are shown in the order they are added.
 
 *  If there an no more tooltips to be shown, the last tooltip and the backdrop are hidden.
 */
- (void)showNextTooltip;

@end
