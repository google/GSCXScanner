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

#import "GSCXOverlayViewArranger.h"

#import <XCTest/XCTest.h>

#import "NSLayoutConstraint+GSCXUtilities.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The frame of the view controller under test, representing the root view controller of an overlay
 * window.
 */
static const CGRect kGSCXViewControllerFrame = {{0, 0}, {414, 667}};

/**
 * The top left quarter of @c kGSCXViewControllerFrame.
 */
static const CGRect kGSCXViewControllerFrameTopLeft = {{0, 0}, {207, 333.5}};

/**
 * The top right quarter of @c kGSCXViewControllerFrame.
 */
static const CGRect kGSCXViewControllerFrameTopRight = {{207, 0}, {207, 333.5}};

/**
 * The bottom left quarter of @c kGSCXViewControllerFrame.
 */
static const CGRect kGSCXViewControllerFrameBottomLeft = {{0, 333.5}, {207, 333.5}};

/**
 * The bottom right quarter of @c kGSCXViewControllerFrame.
 */
static const CGRect kGSCXViewControllerFrameBottomRight = {{207, 333.5}, {207, 333.5}};

/**
 * The initial frame of the view under test, representing a view managed by a
 * @c GSCXOverlayViewArranger instance.
 */
static const CGRect kGSCXOverlayViewFrame = {{0, 0}, {100, 44}};

@interface GSCXOverlayViewArrangerTests : XCTestCase

/**
 * The view controller under test, representing the root view controller of an overlay window.
 */
@property(strong, nonatomic) UIViewController *viewController;

/**
 * The view under test, managed by a @c GSCXOverlayViewArranger instance.
 */
@property(strong, nonatomic) UIView *overlayView;

@end

@implementation GSCXOverlayViewArrangerTests

- (void)setUp {
  [super setUp];
  self.viewController = [[UIViewController alloc] init];
  self.viewController.view.frame = kGSCXViewControllerFrame;
  self.overlayView = [[UIView alloc] initWithFrame:kGSCXOverlayViewFrame];
  [NSLayoutConstraint
      gscx_constraintsWithHorizontalFormat:@"[overlayView(==width)]"
                            verticalFormat:@"[overlayView(==height)]"
                                   options:0
                                   metrics:@{
                                     @"width" : @(CGRectGetWidth(self.overlayView.bounds)),
                                     @"height" : @(CGRectGetHeight(self.overlayView.bounds))
                                   }
                                     views:@{@"overlayView" : self.overlayView}
                                 activated:YES];
  self.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.viewController.view addSubview:self.overlayView];
  [self gscxtest_updateOverlayConstraints];
}

- (void)testRotateClockwiseMovesViewToCornersOfScreen {
  GSCXOverlayViewArranger *arranger =
      [[GSCXOverlayViewArranger alloc] initWithView:self.overlayView container:self.viewController];
  [self gscxtest_updateOverlayConstraints];
  // Initializing arranger activates the bottom left constraints.
  XCTAssertTrue(CGRectContainsRect(kGSCXViewControllerFrameBottomLeft, self.overlayView.frame));
  [arranger rotateClockwise];
  [self gscxtest_updateOverlayConstraints];
  XCTAssertTrue(CGRectContainsRect(kGSCXViewControllerFrameTopLeft, self.overlayView.frame));
  [arranger rotateClockwise];
  [self gscxtest_updateOverlayConstraints];
  XCTAssertTrue(CGRectContainsRect(kGSCXViewControllerFrameTopRight, self.overlayView.frame));
  [arranger rotateClockwise];
  [self gscxtest_updateOverlayConstraints];
  XCTAssertTrue(CGRectContainsRect(kGSCXViewControllerFrameBottomRight, self.overlayView.frame));
  [arranger rotateClockwise];
  [self gscxtest_updateOverlayConstraints];
  XCTAssertTrue(CGRectContainsRect(kGSCXViewControllerFrameBottomLeft, self.overlayView.frame));
}

#pragma mark - Private

/**
 * Recalculates Autolayout constraints for @c overlayView.
 */
- (void)gscxtest_updateOverlayConstraints {
  [self.viewController.view setNeedsLayout];
  [self.viewController.view layoutIfNeeded];
}

@end

NS_ASSUME_NONNULL_END
