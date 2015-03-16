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
//  MFWebView.m
//  MFUI
//
//

#import "MFUILogging.h"

#import "MFWebView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MFCellAbstract.h"
#import "math.h"

@interface MFWebView()

@property (nonatomic, strong) 	MBProgressHUD *HUD;

@property (nonatomic) BOOL isLoading;


@end

@implementation MFWebView

NSString *const DEFAULT_URL = @"defaultUrl";
NSString *const IS_LOCAL = @"isLocal";
NSTimer *timer =nil;


-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initialize];
    }
    return self;
}


-(void) initialize {
    
    //Création du label et ajout à la vue
    self.webview = [[UIWebView alloc] initWithFrame:self.bounds];
    self.webview.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.webview.userInteractionEnabled = YES;
    self.webview.delegate=self;
    
    self.isLoading = NO;
    self.userInteractionEnabled = YES;
    
    [self addSubview:self.webview];
    
    NSLayoutConstraint *insideLabelConstraintLeftMargin = [NSLayoutConstraint constraintWithItem:self.webview attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:0 constant:0];
    NSLayoutConstraint *insideLabelConstraintTopMargin = [NSLayoutConstraint constraintWithItem:self.webview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:0 constant:0];
    NSLayoutConstraint *insideLabelConstraintHeight = [NSLayoutConstraint constraintWithItem:self.webview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    NSLayoutConstraint *insideLabelConstraintWidth = [NSLayoutConstraint constraintWithItem:self.webview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    
    [self addConstraints:@[insideLabelConstraintLeftMargin, insideLabelConstraintTopMargin, insideLabelConstraintHeight, insideLabelConstraintWidth]];
}


#pragma mark - Tags for automatic testing
-(void) setAllTags {
    if (self.webview.tag == 0) {
        [self.webview setTag:TAG_MFWEBVIEW_WEBVIEW];
    }
    if (self.spinner.tag == 0) {
        [self.spinner setTag:TAG_MFWEBVIEW_SPINNER];
    }
}

#pragma mark - Méthodes de gestion du label

+(NSString *)getDataType {
    return @"NSString";
}

-(id)getData {
    return self.webview.request.URL.absoluteString;
}

/**
 * @brief Update the component with either the default url, or the one in the data
 */
-(void)setData:(id)data {

    //Initialisation
    NSURL *url =nil;
    BOOL isLocalSource = NO;
    NSString *baseStringUrl = nil;
    NSDictionary *componentParameters = ((MFFieldDescriptor *)self.selfDescriptor).parameters;
    
    //Vérification de la data et si la source est locale ou externe
    if(data && ![data isKindOfClass:[MFKeyNotFound class]]){
        baseStringUrl = data;
    }
    else if(componentParameters && [componentParameters objectForKey:DEFAULT_URL]) {
        baseStringUrl = [componentParameters objectForKey:DEFAULT_URL];
    }
    
    if(componentParameters && [componentParameters objectForKey:IS_LOCAL]) {
        isLocalSource = [[componentParameters objectForKey:IS_LOCAL] boolValue];
    }
    
    //traitement de l'URL
    if(isLocalSource) {
        NSArray *localSourceComponents = [baseStringUrl componentsSeparatedByString:@"."];
        if(localSourceComponents.count != 2) {
            [MFException throwExceptionWithName:@"MFWebView Error" andReason:@"You should specify a valid local file like \"index.html\"" andUserInfo:nil];
        }
        else {
            NSString *fileName = [localSourceComponents objectAtIndex:0];
            NSString *fileExtension = [localSourceComponents objectAtIndex:1];
            url = [[NSBundle mainBundle] URLForResource:fileName withExtension:fileExtension];
        }
    }
    else {
        if ([baseStringUrl rangeOfString:@"://"].location == NSNotFound) {
            baseStringUrl = [@"http://"stringByAppendingString:baseStringUrl];
        }
        url = [NSURL URLWithString:baseStringUrl];
    }
    
    //Affichage
    if(url!=nil){
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [self.webview loadRequest:urlRequest];
    }
    else{
        [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    }
}



#pragma mark - Webview methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(!self.isLoading) {
        self.isLoading = YES;
        if((!self.HUD ||self.HUD.alpha==0) && self.cellContainer){
            self.HUD = [MBProgressHUD showHUDAddedTo:((MFCellAbstract *)(self.cellContainer)) animated:YES];
            self.HUD.mode = MBProgressHUDModeIndeterminate;
        }
        
        // for timeout
        if(timer != nil){
            [timer invalidate];
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(cancelWeb) userInfo:nil repeats:NO];
    }
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(self.HUD.alpha==1){
        [self.HUD hide:YES];
    }
    // for timeout
    if(timer != nil){
        [timer invalidate];
    }
    
    for (UIView* subview in self.webview.subviews) {
        if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
            ((UIScrollView *)subview).bounces = NO;
            ((UIScrollView *)subview).alwaysBounceVertical = NO;
            ((UIScrollView *)subview).alwaysBounceHorizontal = NO;
        }
    }
    
    self.isLoading = NO;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if(self.HUD.alpha==1){
        [self.HUD hide:YES];
    }
    // load error, hide the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // report the error inside the webview
    NSString* errorString = [NSString stringWithFormat: @"[MFWebView] didFailLoadWithError() - Error in your request : %@", error.localizedDescription];

    MFUILogInfo(errorString, @"");
    
    self.isLoading = NO;
}

/**
 * @brief timeout function
 */
- (void)cancelWeb
{
    if(self.HUD.alpha==1){
        [self.HUD hide:YES];
    }
    // for timeout
    if(timer != nil){
        [timer invalidate];
    }
    MFUILogInfo(@"didn't finish loading within 10 sec");
}

-(void)setEditable:(NSNumber *)editable {
    //Rien a faire.
    //On ne souhaite pas faire le super qui rend le composant non interactif (userInteractionEnbaled =NO)
}

@end
