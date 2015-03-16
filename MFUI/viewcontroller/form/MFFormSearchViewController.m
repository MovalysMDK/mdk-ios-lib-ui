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
//  MFFormSearchViewController.m
//  MFUI
//
//

/**
 * @brief This class is the base Controller to display a search form
 */

#import "MFFormSearchViewController.h"
#import "MFLocalizedString.h"
#import "MFUILogging.h"
#import "MFUILoggingHelper.h"
#import <MFCore/MFCoreApplication.h>
#import "MFUIBaseViewModel.h"
#import "MFAbstractDataLoader.h"
#import "MFDataLoaderActionParameter.h"
#import "MFGenericLoadDataAction.h"


@interface MFFormSearchViewController ()

@end

@implementation MFFormSearchViewController


#pragma mark - Initialization and controller lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.   
    self.navigationBar.topItem.title = MFLocalizedStringFromKey(@"MFFormSearchViewController_title");
    self.navigationBarLeftButton.title = MFLocalizedStringFromKey(@"MFFormSearchViewController_leftButton_title");
    self.navigationBarRightButton.title = MFLocalizedStringFromKey(@"MFFormSearchViewController_rightButton_title");

    [self.navigationBarLeftButton  setTarget:self];
    [self.navigationBarRightButton setTarget: self];
    [self.toolBarClearButton setTarget: self];

    [self.navigationBarLeftButton setAction:@selector(navigationBarLeftButtonAction)];
    [self.navigationBarRightButton setAction:@selector(navigationBarRightButtonAction)];
    [self.toolBarClearButton setAction:@selector(toolBarClearButtonAction)];

   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Searching actions
-(void)navigationBarLeftButtonAction {
    MFUILogInfo(@"Close search form %@ and cancel", self.class);
    [self dismissViewControllerAnimated:YES completion:nil];
    [self cancelSearch];

}

-(void)navigationBarRightButtonAction {
    MFUILogInfo(@"Close search form %@ and valid", self.class);
    [self dismissViewControllerAnimated:YES completion:nil];
    [self validFormAndSearch];
}

-(void)toolBarClearButtonAction {
    for(NSString *bindedPropertyName in [(MFUIBaseViewModel *)self.viewModel getBindedProperties]) {
        [self.viewModel setValue:nil forKeyPath:bindedPropertyName];
    }
}

-(void) validFormAndSearch {
/*    NSException *notImplemetedException = [NSException exceptionWithName:@"Missing Method implementation"
                                                                  reason:[NSString stringWithFormat:@"The method \"validFormAndSearch\" should be implemented in %@", self.class] userInfo:nil];
    MFUILogError(@"%@",notImplemetedException.debugDescription);
    @throw(notImplemetedException);*/
}

-(void) cancelSearch {

}

@end
