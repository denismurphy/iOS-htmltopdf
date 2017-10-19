//
//  NDViewController.m
//  HTMLtoPDF-Demo
//
//  Created by Clément Wehrung on 12/11/12.
//  Copyright (c) 2012 Nurves. All rights reserved.
//

#import "NDViewController.h"

@interface NDViewController ()

@end

@implementation NDViewController

@synthesize PDFCreator;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark Button Actions

- (IBAction)generatePDFUsingDelegate:(id)sender
{
    self.resultLabel.text = @"loading...";

    NDHTMLConfiguration *configuration = [[NDHTMLConfiguration alloc] initWithPageSize:kPaperSizeA4 pageMargins:UIEdgeInsetsMake(10, 5, 10, 5) renderingEngine:NDHTMLRenderingEngineWKWebView];
    
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[NSURL URLWithString:@"https://edition.cnn.com/2012/11/12/business/china-consumer-economy/index.html?hpt=hp_c1"]
                                         pathForPDF:[@"~/Documents/delegateDemo.pdf" stringByExpandingTildeInPath]
                                           delegate:self
                                      configuration:configuration];
}

- (IBAction)generatePDFUsingBlocks:(id)sender
{
    self.resultLabel.text = @"loading...";

    NDHTMLConfiguration *configuration = [[NDHTMLConfiguration alloc] initWithPageSize:kPaperSizeA4 pageMargins:UIEdgeInsetsMake(10, 5, 10, 5) renderingEngine:NDHTMLRenderingEngineUIWebView];
    
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:[NSURL URLWithString:@"https://edition.cnn.com/2013/09/19/opinion/rushkoff-apple-ios-baby-steps/index.html"] pathForPDF:[@"~/Documents/blocksDemo.pdf" stringByExpandingTildeInPath] configuration:configuration successBlock:^(NDHTMLtoPDF *htmlToPDF) {
        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
        NSLog(@"%@",result);
        self.resultLabel.text = result;
    } errorBlock:^(NDHTMLtoPDF *htmlToPDF) {
        NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
        NSLog(@"%@",result);
        self.resultLabel.text = result;
    }];
}

#pragma mark NDHTMLtoPDFDelegate

- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
{
    NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
    NSLog(@"%@",result);
    self.resultLabel.text = result;
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
{
    NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
    NSLog(@"%@",result);
    self.resultLabel.text = result;
}

@end
