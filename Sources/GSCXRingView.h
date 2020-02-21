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
 * The default width of the inner part of the ring.
 */
FOUNDATION_EXTERN const CGFloat kGSCXRingViewDefaultInnerWidth;

/**
 * The default width of the outer part of the ring.
 */
FOUNDATION_EXTERN const CGFloat kGSCXRingViewDefaultOuterWidth;

/**
 * Draws a ring shaped outline around the view's frame. Because a view cannot draw outside its
 * bounds on its layer, a GSCXRingView's frame must be slightly larger than the frame of the
 * element it's highlighting. The ring's owner is responsible for determining the frame or using a
 * factory method to determine the frame. GSCXRingView is an accessibility element.
 */
@interface GSCXRingView : UIView

/**
 * The stroke width of the inner part of the ring, in points. Defaults to 2.0. Must be smaller than
 * outer width.
 */
@property(assign, nonatomic, readonly) CGFloat innerWidth;

/**
 * The stroke width of the outer part of the ring, in points. Defaults to 4.0. Must be larger than
 * inner width.
 */
@property(assign, nonatomic, readonly) CGFloat outerWidth;

/**
 * The color rendered on the inner part of the ring. Defaults to [UIColor blackColor];
 */
@property(strong, nonatomic) UIColor *innerColor;

/**
 * The color rendered on the outer part of the ring. Defaults to [UIColor yellowColor];
 */
@property(strong, nonatomic) UIColor *outerColor;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 * Initializes a GSCXRingView with a frame slightly bigger than the given rect so the ring exactly
 * outlines the given rect. The amount of inset is determined by the default line widths.
 *
 * @param focusRect The rect around which to draw the ring.
 * @return A GSCXRingView which outlines the given frame.
 */
+ (instancetype)ringViewAroundFocusRect:(CGRect)focusRect;

/**
 * Initializes a GSCXRingView with a frame slightly bigger than the given rect so the ring exactly
 * outlines the given rect. The amount of inset is determined by the given line widths.
 *
 * @param focusRect The rect around which to draw the ring.
 * @param innerWidth The width of the inner ring. Must be smaller than outer width.
 * @param outerWidth The width of the outer ring. Must be larger than inner width. Used to
 * determine the inset of the ring's frame.
 * @return A GSCXRingView which outlines the given rect.
 */
+ (instancetype)ringViewAroundFocusRect:(CGRect)focusRect
                             innerWidth:(CGFloat)innerWidth
                             outerWidth:(CGFloat)outerWidth;

/**
 * Sets innerWidth and outerWidth properties simultaneously.
 *
 * @param innerWidth The value to set the innerWidth property. Must be smaller than outerWidth.
 * @param outerWidth The value to set the outerWidth property. Must be larger than innerWidth.
 */
- (void)setInnerWidth:(CGFloat)innerWidth outerWidth:(CGFloat)outerWidth;

@end

NS_ASSUME_NONNULL_END
