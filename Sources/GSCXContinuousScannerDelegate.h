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

#import <UIKit/UIKit.h>

#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@class GSCXContinuousScanner;

/**
 * Listens to scan lifecycle events and provides information on view hierarchies to scan.
 */
@protocol GSCXContinuousScannerDelegate <NSObject>

/**
 * @return The root views of the view hierarchies to scan for accessibility issues.
 */
- (NSArray<UIView *> *)rootViewsToScan;

@optional

/**
 * Called when the scanner will begin a continuous scan.
 *
 * @param scanner The scanner instance that will begin a continuous scan.
 */
- (void)continuousScannerWillStart:(GSCXContinuousScanner *)scanner;

/**
 * Called when a scan occurs.
 *
 * @param scanner The scanner instance that performed the scan.
 * @param result The result of the scan.
 */
- (void)continuousScanner:(GSCXContinuousScanner *)scanner
    didPerformScanWithResult:(GTXHierarchyResultCollection *)result;

@end

NS_ASSUME_NONNULL_END
