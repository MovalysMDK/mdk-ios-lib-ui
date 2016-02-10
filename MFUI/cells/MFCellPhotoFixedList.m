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
//  MFCellPhotoFixedList.m
//  Pods
//
//
//

#import "MFCellPhotoFixedList.h"
#import "MFPhotoDetailViewController.h"
#import "MFPhotoFixedListItemCell.h"
#import "MFUIBaseListViewModel.h"

@implementation MFCellPhotoFixedList


/**
 * @brief Surcharge de la méthode d'ajout d'un item à la fixed list pour l'ajout du composant
 * MPhotoThumbnail
 */
-(void)addItemOnFixedList
{

    
}

-(NSArray *)customButtonsForFixedList {
//    [MFException throwNotImplementedExceptionOfMethodName:@"customButtonsForFixedList" inClass:[self class] andUserInfo:nil];
    return @[];
}

-(NSString *)itemListViewModelName {
//    [MFException throwNotImplementedExceptionOfMethodName:@"itemListViewModelName" inClass:[self class] andUserInfo:nil];
    return @"";
}


@end
