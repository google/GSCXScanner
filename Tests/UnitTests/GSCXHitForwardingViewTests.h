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
#import <XCTest/XCTest.h>

/**
 *  Contains tests for hit forwarding functionality in the hitTest:withEvent: method. Subclasses
 *  of UIView implementing that method to forward touch events may be tested by subclassing this
 *  class and overriding the viewClass method with that class.
 */
@interface GSCXHitForwardingViewTests : XCTestCase

/**
 *  The view under test.
 */
@property(strong, nonatomic) UIView *view;

/**
 *  Returns the view being tested by this test case. Defaults to an instance of
 *  GSCXHitForwardingView.
 *
 *  @param frame The frame of the view. The returned view's frame must be this value.
 *  @return A UIView instance to be tested.
 */
+ (UIView *)viewWithFrame:(CGRect)frame;

@end
