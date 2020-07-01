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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Convenience methods for constructing autolayout constraints for common use cases.
 */
@interface NSLayoutConstraint (GSCXUtilities)

/**
 * Creates autolayout constraints using the visual format for both horizontal and vertical
 * directions.
 *
 * @param horizontalFormat The format of constraints in the horizontal direction. One of @c
 * horizontalFormat and @c verticalFormat must be non-nil.
 * @param verticalFormat The format of constraints in the vertical direction. One of @c
 * horizontalFormat and @c verticalFormat must be non-nil. Does not need to contain the "V:" prefix.
 * @param options Options describing the attribute and the direction of layout for all objects in
 * the visual format string. Used for both @c horizontalFormat and @c verticalFormat.
 * @param metrics A dictionary of constants that appear in the visual format string. The
 * dictionary’s keys must be the string values used in the visual format string. Their values must
 * be @c NSNumber objects.
 * @param views A dictionary of views that appear in the visual format string. The keys must be the
 * string values used in the visual format string, and the values must be the view objects.
 * @param activated @c YES if the returned constraints should be activated, @c NO otherwise.
 * @return An array of constraints expressing the relationships between the provided views as
 * described by the visual format string.
 */
+ (NSArray<NSLayoutConstraint *> *)
    gscx_constraintsWithHorizontalFormat:(nullable NSString *)horizontalFormat
                          verticalFormat:(nullable NSString *)verticalFormat
                                 options:(NSLayoutFormatOptions)options
                                 metrics:(nullable NSDictionary<NSString *, NSNumber *> *)metrics
                                   views:(nullable NSDictionary<NSString *, id> *)views
                               activated:(BOOL)activated;

/**
 * Creates autolayout constraints setting the frame of @c view to the bounds of its superview.
 *
 * @param view The view to add constraints to.
 * @param activated @c YES if the returned constraints should be activated, @c NO otherwise.
 * @return The generated constraints.
 */
+ (NSArray<NSLayoutConstraint *> *)gscx_constraintsToFillSuperviewWithView:(UIView *)view
                                                                 activated:(BOOL)activated;

/**
 * Creates an autolayout constraint fixing @c view's aspect ratio to @c aspectRatio.
 *
 * @param view The view to constrain the aspect ratio of.
 * @param aspectRatio The aspect ratio of the view. Must be greater than 0. Aspect ratio is defined
 * as width divided by height.
 * @param activated @c YES if the returned constraints should be activated, @c NO otherwise.
 * @return The generated constraints.
 */
+ (NSLayoutConstraint *)gscx_constraintWithView:(UIView *)view
                                    aspectRatio:(CGFloat)aspectRatio
                                      activated:(BOOL)activated;

/**
 * Creates an autolayout constraint fixing @c view's aspect ratio to its current aspect ratio.
 *
 * @exception Crashes with an assertion if the view's height is 0.0.
 * @param view The view to constrain the aspect ratio of.
 * @param activated @c YES if the returned constraints should be activated, @c NO otherwise.
 * @return The generated constraint.
 */
+ (NSLayoutConstraint *)gscx_constraintToCurrentAspectRatioWithView:(UIView *)view
                                                          activated:(BOOL)activated;

/**
 * Centers @c view1 and @c view2 on the given axes.
 *
 * @param view1 The first view to center.
 * @param view2 The second view to center.
 * @param horizontally @c YES if @c view1 and @c view2 should have the same center x, @c NO
 * otherwise. At least one of @c horizontally and @c vertically must be true.
 * @param vertically @c YES if @c view1 and @c view2 should have the same center y, @c NO otherwise.
 * At least one of @c horizontally and @c vertically must be true.
 * @param activated @c YES if the returned constraints should be activated, @c NO otherwise.
 * @return The generated constraints.
 */
+ (NSArray<NSLayoutConstraint *> *)gscx_constraintsCenteringView:(UIView *)view1
                                                        withView:(UIView *)view2
                                                    horizontally:(BOOL)horizontally
                                                      vertically:(BOOL)vertically
                                                       activated:(BOOL)activated;

/**
 * Constrains the anchors of @c view to be equal to the safe area layout guide of @c safeAreaView
 * based on the boolean flags. One of @c constrainLeading, @c constrainTrailing, @c constrainTop,
 * and @c constrainBottom must be @c YES or the method crashes with an assertion.
 *
 * @param view The view to constrain the anchors of.
 * @param safeAreaView The view to constrain the anchors of @c view to the safe area layout guide
 *  of.
 * @param constrainLeading @c YES if the leading anchors should be constrained equal.
 * @param constrainTrailing @c YES if the trailing anchors should be constrained equal.
 * @param constrainTop @c YES if the top anchors should be constrained equal.
 * @param constrainBottom @c YES if the bottom anchors should be constrained equal.
 * @param constant The distance between the edges of @c safeAreaView and the constrained edges of
 *  @c view. A positive value means @c view is smaller than @c safeAreaView (@c view is within
 *  @c safeAreaView and there is padding between their edges). A negative values means @c view is
 * larger than @c safeAreaView.
 * @param activated @c YES if the returned constraints should be activated, @c NO otherwise.
 * @return The generated constraints.
 */
+ (NSArray<NSLayoutConstraint *> *)gscx_constrainAnchorsOfView:(UIView *)view
                                         equalToSafeAreaOfView:(UIView *)safeAreaView
                                                       leading:(BOOL)constrainLeading
                                                      trailing:(BOOL)constrainTrailing
                                                           top:(BOOL)constrainTop
                                                        bottom:(BOOL)constrainBottom
                                                      constant:(CGFloat)constant
                                                     activated:(BOOL)activated;

@end

NS_ASSUME_NONNULL_END
