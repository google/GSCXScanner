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

NS_ASSUME_NONNULL_BEGIN

/**
 * The default width of the ring.
 */
FOUNDATION_EXTERN const CGFloat kGSCXRingViewDefaultWidth;

/**
 * Draws a ring shaped outline around the view's frame. Because a view cannot draw outside its
 * bounds on its layer, a GSCXRingView's frame must be slightly larger than the frame of the
 * element it's highlighting. The ring's owner is responsible for determining the frame or using a
 * factory method to determine the frame. GSCXRingView is an accessibility element by default.
 */
@interface GSCXRingView : UIView

/**
 * The stroke width of the ring, in points. Defaults to 4.0.
 */
@property(assign, nonatomic) CGFloat ringWidth;

/**
 * The color of the ring. Defaults to [GSCXRingView defaultColor];
 */
@property(strong, nonatomic) UIColor *ringColor;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 * Constructs a @c GSCXRingView with a frame slightly bigger than the given rect so the ring exactly
 * outlines the given rect. The amount of inset is determined by the default line width.
 *
 * @param focusRect The rect around which to draw the ring.
 * @return A @c GSCXRingView outlining the given rect.
 */
+ (instancetype)ringViewAroundFocusRect:(CGRect)focusRect;

/**
 * Constructs a @c GSCXRingView with a frame slightly bigger than the given rect so the ring exactly
 * outlines the given rect. The amount of inset is determined by the given line width.
 *
 * @param focusRect The rect around which to draw the ring.
 * @param ringWidth The width of the ring. Dtermines the inset of the ring's frame.
 * @return A @c GSCXRingView outlining the given rect.
 */
+ (instancetype)ringViewAroundFocusRect:(CGRect)focusRect ringWidth:(CGFloat)ringWidth;

/**
 * @return The default orange color of a ring view.
 */
+ (UIColor *)defaultColor;

@end

NS_ASSUME_NONNULL_END
