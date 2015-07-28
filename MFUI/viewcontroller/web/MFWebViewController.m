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

#define kLeftMargin				2.0
#define kTopMargin				4.0
#define kRightMargin			2.0
#define kTweenMargin			6.0

#define kNavigationBarHeight    40.0
#define kTextFieldHeight		30.0


#import "MFWebViewController.h"
#import <MFCore/MFCoreI18n.h>

@implementation MFWebViewController

@synthesize myWebView;

-(void)initialize {
    self.title = MFLocalizedStringFromKey(@"WebTitle");
    [self initializeNavigationbar];
    [self initializeUrlField];
    [self initializeWebView];
}

-(void) initializeNavigationbar
{
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kNavigationBarHeight)];
    self.navigationItem.title = @"";
    [self.navigationBar pushNavigationItem:self.navigationItem animated:YES];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]
                                    initWithTitle: MFLocalizedStringFromKey(@"closeButton")
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(closeViewController)];
    self.navigationItem.leftBarButtonItem = closeButton;
    [self.view addSubview:self.navigationBar];
}

-(void) initializeUrlField
{
    CGRect textFieldFrame = CGRectMake(kLeftMargin, kNavigationBarHeight + kTweenMargin,
									   self.view.bounds.size.width - (kLeftMargin * 2.0), kTextFieldHeight);
	self.urlField = [[UITextField alloc] initWithFrame:textFieldFrame];
    self.urlField.borderStyle = UITextBorderStyleBezel;
    self.urlField.textColor = [UIColor blackColor];
    self.urlField.delegate = self;
    self.urlField.placeholder = @"<enter a URL>";
    self.urlField.text = @"http://www.sopragroup.com";
	self.urlField.backgroundColor = [UIColor whiteColor];
	self.urlField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.urlField.returnKeyType = UIReturnKeyGo;
	self.urlField.keyboardType = UIKeyboardTypeURL;	// this makes the keyboard more friendly for typing URLs
	self.urlField.autocapitalizationType = UITextAutocapitalizationTypeNone;	// don't capitalize
	self.urlField.autocorrectionType = UITextAutocorrectionTypeNo;	// we don't like autocompletion while typing
	self.urlField.clearButtonMode = UITextFieldViewModeAlways;
	[self.urlField setAccessibilityLabel:MFLocalizedStringFromKey(@"URLTextField")];
	[self.view addSubview:self.urlField];
}

-(void) initializeWebView
{
    CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
	webFrame.origin.y += kTopMargin + kNavigationBarHeight + kTextFieldHeight;	// leave from the URL input field and its label
	webFrame.size.height -= 40.0;
	self.myWebView = [[UIWebView alloc] initWithFrame:webFrame];
	self.myWebView.backgroundColor = [UIColor whiteColor];
	self.myWebView.scalesPageToFit = YES;
	self.myWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.myWebView.delegate = self;
	[self.view addSubview:self.myWebView];
}

-(id) init{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}


- (void)viewDidLoad
{
	[super viewDidLoad];
}

-(void) closeViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//
- (void)viewDidUnload
{
	[super viewDidUnload];
	
	// release and set to nil
	self.myWebView = nil;
}


#pragma mark -
#pragma mark UIViewController delegate methods

- (void)viewWillAppear:(BOOL)animated
{
	self.myWebView.delegate = self;	// setup the delegate as the web view is shown
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlField.text]]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.myWebView stopLoading];	// in case the web view is still loading its content
	self.myWebView.delegate = nil;	// disconnect the delegate as the webview is hidden
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// we support rotation in this view controller
	return YES;
}

// this helps dismiss the keyboard when the "Done" button is clicked
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[textField text]]]];
	
	return YES;
}

-(NSString *) url
{
    return self.urlField.text;
}

-(void) setUrl:(NSString *)url
{
    self.urlField.text = url;
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// starting the load, show the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// finished loading, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// load error, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	// report the error inside the webview
	NSString *errorString = [NSString stringWithFormat:
							 @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
							 error.localizedDescription];
	[self.myWebView loadHTMLString:errorString baseURL:nil];
}

@end
