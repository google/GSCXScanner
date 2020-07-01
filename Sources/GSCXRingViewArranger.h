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

#import "GSCXRingView.h"
#import "GSCXScannerResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Manages an array of @c GSCXRingView instances to highlight elements corresponding to issues in a
 * @c GSCXResult.
 */
@interface GSCXRingViewArranger : NSObject

/**
 * The result of a scan.
 */
@property(strong, nonatomic, readonly) GSCXScannerResult *result;

/**
 * An array of @c GSCXRingView instances highlighting elements corresponding to the issues in @c
 * result. @c nil until @c addRingViewsToSuperView:fromCoordinates: is called.
 */
@property(strong, nonatomic, readonly, nullable) NSArray<GSCXRingView *> *ringViews;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initializes an instance of @c GSCXRingViewArranger with the given result.
 *
 * @param result A scan result containing issues to highlight.
 * @return An intialized instance of @c GSCXRingViewArranger.
 */
- (instancetype)initWithResult:(GSCXScannerResult *)result;

/**
 * Initializes the ring views and adds them as subviews of @c superview.
 *
 * @param superview The view to which to add the ring views. This ring view's frames are transformed
 * into this view's coordinate space.
 * @param originalCoordinates The original coordinate system the result's UI elements were in. For
 * @c GSCXScannerIssue instances, this is likely the bounds of the main screen.
 */
- (void)addRingViewsToSuperview:(UIView *)superview fromCoordinates:(CGRect)originalCoordinates;

/**
 * Removes all ring views from their superview.
 */
- (void)removeRingViewsFromSuperview;

/**
 * Adds accessibility labels and identifiers to each ring view describing how many issues it
 * represents and what view it is highlighting.
 */
- (void)addAccessibilityAttributesToRingViews;

/**
 * Returns a new result containing only issues found at @c point from the new coordinate space.
 *
 * @param point The point at which to find issues in the new coordinate space.
 * @return A @c GSCXScannerResult instance only containing issues underneath @c point when
 * transformed to the new coordinate space.
 */
- (GSCXScannerResult *)resultWithIssuesAtPoint:(CGPoint)point;

/**
 * Creates an image by capturing a view hierarchy after highlighting views
 * with accessibility issues. The highlights are removed before the method
 * returns.
 *
 * @param superview The view to capture an image of after highlighting accessibility issues.
 * @param originalCoordinates The original coordinate system the result's UI elements were in.
 * @return An image of the view hierarchy of @c superview with highlights over elements with
 * accessibility issues.
 */
- (UIImage *)imageByAddingRingViewsToSuperview:(UIView *)superview
                               fromCoordinates:(CGRect)originalCoordinates;

/**
 * Returns the accessibility identifier of the ring view at the given index.
 *
 * @param index The index of the ring view.
 * @return A string representing the accessibility identifier of the corresponding ring view.
 */
+ (NSString *)accessibilityIdentifierForRingViewAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
