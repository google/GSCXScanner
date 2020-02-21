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

#import "GSCXTestPage.h"

/**
 * A view controller containing elements failing accessibility checks to test scanner
 * functionality.
 */
@interface GSCXTestScannerViewController : UIViewController <GSCXTestPage>

/**
 * Label that fails the first and fourth custom checks.
 */
@property(weak, nonatomic) IBOutlet UILabel *firstLabel;

/**
 * Label that passes checks.
 */
@property(weak, nonatomic) IBOutlet UILabel *secondLabel;

/**
 * Label that fails the second custom check.
 */
@property(weak, nonatomic) IBOutlet UILabel *thirdLabel;

/**
 * Label that fails the third custom check and overlaps with thirdLabel.
 */
@property(weak, nonatomic) IBOutlet UILabel *fourthLabel;

@end
