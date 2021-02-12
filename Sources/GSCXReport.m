//
// Copyright 2019 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "GSCXReport.h"

#import <WebKit/WebKit.h>

#import "GSCXReportContext.h"
#import "GSCXUtils.h"
#import "GTXHierarchyResultCollection+GSCXReport.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface GSCXReport () <WKNavigationDelegate>

/**
 * Invoked when an HTML report has been created. @c nil if a report has not begun being generated.
 * Must be non nil after a report begins being generated.
 */
@property(copy, nonatomic, nullable) GSCXHTMLReportCompletionBlock onComplete;

/**
 * Invoked when an HTML report fails to be created. @c nil if a report has not begun being
 * generated. Must be non nil after a report begins being generated.
 */
@property(copy, nonatomic, nullable) GSCXReportErrorBlock onError;

/**
 * Renders the report.
 */
@property(strong, nonatomic, nullable) WKWebView *helperWebview;

@end

@implementation GSCXReport

- (instancetype)initWithResults:(NSArray<GTXHierarchyResultCollection *> *)results {
  self = [super init];
  if (self) {
    _results = results;
  }
  return self;
}

/**
 * Begins generating an HTML report with the given results.
 *
 * @param onComplete Invoked when the report is created successfully.
 * @param onError Invoked if the report fails to be created.
 */
- (void)createHTMLReportWithCompletionBlock:(GSCXHTMLReportCompletionBlock)onComplete
                                 errorBlock:(GSCXReportErrorBlock)onError {
  GTX_ASSERT(onComplete, @"Report generation callback cannot be nil.");
  GTX_ASSERT(onError, @"Report generation error callback cannot be nil.");
  self.onComplete = onComplete;
  self.onError = onError;

  // Create a HTML file renders the PDF.
  GSCXReportContext *context = [[GSCXReportContext alloc] init];
  NSMutableArray<NSString *> *htmlSnippets = [NSMutableArray array];
  for (GTXHierarchyResultCollection *result in self.results) {
    [htmlSnippets addObject:[result htmlDescription:context]];
  }
  NSString *html = [htmlSnippets componentsJoinedByString:@""];
  NSURL *path = [[self class] gscx_createLocalSiteWithHTMLString:html context:context];

  // Create a 1 pixel webview but do not add it to the hierarchy, the webview will be used to render
  // PDF.
  CGRect webViewFrame = CGRectMake(0, 0, 1, 1);
  self.helperWebview = [[WKWebView alloc] initWithFrame:webViewFrame];
  self.helperWebview.navigationDelegate = self;

  [_helperWebview loadFileURL:[path URLByAppendingPathComponent:@"index.html"]
      allowingReadAccessToURL:path];
}

/**
 * Begins generating a PDF report with the given results.
 *
 * @param onComplete Invoked when the report is created successfully.
 * @param onError Invoked if the report fails to be created.
 */
