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
//  MFForm3DHeaderViewControls.h
//  MFUI
//
//

#import "MFBindingViewAbstract.h"


/**
 * @brief This protocol should be implement by a 3D List Controller.
 * It allows the controller to navigate between the different pages 
 * of the 3D List
 */
@protocol MFForm3DControlsDelegate <NSObject>

@required

/**
 * @brief Method called when the user tap on the next arrow
 */
-(void) onNext;

/**
 * @brief Method called when the user tap on the previous arrow
 */
-(void) onPrevious;

@end



@interface MFForm3DHeaderViewControls : UIView

/**
 * @brief The 'next' arrow
 */
@property (nonatomic, strong) UIButton *arrowNext;

/**
 * @brief The 'previous' arrow
 */
@property (nonatomic, strong) UIButton *arrowPrevious;

/**
 * @brief The contentView of the control. It's the view where is displayed the binded components.
 */
@property (nonatomic, strong) MFBindingViewAbstract *contentView;

/**
 * @brief The delegate on which will be performed 'onNext' and 'onPrevious' events.
 */
@property (nonatomic, weak) id<MFForm3DControlsDelegate> delegate;

@end


