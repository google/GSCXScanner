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

#import "GSCXReportContext.h"
#import <WebKit/WebKit.h>

@interface GSCXReport ()<WKNavigationDelegate>
@end

@implementation GSCXReport {
  GSCXReportCompletionBlock _onComplete;
  WKWebView *_helperWebview;
}

- (void)beginSharingResult:(GSCXScannerResult *)result
       withCompletionBlock:(GSCXReportCompletionBlock)onComplete {
  _onComplete = onComplete ?: ^(NSURL *reportUrl){};

  // Create a HTML file renders the PDF.
  GSCXReportContext *context = [[GSCXReportContext alloc] init];
  NSString *html = [result htmlDescription:context];
  NSURL *path = [[self class] _createLocalSiteWithHTMLString:html context:context];

  // Create a 1 pixel webview but do not add it to the hierarchy, the webview will be used to render
  // PDF.
  CGRect webViewFrame = CGRectMake(0, 0, 1, 1);
  _helperWebview = [[WKWebView alloc] initWithFrame:webViewFrame];
  _helperWebview.navigationDelegate = self;

  [_helperWebview loadFileURL:[path URLByAppendingPathComponent:@"index.html"]
     allowingReadAccessToURL:path];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  NSURL *pdfURL = [[self class] _getPDFFromWebView:_helperWebview];
  _onComplete(pdfURL);
}

#pragma mark - Private

/**
 *  Creates a local HTML page with the given context.
 */
+ (NSURL *)_createLocalSiteWithHTMLString:(NSString *)html context:(GSCXReportContext *)context {
  // Create a temp directory to hold the local website.
  NSURL *temporaryDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory()
                                            isDirectory:YES];
  NSString *tempDirName = [[NSProcessInfo processInfo] globallyUniqueString];
  temporaryDirectoryURL = [temporaryDirectoryURL URLByAppendingPathComponent:tempDirName];
  NSError *error;
      [[NSFileManager defaultManager] createDirectoryAtURL:temporaryDirectoryURL
                               withIntermediateDirectories:YES
                                                attributes:nil
                                                     error:&error];
  NSAssert(error == nil, @"Could not create sharable dir: %@", error);

  // Add an index.html which will be the home page with the given HTML.
  NSURL *indexURL = [temporaryDirectoryURL URLByAppendingPathComponent:@"index.html"];
  [[html dataUsingEncoding:NSASCIIStringEncoding] writeToURL:indexURL atomically:YES];

  // Add all the images into the temp directory
  [context forEachImageWithHandler:^(UIImage * _Nonnull image, NSString * _Nonnull filename) {
    NSURL *url = [temporaryDirectoryURL URLByAppendingPathComponent:filename];
    [UIImagePNGRepresentation(image) writeToURL:url atomically:YES];
  }];

  return temporaryDirectoryURL;
}

/**
 *  Generates a PDF from the webpage in the given webview.
 */
+ (NSURL *)_getPDFFromWebView:(UIView *)webView {
  // Prepare a PDF renderer.
  UIViewPrintFormatter *formatter = [webView viewPrintFormatter];
  UIPrintPageRenderer *renderer = [[UIPrintPageRenderer alloc] init];
  [renderer addPrintFormatter:formatter startingAtPageAtIndex:0];
  // @TODO Move away from pages and render whole report as a single long page to make it easy to
  // read on screens.
  CGRect A4PageRect = CGRectMake(0, 0, 595.2, 841.8); // A4, 72 dpi
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
  NSURL *temporaryDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory()
                                            isDirectory:YES];
  NSString *temporaryFilename = [[NSProcessInfo processInfo] globallyUniqueString];
  temporaryFilename = [temporaryFilename stringByAppendingString:@".pdf"];
  NSURL *temporaryFileURL = [temporaryDirectoryURL URLByAppendingPathComponent:temporaryFilename];
  [pdfData writeToURL:temporaryFileURL atomically:YES];
  return temporaryFileURL;
}

@end
