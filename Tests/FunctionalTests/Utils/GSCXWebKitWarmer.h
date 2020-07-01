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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Error domain for errors occurring when warming up WebKit.
 */
FOUNDATION_EXTERN NSString *const kGSCXWebViewWarmerErrorDomain;

/**
 * Error code occurring when trying to warm up WebKit timed out.
 */
FOUNDATION_EXTERN const NSInteger kGSCXWebViewWarmerErrorCodeTimedOut;

/**
 * Loads data into a @c WKWebView instance to force WebKit's processes to load. This can be called
 * ahead of time in test suites so no one test times out because it was the first test to use a
 * @c WKWebView, which can take upwards of 15 seconds to load at the first invocation.
 */
@interface GSCXWebKitWarmer : NSObject

/**
 * Loads data into a @c WKWebView instance to force WebKit's processes to load. This makes future
 * calls to @c WKWebView faster. Must occur on the main thread.
 *
 * @param timeout The number of seconds to wait before failing the warm up process.
 * @param errorOut Optional. A pointer to an error object. If an error occurs, @c errorOut is set to
 * an error object containing the error information.
 * @return @c YES if the web view was successfully warmed up, @c NO otherwise.
 */
+ (BOOL)warmWebViewWithTimeout:(NSTimeInterval)timeout error:(NSError **)errorOut;

@end

NS_ASSUME_NONNULL_END
