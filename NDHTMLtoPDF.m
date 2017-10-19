//
//  NDHTMLtoPDF.m
//  Nurves
//
//  Created by Clement Wehrung on 31/10/12.
//  Copyright (c) 2012-2014 Clement Wehrung. All rights reserved.
//
//  Released under the MIT license
//
//  Contact cwehrung@nurves.com for any question. 
//
//  Sources : http://www.labs.saachitech.com/2012/10/23/pdf-generation-using-uiprintpagerenderer/
//  Addons : http://developer.apple.com/library/ios/#samplecode/PrintWebView/Listings/MyPrintPageRenderer_m.html#//apple_ref/doc/uid/DTS40010311-MyPrintPageRenderer_m-DontLinkElementID_7

#import "NDHTMLtoPDF.h"
#import <WebKit/WebKit.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation NDHTMLConfiguration

- (instancetype)initWithPageSize:(CGSize)pageSize pageMargins:(UIEdgeInsets)pageMargins renderingEngine:(NDHTMLRenderingEngine)renderingEngine {
    if (self = [super init]) {
        self.pageSize = pageSize;
        self.pageMargins = pageMargins;
        self.renderingEngine = renderingEngine;
    }
    return self;
}

@end

@interface NDHTMLtoPDF ()<WKNavigationDelegate, UIWebViewDelegate>

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSString *HTML;
@property (nonatomic, strong) NSString *PDFpath;
@property (nonatomic, strong) NSData *PDFdata;
@property (nonatomic, strong) WKWebView *wkWebview;
@property (nonatomic, strong) UIWebView *uiWebview;
@property (nonatomic, strong) NDHTMLConfiguration *configuration;

@end

@interface UIPrintPageRenderer (PDF)

- (NSData*) printToPDF;

@end

@implementation NDHTMLtoPDF

@synthesize URL=_URL,wkWebview=_wkWebview,uiWebview=_uiWebview,delegate=_delegate,PDFpath=_PDFpath,configuration=_configuration;

// Create PDF by passing in the URL to a webpage
+ (id)createPDFWithURL:(NSURL*)URL pathForPDF:(NSString*)PDFpath delegate:(id <NDHTMLtoPDFDelegate>)delegate configuration:(NDHTMLConfiguration *)configuration
{
    NDHTMLtoPDF *creator = [[NDHTMLtoPDF alloc] initWithURL:URL delegate:delegate pathForPDF:PDFpath configuration:configuration];
    
    return creator;
}

// Create PDF by passing in the HTML as a String
+ (id)createPDFWithHTML:(NSString*)HTML pathForPDF:(NSString*)PDFpath delegate:(id <NDHTMLtoPDFDelegate>)delegate
               configuration:(NDHTMLConfiguration *)configuration
{
    NDHTMLtoPDF *creator = [[NDHTMLtoPDF alloc] initWithHTML:HTML baseURL:nil delegate:delegate pathForPDF:PDFpath configuration:configuration];
    
    return creator;
}

// Create PDF by passing in the HTML as a String, with a base URL
+ (id)createPDFWithHTML:(NSString*)HTML baseURL:(NSURL*)baseURL pathForPDF:(NSString*)PDFpath delegate:(id <NDHTMLtoPDFDelegate>)delegate
               configuration:(NDHTMLConfiguration *)configuration
{
    NDHTMLtoPDF *creator = [[NDHTMLtoPDF alloc] initWithHTML:HTML baseURL:baseURL delegate:delegate pathForPDF:PDFpath configuration:configuration];
    
    return creator;
}
+ (id)createPDFWithURL:(NSURL*)URL pathForPDF:(NSString*)PDFpath configuration:(NDHTMLConfiguration *)configuration successBlock:(NDHTMLtoPDFCompletionBlock)successBlock errorBlock:(NDHTMLtoPDFCompletionBlock)errorBlock
{
    NDHTMLtoPDF *creator = [[NDHTMLtoPDF alloc] initWithURL:URL delegate:nil pathForPDF:PDFpath configuration:configuration];
    creator.successBlock = successBlock;
    creator.errorBlock = errorBlock;
    
    return creator;
}

+ (id)createPDFWithHTML:(NSString*)HTML pathForPDF:(NSString*)PDFpath configuration:(NDHTMLConfiguration *)configuration successBlock:(NDHTMLtoPDFCompletionBlock)successBlock errorBlock:(NDHTMLtoPDFCompletionBlock)errorBlock
{
    NDHTMLtoPDF *creator = [[NDHTMLtoPDF alloc] initWithHTML:HTML baseURL:nil delegate:nil pathForPDF:PDFpath configuration:configuration];
    creator.successBlock = successBlock;
    creator.errorBlock = errorBlock;
    
    return creator;
}

+ (id)createPDFWithHTML:(NSString*)HTML baseURL:(NSURL*)baseURL pathForPDF:(NSString*)PDFpath configuration:(NDHTMLConfiguration *)configuration successBlock:(NDHTMLtoPDFCompletionBlock)successBlock errorBlock:(NDHTMLtoPDFCompletionBlock)errorBlock
{
    NDHTMLtoPDF *creator = [[NDHTMLtoPDF alloc] initWithHTML:HTML baseURL:baseURL delegate:nil pathForPDF:PDFpath configuration:configuration];
    creator.successBlock = successBlock;
    creator.errorBlock = errorBlock;
    
    return creator;
}