- (void)createPDFReportWithCompletionBlock:(GSCXPDFReportCompletionBlock)onComplete
                                errorBlock:(GSCXReportErrorBlock)onError {
  [self
      createHTMLReportWithCompletionBlock:^(WKWebView *webView) {
        NSURL *url = [GSCXReport gscx_getPDFFromWebView:webView];
        onComplete(url);
      }
                               errorBlock:onError];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView
    didFinishNavigation:(null_unspecified WKNavigation *)navigation {
  self.onComplete(self.helperWebview);
  self.helperWebview = nil;
}

- (void)webView:(WKWebView *)webView
    didFailNavigation:(null_unspecified WKNavigation *)navigation
            withError:(NSError *)error {
  self.onError(error);
}

- (void)webView:(WKWebView *)webView
    didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation
                       withError:(NSError *)error {
  self.onError(error);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
  NSError *error = [NSError errorWithDomain:WKErrorDomain
                                       code:WKErrorWebContentProcessTerminated
                                   userInfo:nil];
  self.onError(error);
}

+ (void)createHTMLReport:(GSCXReport *)report
         completionBlock:(GSCXHTMLReportCompletionBlock)onComplete
              errorBlock:(nullable GSCXReportErrorBlock)onError {
  // Copy the report so the same report object can be used to generate multiple reports, even if
  // one is already in progress.
  __block GSCXReport *copiedReport = [[GSCXReport alloc] initWithResults:report.results];
  [copiedReport
      createHTMLReportWithCompletionBlock:^(WKWebView *webView) {
        onComplete(webView);
        // Capture copiedReport to create an intentional retain cycle. Without this, the GSCXReport
        // object will be deallocated when createHTMLReportWithCompletionBlock: terminates, because
        // it begins an asynchronous process on WKWebView. If no other object owns the GSCXReport,
        // there will be no strong references, and it will be deallocated. The web view's delegate
        // will then be nil, so the callbacks are not run and the report is never generated.
        // Creating a retain cycle keeps the report in memory until one of the callbacks runs.
        // Setting the variable to nil breaks the cycle. If no other objects reference the
        // GSCXReport object, it will be safely deallocated. Otherwise, the original owner will
        // maintain ownership.
        copiedReport = nil;
      }
      errorBlock:^(NSError *error) {
        if (onError) {
          onError(error);
        }
        copiedReport = nil;
      }];
}

+ (void)createPDFReport:(GSCXReport *)report
        completionBlock:(GSCXPDFReportCompletionBlock)onComplete
             errorBlock:(nullable GSCXReportErrorBlock)onError {
  __block GSCXReport *copiedReport = [[GSCXReport alloc] initWithResults:report.results];
  [copiedReport
      createPDFReportWithCompletionBlock:^(NSURL *reportURL) {
        onComplete(reportURL);
        copiedReport = nil;
      }
      errorBlock:^(NSError *error) {
        if (onError) {
          onError(error);
        }
        copiedReport = nil;
      }];
}

#pragma mark - Private

/**
 * Creates a local HTML page with the given context.
 */
+ (NSURL *)gscx_createLocalSiteWithHTMLString:(NSString *)html
                                      context:(GSCXReportContext *)context {
  // Create a temp directory to hold the local website.
  NSURL *temporaryDirectoryURL = [GSCXUtils uniqueTemporaryDirectoryURL];
  // Add an index.html which will be the home page with the given HTML.
  NSURL *indexURL = [temporaryDirectoryURL URLByAppendingPathComponent:@"index.html"];
  BOOL success = [[html dataUsingEncoding:NSUTF8StringEncoding] writeToURL:indexURL atomically:YES];
  (void)success;
  GTX_ASSERT(success, @"Could not write HTML data to file: %@", indexURL);

  // Add all the images into the temp directory
  [context forEachImageWithHandler:^(UIImage *image, NSString *filename) {
    NSURL *url = [temporaryDirectoryURL URLByAppendingPathComponent:filename];
    [UIImagePNGRepresentation(image) writeToURL:url atomically:YES];
  }];

  return temporaryDirectoryURL;
}

/**
 * Generates a PDF from the webpage in the given webview.
 */
+ (NSURL *)gscx_getPDFFromWebView:(UIView *)webView {
  // Prepare a PDF renderer.
  UIViewPrintFormatter *formatter = [webView viewPrintFormatter];
  UIPrintPageRenderer *renderer = [[UIPrintPageRenderer alloc] init];
  [renderer addPrintFormatter:formatter startingAtPageAtIndex:0];
  // @TODO Move away from pages and render whole report as a single long page to make
  // it easy to read on screens.
  CGRect A4PageRect = CGRectMake(0, 0, 595.2, 841.8);  // A4, 72 dpi
  [renderer setValue:[NSValue valueWithCGRect:A4PageRect] forKey:@"paperRect"];
  [renderer setValue:[NSValue valueWithCGRect:A4PageRect] forKey:@"printableRect"];

  // Render PDF to a file in memory.
  NSMutableData *pdfData = [NSMutableData data];
  UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
  for (NSInteger i = 0; i < renderer.numberOfPages; i++) {
    UIGraphicsBeginPDFPage();
    CGRect pdfPageBounds = UIGraphicsGetPDFContextBounds();
    [renderer drawPageAtIndex:i inRect:pdfPageBounds];
  }
  UIGraphicsEndPDFContext();

  // Write the file to temp directory.
  NSURL *temporaryDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
  NSString *temporaryFilename = [[NSProcessInfo processInfo] globallyUniqueString];
  temporaryFilename = [temporaryFilename stringByAppendingString:@".pdf"];
  NSURL *temporaryFileURL = [temporaryDirectoryURL URLByAppendingPathComponent:temporaryFilename];
  [pdfData writeToURL:temporaryFileURL atomically:YES];
  return temporaryFileURL;
}

@end

NS_ASSUME_NONNULL_END
