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

#import "GSCXScannerIssueExpandableTableViewCell.h"

#import "NSLayoutConstraint+GSCXUtilities.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The spacing on the leading and trailing sides of the suggestions stack in a
 * @c GSCXScannerIssueExpandableTableViewCell instance.
 */
static const CGFloat kGSCXScannerIssueExpandableTableViewCellHorizontalSpacing = 8.0f;

/**
 * The spacing on the top and bottom of the suggestions stack in a
 * @c GSCXScannerIssueExpandableTableViewCell instance.
 */
static const CGFloat kGSCXScannerIssueExpandableTableViewCellVerticalSpacing = 8.0f;

@interface GSCXScannerIssueExpandableTableViewCell ()

/**
 * @c YES if the constraints have been added to the cell's subviews, @c NO otherwise.
 */
@property(assign, nonatomic, getter=hasAddedConstraints) BOOL addedConstraints;

@end

@implementation GSCXScannerIssueExpandableTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(nullable NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _suggestionStack = [[UIStackView alloc] init];
    _suggestionStack.axis = UILayoutConstraintAxisVertical;
    _suggestionStack.translatesAutoresizingMaskIntoConstraints = NO;
    _suggestionStack.spacing = kGSCXScannerIssueExpandableTableViewCellVerticalSpacing;
  }
  return self;
}

- (void)updateConstraints {
  [super updateConstraints];
  if (self.hasAddedConstraints) {
    return;
  }
  [self.contentView addSubview:self.suggestionStack];
  NSDictionary<NSString *, NSNumber *> *metrics =
      @{@"spacing" : @(kGSCXScannerIssueExpandableTableViewCellHorizontalSpacing)};
  NSDictionary<NSString *, id> *views = @{@"stack" : self.suggestionStack};
  [NSLayoutConstraint gscx_constraintsWithHorizontalFormat:@"|-spacing-[stack]-spacing-|"
                                            verticalFormat:@"|[stack]|"
                                                   options:0
                                                   metrics:metrics
                                                     views:views
                                                 activated:YES];
  self.addedConstraints = YES;
}

@end

NS_ASSUME_NONNULL_END
