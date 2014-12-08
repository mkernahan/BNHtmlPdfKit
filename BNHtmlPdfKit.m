//
//  BNHtmlPdfKit.m
//
//  Created by Brent Nycum.
//  Copyright (c) 2013 Brent Nycum. All rights reserved.
//

#import "BNHtmlPdfKit.h"

static float const PPI = 72.0f;

#pragma mark - BNHtmlPdfKitPageRenderer Interface

@interface BNHtmlPdfKitPageRenderer : UIPrintPageRenderer

@property (nonatomic, assign) CGFloat topAndBottomMarginSize;
@property (nonatomic, assign) CGFloat leftAndRightMarginSize;

@end


#pragma mark - BNHtmlPdfKitPageRenderer Implementation

@implementation BNHtmlPdfKitPageRenderer

- (CGRect)paperRect {
	return UIGraphicsGetPDFContextBounds();
}

- (CGRect)printableRect {
	return CGRectInset([self paperRect], self.leftAndRightMarginSize, self.topAndBottomMarginSize);
}

@end


#pragma mark - BNHtmlPdfKit Extension

@interface BNHtmlPdfKit () <UIWebViewDelegate>

- (CGSize)_sizeFromPageSize:(BNPageSize)pageSize;

- (void)_timeout;
- (void)_savePdf;

@property (nonatomic, copy) NSString *outputFile;
@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, copy) void (^dataCompletionBlock)(NSData *pdfData);
@property (nonatomic, copy) void (^fileCompletionBlock)(NSString *pdfFileName);
@property (nonatomic, copy) void (^failureBlock)(NSError * error);

@end

#pragma mark - BNHtmlPdfKit Implementation

@implementation BNHtmlPdfKit

+ (BNHtmlPdfKit *)saveUrlAsPdf:(NSURL *)url success:(void (^)(NSData *pdfData))completion failure:(void (^)(NSError *error))failure {

	return [BNHtmlPdfKit saveUrlAsPdf:url pageSize:[BNHtmlPdfKit defaultPageSize] isLandscape:NO success:completion failure:failure];

}

+ (BNHtmlPdfKit *)saveUrlAsPdf:(NSURL *)url pageSize:(BNPageSize)pageSize success:(void (^)(NSData *pdfData))completion failure:(void (^)(NSError *error))failure {

	return [BNHtmlPdfKit saveUrlAsPdf:url pageSize:pageSize isLandscape:NO success:completion failure:failure];

}

+ (BNHtmlPdfKit *)saveUrlAsPdf:(NSURL *)url pageSize:(BNPageSize)pageSize isLandscape:(BOOL)landscape success:(void (^)(NSData *pdfData))completion failure:(void (^)(NSError *error))failure {

	BNHtmlPdfKit *pdfKit = [[BNHtmlPdfKit alloc] initWithPageSize:pageSize isLandscape:landscape];
	pdfKit.dataCompletionBlock = completion;
	pdfKit.failureBlock = failure;
	[pdfKit saveUrlAsPdf:url toFile:nil];
	return pdfKit;

}

+ (BNHtmlPdfKit *)saveUrlAsPdf:(NSURL *)url pageSize:(BNPageSize)pageSize isLandscape:(BOOL)landscape topAndBottomMarginSize:(CGFloat)topAndBottom leftAndRightMarginSize:(CGFloat)leftAndRight success:(void (^)(NSData *pdfData))completion failure:(void (^)(NSError *error))failure {

	BNHtmlPdfKit *pdfKit = [[BNHtmlPdfKit alloc] initWithPageSize:pageSize isLandscape:landscape];
	pdfKit.topAndBottomMarginSize = topAndBottom;
	pdfKit.leftAndRightMarginSize = leftAndRight;
	pdfKit.dataCompletionBlock = completion;
	pdfKit.failureBlock = failure;
	[pdfKit saveUrlAsPdf:url toFile:nil];
	return pdfKit;

}

+ (BNHtmlPdfKit *)saveUrlAsPdf:(NSURL *)url toFile:(NSString *)filename success:(void (^)(NSString *filename))completion failure:(void (^)(NSError *error))failure {

	return [BNHtmlPdfKit saveUrlAsPdf:url toFile:filename pageSize:[BNHtmlPdfKit defaultPageSize] isLandscape:NO success:completion failure:failure];

}

