//
//  NDHTMLtoPDF.h
//  Nurves
//
//  Created by Clement Wehrung on 31/10/12.
//  Copyright (c) 2012-2014 Clement Wehrung. All rights reserved.
//
//  Released under the MIT license

#import <UIKit/UIKit.h>

#define kPaperSizeA4 CGSizeMake(595.2,841.8)
#define kPaperSizeLetter CGSizeMake(612,792)

typedef NS_ENUM(NSUInteger, NDHTMLRenderingEngine) {
    NDHTMLRenderingEngineAuto,
    NDHTMLRenderingEngineUIWebView,
    NDHTMLRenderingEngineWKWebView
};

@interface NDHTMLConfiguration: NSObject

@property (nonatomic) CGSize pageSize;
@property (nonatomic) UIEdgeInsets pageMargins;
@property (nonatomic) NDHTMLRenderingEngine renderingEngine;

- (instancetype)initWithPageSize:(CGSize)pageSize pageMargins:(UIEdgeInsets)pageMargins renderingEngine:(NDHTMLRenderingEngine)renderingEngine;

@end

@class NDHTMLtoPDF;

typedef void (^NDHTMLtoPDFCompletionBlock)(NDHTMLtoPDF* htmlToPDF);

@protocol NDHTMLtoPDFDelegate <NSObject>

@optional
- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF;
- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF;
@end

@interface NDHTMLtoPDF : UIViewController

@property (nonatomic, copy) NDHTMLtoPDFCompletionBlock successBlock;
@property (nonatomic, copy) NDHTMLtoPDFCompletionBlock errorBlock;

@property (nonatomic, weak) id <NDHTMLtoPDFDelegate> delegate;

@property (nonatomic, strong, readonly) NSString *PDFpath;
@property (nonatomic, strong, readonly) NSData *PDFdata;

+ (id)createPDFWithURL:(NSURL*)URL pathForPDF:(NSString*)PDFpath delegate:(id <NDHTMLtoPDFDelegate>)delegate configuration:(NDHTMLConfiguration *)configuration;
+ (id)createPDFWithHTML:(NSString*)HTML pathForPDF:(NSString*)PDFpath delegate:(id <NDHTMLtoPDFDelegate>)delegate configuration:(NDHTMLConfiguration *)configuration;
+ (id)createPDFWithHTML:(NSString*)HTML baseURL:(NSURL*)baseURL pathForPDF:(NSString*)PDFpath delegate:(id <NDHTMLtoPDFDelegate>)delegate configuration:(NDHTMLConfiguration *)configuration;

+ (id)createPDFWithURL:(NSURL*)URL pathForPDF:(NSString*)PDFpath configuration:(NDHTMLConfiguration *)configuration successBlock:(NDHTMLtoPDFCompletionBlock)successBlock errorBlock:(NDHTMLtoPDFCompletionBlock)errorBlock;
+ (id)createPDFWithHTML:(NSString*)HTML pathForPDF:(NSString*)PDFpath configuration:(NDHTMLConfiguration *)configuration successBlock:(NDHTMLtoPDFCompletionBlock)successBlock errorBlock:(NDHTMLtoPDFCompletionBlock)errorBlock;
+ (id)createPDFWithHTML:(NSString*)HTML baseURL:(NSURL*)baseURL pathForPDF:(NSString*)PDFpath configuration:(NDHTMLConfiguration *)configuration successBlock:(NDHTMLtoPDFCompletionBlock)successBlock errorBlock:(NDHTMLtoPDFCompletionBlock)errorBlock;
@end
