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

#import "GSCXHitForwardingWindow.h"
#import "GSCXHitForwardingViewTests.h"

/**
 *  Contains tests for -[GSCXHitForwardingWindow hitTest:withEvent:].
 */
@interface GSCXHitForwardingWindowTests : GSCXHitForwardingViewTests
@end

@implementation GSCXHitForwardingWindowTests

#pragma mark - GSCXHitForwardingViewTests

+ (UIView *)viewWithFrame:(CGRect)frame {
  GSCXHitForwardingWindow *window = [[GSCXHitForwardingWindow alloc] initWithFrame:frame];
  window.rootViewController = [[UIViewController alloc] init];
  // Hiding the view controller's view prevents the window from returning it in hitTest:withEvent:.
  window.rootViewController.view.hidden = YES;
  window.hidden = NO;
  return window;
}

@end
