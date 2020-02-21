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

#import "GSCXActivitySourceMonitoring.h"
#import "GSCXContinuousScannerScheduling.h"
#import "GSCXScannerDelegate.h"
#import "GSCXSharingDelegate.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

/**
 * Configures the installation of @c GSCXScanner.
 */
@interface GSCXInstallerOptions : NSObject

/**
 * An array of checks the scanner uses to evaluate accessibility elements. Defaults to
 * GTXChecksCollection allGtxChecks.
 */
@property(strong, nonatomic) NSArray<id<GTXChecking>> *checks;

/**
 * An array of blacklists the scanner uses to skip accessibility elements. Defaults to an empty
 * array.
 */
@property(strong, nonatomic) NSArray<id<GTXBlacklisting>> *blacklists;

/**
 * The delegate of the @c GSCXScanner. Optional. Defaults to @c nil.
 */
@property(strong, nonatomic, nullable) id<GSCXScannerDelegate> scannerDelegate;

/**
 * An array of @c GSCXActivitySourceMonitoring instances used by the continuous scanner to determine
 * if the application is busy or free. If @c nil, then the default activity sources are used. If not
 * @c nil, must be non-empty.
 */
@property(strong, nonatomic, nullable) NSArray<id<GSCXActivitySourceMonitoring>> *activitySources;

/**
 * An array of @c GSCXContinuousScannerScheduling instances used by the continuous scanner to
 * determine when scans should take place. If @c nil, then the default schedulers are used. If not
 * @c nil, must be non-empty.
 */
@property(strong, nonatomic, nullable) NSArray<id<GSCXContinuousScannerScheduling>> *schedulers;

/**
 * Controls how the scan reports are shared. Optional. If @c nil, a
 * @c GSCXDefaultSharingDelegate instance is used.
 */
@property(strong, nonatomic, nullable) id<GSCXSharingDelegate> sharingDelegate;

@end

NS_ASSUME_NONNULL_END
