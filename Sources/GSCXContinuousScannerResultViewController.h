//
// Copyright 2019 Google LLC.
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

#import "GSCXReport.h"
#import "GSCXSharingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Invoked when a @c GSCXContinuousScannerResultViewController fails to load a report.
 */
typedef void (^GSCXContinuousScannerLoadFailureCallback)(void);

/**
 * The title of the bar button item that shares scan results.
 */
FOUNDATION_EXTERN NSString *const kGSCXContinuousScannerResultShareBarButtonTitle;

/**
 * Displays a report of a continuous scan's results.
 */
@interface GSCXContinuousScannerResultViewController
    : UIViewController <UINavigationControllerDelegate>

/**
 * Invoked when the report cannot be loaded. Use this to dismiss the view controller.
 */
@property(copy, nonatomic) GSCXContinuousScannerLoadFailureCallback failureCallback;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/**
 * Initializes this object by loading from a xib file from a given bundle. The user provides
 * whether accessibility is enabled or not.
 *
 * @param nibName The name of the xib file to load from (without the ".xib" extension).
 * @param bundle The bundle the xib file is located in, or nil if it's in the main bundle.
 * @param report Generates the report displayed by this view controller.
 * @param sharingDelegate Controls how the report is shared.
 * @return An initialized @c GSCXContinuousScannerResultViewController object.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         report:(GSCXReport *)report
                sharingDelegate:(id<GSCXSharingDelegate>)sharingDelegate NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
