//
// Copyright 2020 Google Inc.
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

#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/Utils/GSCXWebKitWarmer.h"

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

NSString *const kGSCXWebViewWarmerErrorDomain = @"com.google.gscxscanner";

const NSInteger kGSCXWebViewWarmerErrorCodeTimedOut = 1;

/**
 * The number of seconds to run the run loop for while waiting for @c WKWebView events to fire,
 * signalling that the web view has been successfully warmed or not.
 */
static const NSTimeInterval kGSCXWebViewWarmerRunLoopDuration = 0.1;

@interface GSCXWebKitWarmer () <WKNavigationDelegate>

/**
 * The error occurring while trying to warm the web view. @c nil if no error occurred.
 */
@property(strong, nonatomic, nullable) NSError *error;

/**
 * @c YES if the web view was sucessfully warmed up, @c NO otherwise.
 */
@property(assign, nonatomic, getter=isWarmedUp) BOOL warmedUp;

/**
 * The web view used to load data into to force WebKit's processes to load.
 */
@property(strong, nonatomic) WKWebView *webView;

@end

@implementation GSCXWebKitWarmer

- (instancetype)init {
  self = [super init];
  if (self) {
    _webView = [[WKWebView alloc] initWithFrame:CGRectZero
                                  configuration:[[WKWebViewConfiguration alloc] init]];
    _webView.navigationDelegate = self;
  }
  return self;
}

+ (BOOL)warmWebViewWithTimeout:(NSTimeInterval)timeout error:(NSError **)errorOut {
  static dispatch_once_t onceToken;
  static BOOL warmedUp = NO;
  static NSError *error = nil;
  dispatch_once(&onceToken, ^{
    GSCXWebKitWarmer *warmer = [[GSCXWebKitWarmer alloc] init];
    NSError *warmerError;
    warmedUp = [warmer gscxtest_warmWebViewWithTimeout:timeout error:&warmerError];
    error = warmerError;
  });
  if (errorOut) {
    *errorOut = error;
  }
  return warmedUp;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView
    didFinishNavigation:(null_unspecified WKNavigation *)navigation {
  self.warmedUp = YES;
}

- (void)webView:(WKWebView *)webView
    didFailNavigation:(null_unspecified WKNavigation *)navigation
            withError:(NSError *)error {
  self.warmedUp = YES;
  self.error = error;
}

#pragma mark - Private

/**
 * Loads data into a @c WKWebView instance to force WebKit's processes to load. This makes future
 * calls to @c WKWebView faster. Must occur on the main thread.
 *
 * @param timeout The number of seconds to wait before failing the warm up process.
 * @param errorOut Optional. A pointer to an error object. If an error occurs, @c errorOut is set to
 * an error object containing the error information.
 * @return @c YES if the web view was successfully warmed up, @c NO otherwise.
 */
- (BOOL)gscxtest_warmWebViewWithTimeout:(NSTimeInterval)timeout error:(NSError **)errorOut {
  NSDate *stopDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
  [self.webView loadHTMLString:@"" baseURL:nil];
  while (!self.warmedUp && [stopDate timeIntervalSinceNow] > 0.0) {
    [NSRunLoop.mainRunLoop
        runUntilDate:[NSDate dateWithTimeIntervalSinceNow:kGSCXWebViewWarmerRunLoopDuration]];
  }
  if (!self.warmedUp && errorOut) {
    if ([stopDate timeIntervalSinceNow] <= 0.0) {
      *errorOut = [NSError errorWithDomain:kGSCXWebViewWarmerErrorDomain
                                      code:kGSCXWebViewWarmerErrorCodeTimedOut
                                  userInfo:@{
                                    NSLocalizedDescriptionKey : [NSString
                                        stringWithFormat:@"Timed out after %f seconds", timeout]
                                  }];
    } else {
      *errorOut = self.error;
    }
  }
  return self.warmedUp;
}

@end

NS_ASSUME_NONNULL_END