+ (BNHtmlPdfKit *)saveUrlAsPdf:(NSURL *)url toFile:(NSString *)filename pageSize:(BNPageSize)pageSize success:(void (^)(NSString *filename))completion failure:(void (^)(NSError *error))failure {

	return [BNHtmlPdfKit saveUrlAsPdf:url toFile:filename pageSize:pageSize isLandscape:NO success:completion failure:failure];

}

+ (BNHtmlPdfKit *)saveUrlAsPdf:(NSURL *)url toFile:(NSString *)filename pageSize:(BNPageSize)pageSize isLandscape:(BOOL)landscape success:(void (^)(NSString *filename))completion failure:(void (^)(NSError *error))failure {

	BNHtmlPdfKit *pdfKit = [[BNHtmlPdfKit alloc] initWithPageSize:pageSize isLandscape:landscape];
	pdfKit.fileCompletionBlock = completion;
	pdfKit.failureBlock = failure;
	[pdfKit saveUrlAsPdf:url toFile:filename];
	return pdfKit;

}

+ (BNHtmlPdfKit *)saveUrlAsPdf:(NSURL *)url toFile:(NSString *)filename pageSize:(BNPageSize)pageSize isLandscape:(BOOL)landscape topAndBottomMarginSize:(CGFloat)topAndBottom leftAndRightMarginSize:(CGFloat)leftAndRight success:(void (^)(NSString *filename))completion failure:(void (^)(NSError *error))failure {

	BNHtmlPdfKit *pdfKit = [[BNHtmlPdfKit alloc] initWithPageSize:pageSize isLandscape:landscape];
	pdfKit.topAndBottomMarginSize = topAndBottom;
	pdfKit.leftAndRightMarginSize = leftAndRight;
	pdfKit.fileCompletionBlock = completion;
	pdfKit.failureBlock = failure;
	[pdfKit saveUrlAsPdf:url toFile:filename];
	return pdfKit;

}

+ (BNHtmlPdfKit *)saveUrlAsPdf:(NSURL *)url customPageSize:(CGSize)pageSize success:(void (^)(NSData *pdfData))completion failure:(void (^)(NSError *error))failure {

	BNHtmlPdfKit *pdfKit = [[BNHtmlPdfKit alloc] initWithCustomPageSize:pageSize];
	pdfKit.dataCompletionBlock = completion;
	pdfKit.failureBlock = failure;
	[pdfKit saveUrlAsPdf:url toFile:nil];
	return pdfKit;

}

+ (BNHtmlPdfKit *)saveUrlAsPdf:(NSURL *)url customPageSize:(CGSize)pageSize topAndBottomMarginSize:(CGFloat)topAndBottom leftAndRightMarginSize:(CGFloat)leftAndRight success:(void (^)(NSData *pdfData))completion failure:(void (^)(NSError *error))failure {

	BNHtmlPdfKit *pdfKit = [[BNHtmlPdfKit alloc] initWithCustomPageSize:pageSize];
	pdfKit.topAndBottomMarginSize = topAndBottom;
	pdfKit.leftAndRightMarginSize = leftAndRight;
	pdfKit.dataCompletionBlock = completion;
	pdfKit.failureBlock = failure;
	[pdfKit saveUrlAsPdf:url toFile:nil];
	return pdfKit;

}

+ (BNHtmlPdfKit *)saveUrlAsPdf:(NSURL *)url toFile:(NSString *)filename customPageSize:(CGSize)pageSize success:(void (^)(NSString *filename))completion failure:(void (^)(NSError *error))failure {

	BNHtmlPdfKit *pdfKit = [[BNHtmlPdfKit alloc] initWithCustomPageSize:pageSize];
	pdfKit.fileCompletionBlock = completion;
	pdfKit.failureBlock = failure;
	[pdfKit saveUrlAsPdf:url toFile:filename];
	return pdfKit;

}

+ (BNHtmlPdfKit *)saveUrlAsPdf:(NSURL *)url toFile:(NSString *)filename customPageSize:(CGSize)pageSize topAndBottomMarginSize:(CGFloat)topAndBottom leftAndRightMarginSize:(CGFloat)leftAndRight success:(void (^)(NSString *filename))completion failure:(void (^)(NSError *error))failure {

	BNHtmlPdfKit *pdfKit = [[BNHtmlPdfKit alloc] initWithCustomPageSize:pageSize];
	pdfKit.topAndBottomMarginSize = topAndBottom;
	pdfKit.leftAndRightMarginSize = leftAndRight;
	pdfKit.fileCompletionBlock = completion;
	pdfKit.failureBlock = failure;
	[pdfKit saveUrlAsPdf:url toFile:filename];
	return pdfKit;

}

