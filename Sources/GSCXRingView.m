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

NS_ASSUME_NONNULL_BEGIN

const CGFloat kGSCXRingViewDefaultInnerWidth = 2.0f;
const CGFloat kGSCXRingViewDefaultOuterWidth = 4.0f;

/**
 * The minimum size the width or height of a rectangle can be to be accessible.
 */
static const CGFloat kGSCXRingViewMinimumSize = 44.0;

@implementation GSCXRingView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _innerColor = [UIColor blackColor];
    _outerColor = [UIColor yellowColor];
    _innerWidth = kGSCXRingViewDefaultInnerWidth;
    _outerWidth = kGSCXRingViewDefaultOuterWidth;
    self.backgroundColor = [UIColor clearColor];
    self.isAccessibilityElement = YES;
  }
  return self;
}

+ (instancetype)ringViewAroundFocusRect:(CGRect)focusRect {
  return [GSCXRingView ringViewAroundFocusRect:focusRect
                                    innerWidth:kGSCXRingViewDefaultInnerWidth
                                    outerWidth:kGSCXRingViewDefaultOuterWidth];
}

+ (instancetype)ringViewAroundFocusRect:(CGRect)focusRect
                             innerWidth:(CGFloat)innerWidth
                             outerWidth:(CGFloat)outerWidth {
  NSParameterAssert(innerWidth < outerWidth);
  CGFloat width = MAX(CGRectGetWidth(focusRect) + outerWidth, kGSCXRingViewMinimumSize);
  CGFloat height = MAX(CGRectGetHeight(focusRect) + outerWidth, kGSCXRingViewMinimumSize);
  CGRect ringFrame = CGRectMake(CGRectGetMidX(focusRect) - width / 2.0,
                                CGRectGetMidY(focusRect) - height / 2.0, width, height);
  GSCXRingView *ringView = [[GSCXRingView alloc] initWithFrame:ringFrame];
  [ringView setInnerWidth:innerWidth outerWidth:outerWidth];
  return ringView;
}

- (void)setInnerWidth:(CGFloat)innerWidth outerWidth:(CGFloat)outerWidth {
  NSParameterAssert(innerWidth < outerWidth);
  _innerWidth = innerWidth;
  _outerWidth = outerWidth;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGFloat cornerRadius = self.outerWidth / 2.0f;
  UIBezierPath *path =
      [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, cornerRadius, cornerRadius)
                                 cornerRadius:cornerRadius];

  CGContextSetStrokeColorWithColor(context, [self.outerColor CGColor]);
  path.lineWidth = self.outerWidth;
  [path stroke];

  CGContextSetStrokeColorWithColor(context, [self.innerColor CGColor]);
  path.lineWidth = self.innerWidth;
  [path stroke];
}

@end

NS_ASSUME_NONNULL_END
