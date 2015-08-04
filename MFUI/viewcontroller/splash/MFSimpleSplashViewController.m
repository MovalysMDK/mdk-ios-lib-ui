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
//  MFSimpleSplashViewController.m
//  MFUI
//
//


#import <MFCore/MFCoreApplication.h>
#import <MFCore/MFCoreBean.h>
#import <MFCore/MFCoreConfig.h>

#import "MFSimpleSplashViewController.h"
#import "MFTransitionController.h"
#import "MFViewController.h"

@interface MFSimpleSplashViewController ()

@property(nonatomic) NSInteger progressMax;
@property(nonatomic) NSInteger progress;


@end

@implementation MFSimpleSplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.progress = 0;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initProgressBar];
}



-(void) initProgressBar {
    // Do any additional setup after loading the view.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        MFStarter* starter = [MFStarter getInstance];
        [starter setInitCallBack:^(NSInteger count) {
            self.progressMax = count;
        } withProgressCallBack:^(NSString *step, NSString *state) {
            if ([STEP_INIT_PROPERTIES isEqualToString:step]) {
                if ([STARTER_END isEqualToString:state]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(self.progressView)
                            [self.progressView setHidden:false];
                        if(self.indicatorView)
                            [self.indicatorView startAnimating];
                    });
                }
                else {
                    //start
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(self.progressView)
                            [self.progressView setHidden:true];
                        if(self.indicatorView)
                            [self.indicatorView stopAnimating];
                    });
                }
            }
            if (![step hasPrefix:@"STEP_"] &&
                [STARTER_END isEqualToString:state]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.progress = self.progress+1;
                    if(self.progressView) {
                        self.progressView.progress = (float)self.progress/(float)self.progressMax;
                    }
                });
            }
        } withEndCallBack:^(){
            //tempo nécessaire pour que l'oeil distingue le dernier avancement de la barre de progression
            usleep(100);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *mainStoryboardName = [[[[MFBeanLoader getInstance] getBeanWithKey:BEAN_KEY_CONFIGURATION_HANDLER] getProperty:MFPROP_MainStoryboard]getStringValue];
                UIViewController *initialViewController = nil;
                
                if (mainStoryboardName && mainStoryboardName.length > 0) {
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:mainStoryboardName bundle:nil];
                    initialViewController = [sb instantiateInitialViewController];
                }
                else {
                    initialViewController = [[MFViewController alloc] init];
                }
                [self.transitionController transitionToViewController:initialViewController withOptions:UIViewAnimationOptionTransitionCurlUp];
                
                
            });
        }
         ];
    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}





@end
