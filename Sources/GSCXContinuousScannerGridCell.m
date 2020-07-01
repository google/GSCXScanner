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

#import "GSCXContinuousScannerGridCell.h"

#import "NSLayoutConstraint+GSCXUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@implementation GSCXContinuousScannerGridCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _screenshot = [[UIImageView alloc] init];
    _screenshot.translatesAutoresizingMaskIntoConstraints = NO;
    _badge = [[UILabel alloc] init];
    _badge.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _badge.adjustsFontSizeToFitWidth = YES;
    _badge.adjustsFontForContentSizeCategory = YES;
    _badge.translatesAutoresizingMaskIntoConstraints = NO;
    _badgeBackground = [[GSCXColoredView alloc] initWithFrame:CGRectZero];
    _badgeBackground.translatesAutoresizingMaskIntoConstraints = NO;
    _badgeBackground.opaque = NO;
    [self.contentView addSubview:_screenshot];
    [self.contentView addSubview:_badgeBackground];
    [self.contentView addSubview:_badge];
    [NSLayoutConstraint gscx_constraintsCenteringView:_screenshot
                                             withView:_screenshot.superview
                                         horizontally:YES
                                           vertically:YES
                                            activated:YES];
    [_screenshot.leadingAnchor
        constraintGreaterThanOrEqualToAnchor:_screenshot.superview.leadingAnchor]
        .active = YES;
    [_screenshot.topAnchor constraintGreaterThanOrEqualToAnchor:_screenshot.superview.topAnchor]
        .active = YES;
    [_screenshot.trailingAnchor
        constraintLessThanOrEqualToAnchor:_screenshot.superview.trailingAnchor]
        .active = YES;
    [_screenshot.bottomAnchor constraintLessThanOrEqualToAnchor:_screenshot.superview.bottomAnchor]
        .active = YES;
    [_badgeBackground.leadingAnchor constraintEqualToAnchor:_badge.leadingAnchor].active = YES;
    [_badgeBackground.trailingAnchor constraintEqualToAnchor:_badge.trailingAnchor].active = YES;
    [_badgeBackground.topAnchor constraintEqualToAnchor:_badge.topAnchor].active = YES;
    [_badgeBackground.bottomAnchor constraintEqualToAnchor:_badge.bottomAnchor].active = YES;
  }
  return self;
}

@end

NS_ASSUME_NONNULL_END
