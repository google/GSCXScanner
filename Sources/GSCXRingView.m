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

#import "GSCXRingView.h"

#import "GSCXUtils.h"

NS_ASSUME_NONNULL_BEGIN

const CGFloat kGSCXRingViewDefaultWidth = 4.0f;

@implementation GSCXRingView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _ringColor = [GSCXRingView defaultColor];
    _ringWidth = kGSCXRingViewDefaultWidth;
    self.backgroundColor = [UIColor clearColor];
    self.isAccessibilityElement = YES;
  }
  return self;
}

+ (instancetype)ringViewAroundFocusRect:(CGRect)focusRect {
  return [GSCXRingView ringViewAroundFocusRect:focusRect ringWidth:kGSCXRingViewDefaultWidth];
}

+ (instancetype)ringViewAroundFocusRect:(CGRect)focusRect ringWidth:(CGFloat)ringWidth {
  CGFloat width = MAX(CGRectGetWidth(focusRect) + ringWidth, kGSCXMinimumTouchTargetSize);
  CGFloat height = MAX(CGRectGetHeight(focusRect) + ringWidth, kGSCXMinimumTouchTargetSize);
  CGRect ringFrame = CGRectMake(CGRectGetMidX(focusRect) - width / 2.0,
                                CGRectGetMidY(focusRect) - height / 2.0, width, height);
  GSCXRingView *ringView = [[GSCXRingView alloc] initWithFrame:ringFrame];
  ringView.ringWidth = ringWidth;
  return ringView;
}

- (void)setRingWidth:(CGFloat)ringWidth {
  _ringWidth = ringWidth;
  [self setNeedsDisplay];
}

- (void)setRingColor:(UIColor *)ringColor {
  _ringColor = ringColor;
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
  // Inset by half the ring width on each side, because stroking a path fills half of the line width
  // on one side of the line and half on the other. Without the inset, the stroke would be halfway
  // outside the bounds of the ring view and be clipped.
  CGFloat cornerRadius = self.ringWidth / 2.0f;
  UIBezierPath *path =
      [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, cornerRadius, cornerRadius)
                                 cornerRadius:cornerRadius];
  path.lineWidth = self.ringWidth;
  [self.ringColor setStroke];
  [path stroke];
}

+ (UIColor *)defaultColor {
  return [UIColor colorWithRed:239.0 / 255.0 green:109.0 / 255.0 blue:0.0 alpha:1.0];
}

@end

NS_ASSUME_NONNULL_END
