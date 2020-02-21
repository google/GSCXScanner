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

#import <UIKit/UIKit.h>

#import "GSCXScannerResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The accessibility identifier of the check name label.
 */
FOUNDATION_EXTERN NSString *const kGSCXDetailCheckNameAccessibilityIdentifier;

/**
 * The accessibility identifier of the check description label.
 */
FOUNDATION_EXTERN NSString *const kGSCXDetailCheckDescriptionAccessibilityIdentifier;

/**
 * Presents detailed information on an failing accessibility check and potential solution.
 * Considered opaque.
 */
@interface GSCXScannerResultDetailViewController : UIViewController

/**
 * The result of the scan. This object's owner is responsible for setting this property before
 * viewDidLoad is called.
 */
@property(strong, nonatomic, readonly) GSCXScannerResult *scanResult;

/**
 * The index of the issue to display details about. This object's owner is responsible for setting
 * this property before viewDidLoad is called.
 */
@property(assign, nonatomic, readonly) NSUInteger issueIndex;

/**
 * Label displaying the name of the accessibility issue.
 */
@property(weak, nonatomic) IBOutlet UILabel *checkName;

/**
 * Label displaying the description of the accessibility issue and potential solution.
 */
@property(weak, nonatomic) IBOutlet UILabel *checkDescription;

/**
 * Sets the scanResult and issueIndex properties at the same time. These properties cannot be set
 * separately because that would temporarily introduce invalid state.
 *
 * @param scanResult The new value of @c scanResult.
 * @param issueIndex The new value of @c issueIndex.
 */
- (void)setScanResult:(GSCXScannerResult *)scanResult issueIndex:(NSUInteger)issueIndex;

@end

NS_ASSUME_NONNULL_END
