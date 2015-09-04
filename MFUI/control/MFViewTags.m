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


#import "MFViewTags.h"

/**
 * Cette classe définit les tags utilisés pour le test automatique des composants.
 *
 * Convention de nommage, pour le nom des tags : TAG_COMPONENTNAME_SUBVIEWVARNAME
 * - TAG : "TAG"
 * - COMPONENTNAME : nom du composant (nom du fichier .h/.m sans l'extension)
 * - SUBVIEWVARNAME : nom de la variable de chaque subview déclarée dans la méthode customizableComponents() du composant
 * Tous les caractères sont en majuscules.
 *
 * Convention de numérotation, pour la valeur des tags : AAABB
 * - AAA : 100 + indice du composant dans l'arboresence du répertoire control (après avoir fait un clic-droit sur le dossier control/le sous-dossier contentant le composant, puis "Sort by Name")
 * -  BB :  00 + indice de chaque subview déclarée dans la méthode customizableComponents() du composant (en respectant l'ordre d'apparition dans la méthode)
 * Initialement, les indices sont incrémentés de 5 en 5, en allant de 100 à 995 pour AAA et 00 à 95 pour BB.
 * Par la suite (et pour éviter un décalage fastidieux des indices), il sera toléré d'utiliser n'importe quel nombre entre deux indices existants
 *              (par exemple 101 102 103 104 pour AAA, ou 21 22 23 24 pour BB...)
 */

//                                                               AAABB

// /MFUI/control/button
NSInteger const TAG_MFBUTTON_BUTTON                           = 10005;

// /MFUI/control/date
NSInteger const TAG_MFDATEPICKER_DATEBUTTON                   = 10500;
NSInteger const TAG_MFDATEPICKER_DATEPICKER                   = 10505;
NSInteger const TAG_MFDATEPICKER_CONFIRMBUTTON                = 10510;
NSInteger const TAG_MFDATEPICKER_CANCELBUTTON                 = 10515;

// /MFUI/control/image
NSInteger const TAG_MFENUMIMAGE_IMAGEVIEW                     = 11000;

// /MFUI/control/label
NSInteger const TAG_MFLABEL_LABEL                             = 11500;

// /MFUI/control/list
NSInteger const TAG_MFFIXEDLIST_TABLEVIEW                     = 12000;
NSInteger const TAG_MFFIXEDLIST_TOPBARVIEW                    = 12005;

NSInteger const TAG_MFPICKERLIST_PICKERVIEW                   = 12500;
NSInteger const TAG_MFPICKERLIST_CONFIRMBUTTON                = 12505;
NSInteger const TAG_MFPICKERLIST_CANCELBUTTON                 = 12510;

NSInteger const TAG_MFSIMPLEPICKERLIST_PICKERBUTTON           = 13000;
NSInteger const TAG_MFSIMPLEPICKERLIST_PICKERVIEW             = 13005;
NSInteger const TAG_MFSIMPLEPICKERLIST_CONFIRMBUTTON          = 13010;
NSInteger const TAG_MFSIMPLEPICKERLIST_CANCELBUTTON           = 13015;

// /MFUI/control/number
NSInteger const TAG_MFNUMBERPICKER_NUMBERBUTTON               = 13500;
NSInteger const TAG_MFNUMBERPICKER_PICKERVIEW                 = 13505;
NSInteger const TAG_MFNUMBERPICKER_CONFIRMBUTTON              = 13510;
NSInteger const TAG_MFNUMBERPICKER_CANCELBUTTON               = 13515;

// /MFUI/control/photo
NSInteger const TAG_MFPHOTOTHUMBNAIL_PHOTOVIEW                = 14000;
NSInteger const TAG_MFPHOTOTHUMBNAIL_DATE                     = 14005;
NSInteger const TAG_MFPHOTOTHUMBNAIL_TITRE                    = 14010;
NSInteger const TAG_MFPHOTOTHUMBNAIL_DESCRIPTION              = 14015;

// /MFUI/control/position
NSInteger const TAG_MFPOSITION_LATITUDE                       = 14500;
NSInteger const TAG_MFPOSITION_LONGITUDE                      = 14505;
NSInteger const TAG_MFPOSITION_GPSBUTTON                      = 14510;
NSInteger const TAG_MFPOSITION_MAPBUTTON                      = 14515;

// /MFUI/control/processing

// /MFUI/control/signature
NSInteger const TAG_MFSIGNATURE_SIGNATURE                     = 15000;
NSInteger const TAG_MFSIGNATURE_CONFIRMBUTTON                 = 15005;
NSInteger const TAG_MFSIGNATURE_CANCELBUTTON                  = 15010;
NSInteger const TAG_MFSIGNATURE_CLEARBUTTON                   = 15015;

// /MFUI/control/slider
NSInteger const TAG_MFSLIDER_SLIDER                           = 15500;
NSInteger const TAG_MFSLIDER_SLIDERVALUE                      = 15505;

// /MFUI/control/switch
NSInteger const TAG_MFSWITCH_SWITCHCOMPONENT                  = 16000;

// /MFUI/control/textfield
NSInteger const TAG_MFBROWSEURLTEXTFIELD_TEXTFIELD            = 16500;
NSInteger const TAG_MFBROWSEURLTEXTFIELD_ACTIONBUTTON         = 16505;

NSInteger const TAG_MFCALLPHONENUMBERTEXTFIELD_TEXTFIELD      = 17000;
NSInteger const TAG_MFCALLPHONENUMBERTEXTFIELD_ACTIONBUTTON   = 17005;

NSInteger const TAG_MFDOUBLETEXTFIELD_TEXTFIELD               = 17500;
NSInteger const TAG_MFDOUBLETEXTFIELD_ACTIONBUTTON            = 17505;

NSInteger const TAG_MFINTEGERTEXTFIELD_TEXTFIELD              = 18000;
NSInteger const TAG_MFINTEGERTEXTFIELD_ACTIONBUTTON           = 18005;

NSInteger const TAG_MFREGULAREXPRESSIONTEXTFIELD_TEXTFIELD    = 18500;
NSInteger const TAG_MFREGULAREXPRESSIONTEXTFIELD_ACTIONBUTTON = 18505;

NSInteger const TAG_MFSENDEMAILTEXTFIELD_TEXTFIELD            = 19000;
NSInteger const TAG_MFSENDEMAILTEXTFIELD_ACTIONBUTTON         = 19005;

NSInteger const TAG_MFTEXTFIELD_TEXTFIELD                     = 19500;

NSInteger const TAG_MFTEXTVIEW_TEXTVIEW                       = 20000;

// /MFUI/control/tooltip

// /MFUI/control/webview
NSInteger const TAG_MFWEBVIEW_WEBVIEW                         = 20500;
NSInteger const TAG_MFWEBVIEW_SPINNER                         = 20505;
