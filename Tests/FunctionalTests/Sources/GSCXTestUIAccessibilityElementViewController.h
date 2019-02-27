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
 *  A view controller containing UIAccessibilityElements (not UIViews) which fail accessibility
 *  checks.
 */
@interface GSCXTestUIAccessibilityElementViewController : UIViewController <GSCXTestPage>

/**
 *  A visual indicator for the location of the underlying pure UIAccessibilityElement.
 */
@property(weak, nonatomic) IBOutlet UIView *visualIndicator;
/**
 *  A visual indicator for the location of the underlying pure UIAccessibilityElement acting as an
 *  accessibility container.
 */
@property(weak, nonatomic) IBOutlet UIView *container;
/**
 *  A visual indicator for the location of the underlying pure UIAccessibilityElement nested inside
 *  the accessibility container.
 */
@property(weak, nonatomic) IBOutlet UIView *subVisualIndicator;

@end