- (id)init
{
    if (self = [super init])
    {
        self.PDFdata = nil;
    }
    return self;
}

- (id)initWithURL:(NSURL*)URL delegate:(id <NDHTMLtoPDFDelegate>)delegate pathForPDF:(NSString*)PDFpath configuration:(NDHTMLConfiguration *)configuration
{
    if (self = [super init])
    {
        self.URL = URL;
        self.delegate = delegate;
        self.PDFpath = PDFpath;
                
        self.configuration = configuration;
        
        [self forceLoadView];
    }
    return self;
}

- (id)initWithHTML:(NSString*)HTML baseURL:(NSURL*)baseURL delegate:(id <NDHTMLtoPDFDelegate>)delegate
        pathForPDF:(NSString*)PDFpath configuration:(NDHTMLConfiguration *)configuration
{
    if (self = [super init])
    {
        self.HTML = HTML;
        self.URL = baseURL;
        self.delegate = delegate;
        self.PDFpath = PDFpath;
        
        self.configuration = configuration;

        [self forceLoadView];
    }
    return self;
}

- (void)forceLoadView
{
    [[UIApplication sharedApplication].delegate.window addSubview:self.view];
    
    self.view.frame = CGRectMake(0, 0, 1, 1);
    self.view.alpha = 0.0;
}

- (void)createWKWebView
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    self.wkWebview = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    self.wkWebview.navigationDelegate = self;

    [self.view addSubview:self.wkWebview];

    if (self.HTML == nil) {
        [self.wkWebview loadRequest:[NSURLRequest requestWithURL:self.URL]];
    }else{
        [self.wkWebview loadHTMLString:self.HTML baseURL:self.URL];
    }
}

- (void)createUIWebView
{
    self.uiWebview = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.uiWebview.delegate = self;
    [self.view addSubview:self.uiWebview];

    if (self.HTML == nil) {
        [self.uiWebview loadRequest:[NSURLRequest requestWithURL:self.URL]];
    }else{
        [self.uiWebview loadHTMLString:self.HTML baseURL:self.URL];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    BOOL useWKWebView = NO;
    if (self.configuration.renderingEngine == NDHTMLRenderingEngineWKWebView)
    {
        useWKWebView = YES;
    }
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10") && self.configuration.renderingEngine == NDHTMLRenderingEngineAuto)
    {
        useWKWebView = YES;
    }

    if (useWKWebView)
    {
        [self createWKWebView];
    }
    else
    {
        [self createUIWebView];
    }
}

- (void)didFinishLoad:(UIView *)webView
{
    UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc] init];

    [render addPrintFormatter:webView.viewPrintFormatter startingAtPageAtIndex:0];

    CGRect printableRect = CGRectMake(self.configuration.pageMargins.left,
                                      self.configuration.pageMargins.top,
                                      self.configuration.pageSize.width - self.configuration.pageMargins.left - self.configuration.pageMargins.right,
                                      self.configuration.pageSize.height - self.configuration.pageMargins.top - self.configuration.pageMargins.bottom);

    CGRect paperRect = CGRectMake(0, 0, self.configuration.pageSize.width, self.configuration.pageSize.height);

    [render setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"];
    [render setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];

    self.PDFdata = [render printToPDF];

    if (self.PDFpath) {
        [self.PDFdata writeToFile: self.PDFpath  atomically: YES];
    }

    [self terminateWebTask];

    if (self.delegate && [self.delegate respondsToSelector:@selector(HTMLtoPDFDidSucceed:)])
        [self.delegate HTMLtoPDFDidSucceed:self];

    if(self.successBlock) {
        self.successBlock(self);
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.isLoading) return;
    [self didFinishLoad:webView];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (webView.isLoading) return;
    [self didFinishLoad:webView];
}

- (void)didFailToLoad
{
    [self terminateWebTask];

    if (self.delegate && [self.delegate respondsToSelector:@selector(HTMLtoPDFDidFail:)])
        [self.delegate HTMLtoPDFDidFail:self];

    if(self.errorBlock) {
        self.errorBlock(self);
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (webView.isLoading) return;
    [self didFailToLoad];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (webView.isLoading) return;
    [self didFailToLoad];
}

- (void)terminateWebTask
{
    [self.wkWebview stopLoading];
    self.wkWebview.navigationDelegate = nil;
    [self.wkWebview removeFromSuperview];

    [self.uiWebview stopLoading];
    self.uiWebview.delegate = nil;
    [self.uiWebview removeFromSuperview];
    
    [self.view removeFromSuperview];
    
    self.wkWebview = nil;
    self.uiWebview = nil;
}

@end

@implementation UIPrintPageRenderer (PDF)

- (NSData*) printToPDF
{
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData( pdfData, self.paperRect, nil );
        
    [self prepareForDrawingPages: NSMakeRange(0, self.numberOfPages)];
    
    CGRect bounds = UIGraphicsGetPDFContextBounds();
        
    for ( int i = 0 ; i < self.numberOfPages ; i++ )
    {
        UIGraphicsBeginPDFPage();
        
        [self drawPageAtIndex: i inRect: bounds];
    }
    
    UIGraphicsEndPDFContext();
        
    return pdfData;
}

@end