#pragma mark - Initializers

- (id)initWithPageSize:(BNPageSize)pageSize customPageSize:(CGSize)customPageSize isLandscape:(BOOL)landscape {
    if (self = [super init]) {
        self.pageSize = pageSize;
        self.customPageSize = customPageSize;
        self.landscape = landscape;
        
        // Default 1/4" margins
        self.topAndBottomMarginSize = 0.25f * PPI;
        self.leftAndRightMarginSize = 0.25f * PPI;
    }
    return self;
}

- (id)init {
    return [self initWithPageSize:[BNHtmlPdfKit defaultPageSize] customPageSize:CGSizeZero isLandscape:NO];
}

- (id)initWithPageSize:(BNPageSize)pageSize {
    return [self initWithPageSize:pageSize customPageSize:CGSizeZero isLandscape:NO];
}

- (id)initWithPageSize:(BNPageSize)pageSize isLandscape:(BOOL)landscape {
    return [self initWithPageSize:pageSize customPageSize:CGSizeZero isLandscape:landscape];
}

- (id)initWithCustomPageSize:(CGSize)pageSize {
    return [self initWithPageSize:BNPageSizeCustom customPageSize:pageSize isLandscape:NO];
}

- (void)dealloc {
	[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeout) object:nil];

	[self.webView setDelegate:nil];
	[self.webView stopLoading];
}

#pragma mark - Class Methods

+ (CGSize) bnSizeMakeWithPaperWidth:(CGFloat)paperWidth height:(CGFloat)paperHeight ppi:(CGFloat)ppi
{
    return CGSizeMake(paperWidth * ppi, paperHeight * ppi);
}

+ (CGSize) bnSizeMakeWithPaperWidth:(CGFloat)paperWidth height:(CGFloat)paperHeight
{
    return [self bnSizeMakeWithPaperWidth:paperWidth height:paperHeight ppi:PPI];
}

