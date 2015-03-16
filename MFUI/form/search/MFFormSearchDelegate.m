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
//  MFFormBaseSearchViewController.m
//  MFUI
//
//

/**
 * @brief This class is a delegate that allow to integrate un search button in a formController
 */

#import "MFFormSearchDelegate.h"
#import <MFCore/MFCoreApplication.h>
#import "MFFormSearchViewController.h"
#import "MFUILogging.h"
#import "MFContextProtocol.h"


@interface MFFormSearchDelegate ()

/**
 * @brief The needed searchBar if the search is simple
 */
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic) BOOL enabled;

@property (nonatomic, strong) NSString *lastSearchText;

@end

@implementation MFFormSearchDelegate

#pragma  mark - Synthesizing properties of delegate
@synthesize isLiveSearch = _isLiveSearch;
@synthesize isSimpleSearch = _isSimpleSearch;
@synthesize searchFormController = _searchFormController;
@synthesize displayNumberOfResults = _displayNumberOfResults;

#pragma  mark - Initializing and Controller lifecycle


#pragma  mark - MFFormSearchProtocol methods implementation
-(void)addSearchIcon {
    //Creating a new UIbarButtonItem and adding it to the navigationItem
    self.enabled = NO;
    self.lastSearchText = @"";
    NSMutableArray *currentRightBarButtonItems = [self.baseController.navigationItem.rightBarButtonItems mutableCopy];
    if(!currentRightBarButtonItems) {
        currentRightBarButtonItems = [NSMutableArray array];
    }
    UIBarButtonItem *searchIcon = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchFormController)];
    [currentRightBarButtonItems insertObject:searchIcon atIndex:0];
    self.baseController.navigationItem.rightBarButtonItems = currentRightBarButtonItems;
}

-(void)showSearchFormController {
    self.enabled = YES;
    if(self.isSimpleSearch) {
        [self showSearchBar];
    }
    else {
        if(self.isLiveSearch) {
            // NOTHING TO DODO HERE.
        }
        else {
            if([self.baseController searchViewController]) {
                MFFormSearchViewController *searchController = [self.baseController searchViewController];
                searchController.targetFormController = self.baseController;
                [self.baseController presentViewController:searchController animated:YES completion:nil];
            }
        }
    }
}

-(void)setBaseController:(MFFormBaseViewController *)baseController {
    _baseController = baseController;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addSearchIcon];
    });
}


#pragma mark - SearchBar hide/show

-(void)showSearchBar{
    self.enabled = YES;
    //Initializing searchBar
    UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,self.baseController.view.frame.size.width,40)]; // frame has no effect.
    [searchBar setBarStyle:UIBarStyleBlack];
    searchBar.showsCancelButton = YES;
    searchBar.delegate = self;
    [searchBar setText:self.lastSearchText];
    
    //Showing searchBar and customize appearence in the formController
    self.baseController.tableView.tableHeaderView = searchBar;
    [self.baseController.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.baseController.searchController setActive:YES animated:YES];
    
    //Scrolling to top
    [self.baseController.tableView scrollRectToVisible:CGRectMake(1, 1, 1, 1) animated:YES];
    
    //Initializing and showing keyboard
    [searchBar becomeFirstResponder];
    [searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
}

-(void)hideSearchBar {
    self.baseController.tableView.tableHeaderView = nil;
    [self.baseController.searchController setActive:NO animated:YES];
    [self.baseController.navigationItem.rightBarButtonItem setEnabled:YES];
    [self hidePromptForced:NO];
}

-(void) hidePromptForced:(BOOL)forced {
    if(forced) {
        [self.baseController.navigationItem performSelector:@selector(setPrompt:) withObject:nil afterDelay:2];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            int delay = self.isLiveSearch ? -1 : 2;
            delay = self.isSimpleSearch ? delay : 2;
            if(delay !=-1) {
                [self.baseController.navigationItem performSelector:@selector(setPrompt:) withObject:nil afterDelay:delay];
            }
        });
    }
}


#pragma mark - SearchBar Delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if(!self.isLiveSearch) {
        [self processSearchWithText:searchBar.text];
    }
    [self hideSearchBar];
    [self hidePromptForced:YES];
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(self.isLiveSearch) {
        [self processSearchWithText:searchText];
    }
    if([searchText isEqualToString:@""]) {
        [self hidePromptForced:NO];
    }
    self.lastSearchText = searchText;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.lastSearchText = @"";
    [self processSearchWithText:self.lastSearchText];
    [self hideSearchBar];
    [self hidePromptForced:YES];
}


#pragma mark - Searching
-(void) processSearchWithText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.baseController simpleSearchActionWithText:text];
    });
}

-(int)numberOfResults {
    NSInteger numberOfSections = [self.baseController.tableView numberOfSections];
    int totalNumberOfRows = 0;
    for(int sectionIndex = 0 ; sectionIndex < numberOfSections ; sectionIndex++) {
        totalNumberOfRows += [self.baseController.tableView numberOfRowsInSection:sectionIndex];
    }
    return totalNumberOfRows;
}

-(void) actualizePrompt {
    if(self.displayNumberOfResults && ![self.searchBar.text isEqualToString:@""] && self.enabled) {
        int numberOfresults = [self numberOfResults];
        NSString *promptText = nil;
        if(numberOfresults < 2 ) {
            promptText = [NSString stringWithFormat:@"%i résultat", numberOfresults];
        }
        else {
            promptText = [NSString stringWithFormat:@"%i résultats", numberOfresults];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.baseController.navigationItem.prompt = promptText;
            [self hidePromptForced:NO];
        });
    }
    else {
        [self hidePromptForced:NO];
    }
}




@end
