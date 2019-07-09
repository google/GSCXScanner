//
// Copyright 2018 Google Inc.
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
#import <UIKit/UIKit.h>

#import "GSCXAnalytics.h"
#import "GSCXScannerDelegate.h"
#import "GSCXScannerResult.h"

// All GTXiLib imports are grouped here to help with OSS release script which replaces the below
// with GTXiLib framework import.
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

/**
 *  Scans a view hieararchy(s) for accessibility issues based on a set of registered checks.
 */
@interface GSCXScanner : NSObject

/**
 *  The object that receives notifications about scan events.
 */
@property(weak, nonatomic) id<GSCXScannerDelegate> _Nullable delegate;
/**
 *  The most recent result of scanning the view hierarchy, or nil if no scan has
 *  been performed yet. Old results are overwritten.
 */
@property(strong, nonatomic, readonly) GSCXScannerResult *_Nullable lastScanResult;

/**
 *  Constructs a GSCXScanner object.
 */
+ (instancetype)scanner;
/**
 *  Constructs a GSCXScanner object with the given checks and blacklists.
 *
 *  @param checks The accessibility checks to register.
 *  @param blacklists The blacklists to register.
 *  @return A GSCXScanner object with registered checks and blacklists.
 */
+ (instancetype)scannerWithChecks:(NSArray<id<GTXChecking>> *)checks
                       blacklists:(NSArray<id<GTXBlacklisting>> *)blacklists;
/**
 *  Scans the view hierarchy with root given by the data source for accessibility
 *  issues. rootViews is an array of UIViews representing the roots of
 *  view hierarchies for the scanner to check. lastScanResult is set to the return
 *  value of this method.
 *
 *  @param rootViews An array of views to check for accessibility issues. Checks the given views
 *  and all subviews.
 *  @return A GSCXScannerResult object containing all the issues found in the scan.
 */
- (GSCXScannerResult *)scanRootViews:(NSArray<UIView *> *)rootViews;
/**
 *  Registers the given check to be executed on all elements this instance is used
 *  on.
 *
 *  @param check A GTXChecking object used to check for accessibility issues.
 */
- (void)registerCheck:(id<GTXChecking>)check;
/**
 *  Configures this instance to skip elements by a given blacklist.
 *
 *  @param blacklist A GTXBlacklisting object used to skip elements for accessibility checks.
 */
- (void)registerBlacklist:(id<GTXBlacklisting>)blacklist;

@end

NS_ASSUME_NONNULL_END