+ (CGSize)sizeForPageSize:(BNPageSize)pageSize {
	switch (pageSize) {
		case BNPageSizeLetter:
            return [self bnSizeMakeWithPaperWidth:8.5f height:11.0f];
		case BNPageSizeGovernmentLetter:
			return [self bnSizeMakeWithPaperWidth:8.0f height:10.5f];
		case BNPageSizeLegal:
			return [self bnSizeMakeWithPaperWidth:8.5f height:14.0f];
		case BNPageSizeJuniorLegal:
			return [self bnSizeMakeWithPaperWidth:8.5f height:5.0f];
		case BNPageSizeLedger:
			return [self bnSizeMakeWithPaperWidth:17.0f height:11.0f];
		case BNPageSizeTabloid:
			return [self bnSizeMakeWithPaperWidth:11.0f height:17.0f];
		case BNPageSizeA0:
			return [self bnSizeMakeWithPaperWidth:33.11f height:46.81f];
		case BNPageSizeA1:
			return [self bnSizeMakeWithPaperWidth:23.39f height:33.11f];
		case BNPageSizeA2:
			return [self bnSizeMakeWithPaperWidth:16.54f height:23.39f];
		case BNPageSizeA3:
			return [self bnSizeMakeWithPaperWidth:11.69f height:16.54f];
		case BNPageSizeA4:
			return [self bnSizeMakeWithPaperWidth:8.26666667 height:11.6916667];
		case BNPageSizeA5:
			return [self bnSizeMakeWithPaperWidth:5.83f height:8.27f];
		case BNPageSizeA6:
			return [self bnSizeMakeWithPaperWidth:4.13f height:5.83f];
		case BNPageSizeA7:
			return [self bnSizeMakeWithPaperWidth:2.91f height:4.13f];
		case BNPageSizeA8:
			return [self bnSizeMakeWithPaperWidth:2.05f height:2.91f];
		case BNPageSizeA9:
			return [self bnSizeMakeWithPaperWidth:1.46f height:2.05f];
		case BNPageSizeA10:
			return [self bnSizeMakeWithPaperWidth:1.02f height:1.46f];
		case BNPageSizeB0:
			return [self bnSizeMakeWithPaperWidth:39.37f height:55.67f];
		case BNPageSizeB1:
			return [self bnSizeMakeWithPaperWidth:27.83f height:39.37f];
		case BNPageSizeB2:
			return [self bnSizeMakeWithPaperWidth:19.69f height:27.83f];
		case BNPageSizeB3:
			return [self bnSizeMakeWithPaperWidth:13.90f height:19.69f];
		case BNPageSizeB4:
			return [self bnSizeMakeWithPaperWidth:9.84f height:13.90f];
		case BNPageSizeB5:
			return [self bnSizeMakeWithPaperWidth:6.93f height:9.84f];
		case BNPageSizeB6:
			return [self bnSizeMakeWithPaperWidth:4.92f height:6.93f];
		case BNPageSizeB7:
			return [self bnSizeMakeWithPaperWidth:3.46f height:4.92f];
		case BNPageSizeB8:
			return [self bnSizeMakeWithPaperWidth:2.44f height:3.46f];
		case BNPageSizeB9:
			return [self bnSizeMakeWithPaperWidth:1.73f height:2.44f];
		case BNPageSizeB10:
			return [self bnSizeMakeWithPaperWidth:1.22f height:1.73f];
		case BNPageSizeC0:
			return [self bnSizeMakeWithPaperWidth:36.10f height:51.06f];
		case BNPageSizeC1:
			return [self bnSizeMakeWithPaperWidth:25.51f height:36.10f];
		case BNPageSizeC2:
			return [self bnSizeMakeWithPaperWidth:18.03f height:25.51f];
		case BNPageSizeC3:
			return [self bnSizeMakeWithPaperWidth:12.76f height:18.03f];
		case BNPageSizeC4:
			return [self bnSizeMakeWithPaperWidth:9.02f height:12.76f];
		case BNPageSizeC5:
			return [self bnSizeMakeWithPaperWidth:6.38f height:9.02f];
		case BNPageSizeC6:
			return [self bnSizeMakeWithPaperWidth:4.49f height:6.38f];
		case BNPageSizeC7:
			return [self bnSizeMakeWithPaperWidth:3.19f height:4.49f];
		case BNPageSizeC8:
			return [self bnSizeMakeWithPaperWidth:2.24f height:3.19f];
		case BNPageSizeC9:
			return [self bnSizeMakeWithPaperWidth:1.57f height:2.24f];
		case BNPageSizeC10:
			return [self bnSizeMakeWithPaperWidth:1.10f height:1.57f];
		case BNPageSizeJapaneseB0:
			return [self bnSizeMakeWithPaperWidth:40.55f height:57.32f];
		case BNPageSizeJapaneseB1:
			return [self bnSizeMakeWithPaperWidth:28.66f height:40.55f];
		case BNPageSizeJapaneseB2:
			return [self bnSizeMakeWithPaperWidth:20.28f height:28.66f];
		case BNPageSizeJapaneseB3:
			return [self bnSizeMakeWithPaperWidth:14.33f height:20.28f];
		case BNPageSizeJapaneseB4:
			return [self bnSizeMakeWithPaperWidth:10.12f height:14.33f];
		case BNPageSizeJapaneseB5:
			return [self bnSizeMakeWithPaperWidth:7.17f height:10.12f];
		case BNPageSizeJapaneseB6:
			return [self bnSizeMakeWithPaperWidth:5.04f height:7.17f];
		case BNPageSizeJapaneseB7:
			return [self bnSizeMakeWithPaperWidth:3.58f height:5.04f];
		case BNPageSizeJapaneseB8:
			return [self bnSizeMakeWithPaperWidth:2.52f height:3.58f];
		case BNPageSizeJapaneseB9:
			return [self bnSizeMakeWithPaperWidth:1.77f height:2.52f];
		case BNPageSizeJapaneseB10:
			return [self bnSizeMakeWithPaperWidth:1.26f height:1.77f];
		case BNPageSizeJapaneseB11:
			return [self bnSizeMakeWithPaperWidth:0.87f height:1.26f];
		case BNPageSizeJapaneseB12:
			return [self bnSizeMakeWithPaperWidth:0.63f height:0.87f];
		case BNPageSizeCustom:
			return CGSizeZero;
	}
	return CGSizeZero;
}

#pragma mark - Methods

- (CGSize)actualPageSize {
	if (self.landscape) {
		CGSize pageSize = [self _sizeFromPageSize:self.pageSize];
		return CGSizeMake(pageSize.height, pageSize.width);
	}
	return [self _sizeFromPageSize:self.pageSize];
}

