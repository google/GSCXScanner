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

#import "GSCXContinuousScannerGalleryDetailViewData.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXContinuousScannerGalleryDetailViewData ()

/**
 * The labels in @c stackView describing the failing accessibility check(s) on the UI element.
 */
@property(strong, nonatomic) NSMutableArray<UILabel *> *checkLabels;

@end

@implementation GSCXContinuousScannerGalleryDetailViewData

- (instancetype)init {
  self = [super init];
  if (self != nil) {
    _containerView = [[UIScrollView alloc] init];
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    _stackView = [[UIStackView alloc] init];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [_containerView addSubview:_stackView];
    NSDictionary<NSString *, id> *views = @{@"stackView" : _stackView};
    [NSLayoutConstraint
        activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[stackView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:views]];
    [NSLayoutConstraint
        activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[stackView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:views]];
    _checkLabels = [NSMutableArray array];
  }
  return self;
}

- (void)addCheckWithTitle:(NSString *)title contents:(NSString *)contents {
  UILabel *titleLabel = [[UILabel alloc] init];
  titleLabel.text = title;
  titleLabel.numberOfLines = 0;
  titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
  titleLabel.textColor = self.textColor;
  [self.stackView addArrangedSubview:titleLabel];
  [self.checkLabels addObject:titleLabel];
  UILabel *contentsLabel = [[UILabel alloc] init];
  contentsLabel.text = contents;
  contentsLabel.numberOfLines = 0;
  contentsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  contentsLabel.textColor = self.textColor;
  [self.stackView addArrangedSubview:contentsLabel];
  [self.checkLabels addObject:contentsLabel];
}

- (void)didLayoutSubviews {
  self.containerView.contentSize = self.stackView.frame.size;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
  self.containerView.backgroundColor = backgroundColor;
  _backgroundColor = backgroundColor;
}

- (void)setTextColor:(UIColor *)textColor {
  for (UILabel *label in self.checkLabels) {
    label.textColor = textColor;
  }
  _textColor = textColor;
}

@end

NS_ASSUME_NONNULL_END
