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
//  MFViewControllerProtocol.h
//  MFCore
//
//



@protocol MFViewControllerProtocol <NSObject>

#pragma mark - MEthods
@optional

/*!
 * @brief Generic action called when a button is pressed on a mains creen
 * @param the sender of the action
 * @return the associated IBAction 
 */
-(IBAction)genericButtonPressed:(id)sender;

/*!
 * Show the waiting view in order to block UI
 */
-(void) showWaitingView;

/*!
 * Show the waiting view in order to block UI
 */
-(void) showWaitingViewWithMessageKey:(NSString *)key;

/*!
 * Dismiss the waiting view if it's displayed
 */
-(void) dismissWaitingView;

/*!
 * Show the waiting view in order to block UI during a given time (in seconds)
 * @param seconds The number of seconds for displaying waiting view
 */
-(void) showWaitingViewDuring:(int)seconds;


@end
