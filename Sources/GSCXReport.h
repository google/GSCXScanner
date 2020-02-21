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

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#import "GSCXScannerResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Invoked when a @c GSCXReport instance has finished creating an HTML report.
 *
 * @param webView A @c WKWebView instance rendering the report. The caller owns this instance.
 */
typedef void (^GSCXHTMLReportCompletionBlock)(WKWebView *webView);

/**
 * Invoked when a @c GSCXReport instance has finished creating a PDF report.
 *
 * @param reportURL A URL representing a local file at which the PDF is stored.
 */
typedef void (^GSCXPDFReportCompletionBlock)(NSURL *reportUrl);

/**
 * Class responsible for generating reports and showing UI for sharing it.
 */
@interface GSCXReport : NSObject

/**
 * The results found across all scans.
 */
@property(strong, nonatomic, readonly) NSArray<GSCXScannerResult *> *results;

/**
 * Initializes a @c GSCXReport instance displaying the given scan results.
 *
 * @param results The results to display in the report.
 * @return An initialized @c GSCXReport instance.
 */
- (instancetype)initWithResults:(NSArray<GSCXScannerResult *> *)results;

/**
 * Creates an HTML report describing the issues found in all scans.
 *
 * @param onComplete Invoked when the report has been created.
 */
- (void)createHTMLReportWithCompletionBlock:(GSCXHTMLReportCompletionBlock)onComplete;

/**
 * Creates a PDF report describing the issues found in all scans.
 *
 * @param onComplete Invoked when the report has been created.
 */
- (void)createPDFReportWithCompletionBlock:(GSCXPDFReportCompletionBlock)onComplete;

@end

NS_ASSUME_NONNULL_END