- (void)saveHtmlAsPdf:(NSString *)html {
	[self saveHtmlAsPdf:html toFile:nil];
}

- (void)saveHtmlAsPdf:(NSString *)html toFile:(NSString *)file {
	self.outputFile = file;

	self.webView = [[UIWebView alloc] init];
	self.webView.delegate = self;

	if (!self.baseUrl) {
		[self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://localhost"]];
	} else {
		[self.webView loadHTMLString:html baseURL:self.baseUrl];
	}
}

- (void)saveUrlAsPdf:(NSURL *)url {
	[self saveUrlAsPdf:url toFile:nil];
}

- (void)saveUrlAsPdf:(NSURL *)url toFile:(NSString *)file {
	self.outputFile = file;

	self.webView = [[UIWebView alloc] init];
	self.webView.delegate = self;

	if ([self.webView respondsToSelector:@selector(setSuppressesIncrementalRendering:)]) {
		[self.webView setSuppressesIncrementalRendering:YES];
	}

	[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)saveWebViewAsPdf:(UIWebView *)webView {
	[self saveWebViewAsPdf:webView toFile:nil];
}

- (void)saveWebViewAsPdf:(UIWebView *)webView toFile:(NSString *)file {
	[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeout) object:nil];

	self.outputFile = file;

	webView.delegate = self;

	self.webView = webView;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
	BOOL complete = [readyState isEqualToString:@"complete"];

	[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeout) object:nil];

	if (complete) {
		[self _savePdf];
	} else {
		[self performSelector:@selector(_timeout) withObject:nil afterDelay:1.0f];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeout) object:nil];

	if (self.failureBlock) {
		self.failureBlock(error);
	}

	if ([self.delegate respondsToSelector:@selector(htmlPdfKit:didFailWithError:)]) {
		[self.delegate htmlPdfKit:self didFailWithError:error];
	}

	self.webView = nil;
}

#pragma mark - Private Methods

- (void)_timeout {
	[self _savePdf];
}

- (void)_savePdf {
	if (!self.webView) {
		return;
	}

	UIPrintFormatter *formatter = self.webView.viewPrintFormatter;

	BNHtmlPdfKitPageRenderer *renderer = [[BNHtmlPdfKitPageRenderer alloc] init];
	renderer.topAndBottomMarginSize = self.topAndBottomMarginSize;
	renderer.leftAndRightMarginSize = self.leftAndRightMarginSize;

	[renderer addPrintFormatter:formatter startingAtPageAtIndex:0];

	NSMutableData *currentReportData = [NSMutableData data];

	CGSize pageSize = [self actualPageSize];
	CGRect pageRect = CGRectMake(0, 0, pageSize.width, pageSize.height);

	UIGraphicsBeginPDFContextToData(currentReportData, pageRect, nil);

	[renderer prepareForDrawingPages:NSMakeRange(0, 1)];

	NSInteger pages = [renderer numberOfPages];

	for (NSInteger i = 0; i < pages; i++) {
		UIGraphicsBeginPDFPage();
		[renderer drawPageAtIndex:i inRect:renderer.paperRect];
	}

	UIGraphicsEndPDFContext();

	if (self.dataCompletionBlock) {
		self.dataCompletionBlock(currentReportData);
	}

	if (self.fileCompletionBlock) {
		self.fileCompletionBlock(self.outputFile);
	}

	if ([self.delegate respondsToSelector:@selector(htmlPdfKit:didSavePdfData:)]) {
		[self.delegate htmlPdfKit:self didSavePdfData:currentReportData];
	}

	if (self.outputFile) {
		[currentReportData writeToFile:self.outputFile atomically:YES];

		if ([self.delegate respondsToSelector:@selector(htmlPdfKit:didSavePdfFile:)]) {
			[self.delegate htmlPdfKit:self didSavePdfFile:self.outputFile];
		}
	}

	self.webView = nil;
}

- (CGSize)_sizeFromPageSize:(BNPageSize)pageSize {
	if (pageSize == BNPageSizeCustom) {
		return self.customPageSize;
	}

	return [BNHtmlPdfKit sizeForPageSize:pageSize];
}

+ (BNPageSize)defaultPageSize {
	NSLocale *locale = [NSLocale currentLocale];
	BOOL useMetric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
	BNPageSize pageSize = (useMetric ? BNPageSizeA4 : BNPageSizeLetter);

	return pageSize;
}

@end
