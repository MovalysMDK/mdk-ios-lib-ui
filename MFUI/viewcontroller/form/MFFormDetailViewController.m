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



#import <MFCore/MFCoreI18n.h>

#import "MFFormDetailViewController.h"
#import "MFFormValidationDelegate.h"
#import "MFUIComponentProtocol.h"

@interface MFFormDetailViewController ()

/**
 * @brief Indicates if an update of the object that ask this detail form controller should be done
 */
@property BOOL shouldUpdateSender;

@end

@implementation MFFormDetailViewController
@synthesize viewModel = _viewModel;
@synthesize parentFormController = _parentFormController;
@synthesize editable = _editable;
@synthesize indexPath = _indexPath;
@synthesize formValidation = _formValidation;
@synthesize originalViewModel = _originalViewModel;
@synthesize editionType = _editionType;
@synthesize sender = _sender;

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
    
    self.shouldUpdateSender = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:MFLocalizedStringFromKey(@"form_cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc]
                                              initWithTitle:MFLocalizedStringFromKey(@"form_save") style: UIBarButtonItemStylePlain
                                              target:self action:@selector(dismissDetail)];
    
    self.navigationItem.leftBarButtonItem = left;
    self.navigationItem.rightBarButtonItem = right;
    
    // Si le contrôleur n'est pas surchargé par défaut, on met le nom du storyboard qui le contient.
    NSString *screenTitleLocalized = [NSString stringWithFormat:@"screen_title_%@", self.class] ;
    self.title = MFLocalizedStringFromKey( screenTitleLocalized );
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self isMovingFromParentViewController])
    {
        if(!self.shouldUpdateSender) {
            [self.sender updateChangesFromDetailControllerOnCellAtIndexPath:self.indexPath withViewModel:self.viewModel editionType:self.editionType];
        }    }
    else
    {
        NSLog(@"New view controller was pushed");
    }
}

#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
-(void)setViewModel:(id<MFUIBaseViewModelProtocol>)viewModel {
    _viewModel = viewModel;
    _viewModel.form = self;
    
    //Si une propriété currentViewModel est générée sur la classe du projet ave cle bon type
    if([self respondsToSelector:@selector(setCurrentViewModel:)]) {
        [self performSelector:@selector(setCurrentViewModel:) withObject:viewModel];
    }
}
#pragma clang diagnostic pop

-(void) cancelAction {
    self.shouldUpdateSender = YES;
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)setOriginalViewModel:(id<MFUIBaseViewModelProtocol>)originalViewModel {
    self.viewModel = originalViewModel;
    _originalViewModel = originalViewModel;
}



- (void)dismissDetail {
    
    if ( [ self.formValidation validateViewModel: self.viewModel] ) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        UIAlertView *invalidDataAlert = [[UIAlertView alloc]
                                         initWithTitle:MFLocalizedStringFromKey(@"form_savefailed_title")
                                         message:MFLocalizedStringFromKey(@"form_savefailed_title")
                                         delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil, nil];
        invalidDataAlert.tag = kDiscardChangesAlert;
        [invalidDataAlert show];
    }
}

-(id<MFUIBaseViewModelProtocol>)createViewModel {
    return self.originalViewModel;
}

-(void)setFormValidation:(MFFormValidationDelegate *)formValidation {
    _formValidation = formValidation;
}


@end
