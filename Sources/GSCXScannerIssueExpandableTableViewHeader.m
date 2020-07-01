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

#import "GSCXScannerIssueExpandableTableViewHeader.h"

#import "GSCXImageNames.h"
#import "GSCXUtils.h"
#import "NSLayoutConstraint+GSCXUtilities.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const kGSCXScannerIssueExpandableTableViewHeaderExpandHint = @"Expands the section";

NSString *const kGSCXScannerIssueExpandableTableViewHeaderCollapseHint = @"Collapses the section";

NSString *const kGSCXScannerIssueExpandableTableViewHeaderExpandActionName = @"Expand";

NSString *const kGSCXScannerIssueExpandableTableViewHeaderCollapseActionName = @"Collapse";

@interface GSCXScannerIssueExpandableTableViewHeader ()

/**
 * @c YES if the header's constraints have been initialized, @c NO otherwise.
 */
@property(assign, nonatomic, getter=hasSetupConstraints) BOOL setupConstraints;

@end

@implementation GSCXScannerIssueExpandableTableViewHeader

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
  self = [super initWithReuseIdentifier:reuseIdentifier];
  if (self) {
    _expandable = YES;
    _expandIcon = [[UIButton alloc] initWithFrame:CGRectZero];
    [_expandIcon addTarget:self
                    action:@selector(gscx_toggleIsExpanded)
          forControlEvents:UIControlEventTouchUpInside];
    NSBundle *imageBundle =
        [NSBundle bundleForClass:[GSCXScannerIssueExpandableTableViewHeader class]];
    UIImage *iconImage = [UIImage imageNamed:kGSCXExpandIconImageName
                                    inBundle:imageBundle
               compatibleWithTraitCollection:nil];
    [_expandIcon setImage:iconImage forState:UIControlStateNormal];
    _expandIcon.translatesAutoresizingMaskIntoConstraints = NO;
    // TODO: Remove this if Switch Control behavior is fixed.
    //
    // On iOS 13, Switch Control cannot focus on headers, even if they are marked as accessibility
    // elements. It can focus on the expand icon if it is a UIButton element. To access the button,
    // the header must not be an accessibility element, otherwise it won't let its children be
    // focused. Thus, on iOS 13 only, the header should not be an accessibility element, and its
    // children should be instead. On iOS 12 and before, both Voice Over and Switch Control can
    // access headers, so this is unneeded.
    if (@available(iOS 13.0, *)) {
      self.isAccessibilityElement = NO;
      self.accessibilityElements = @[ self.textLabel, _expandIcon ];
    }
  }
  return self;
}

- (void)updateConstraints {
  [super updateConstraints];
  if (self.hasSetupConstraints) {
    return;
  }
  [self.contentView addSubview:self.expandIcon];
  NSDictionary<NSString *, id> *views = @{@"expandIcon" : self.expandIcon};
  NSDictionary<NSString *, NSNumber *> *metrics = @{@"size" : @(kGSCXMinimumTouchTargetSize)};
  [NSLayoutConstraint gscx_constraintsWithHorizontalFormat:@"[expandIcon(>=size)]|"
                                            verticalFormat:@"[expandIcon(>=size)]"
                                                   options:0
                                                   metrics:metrics
                                                     views:views
                                                 activated:YES];
  [NSLayoutConstraint gscx_constraintsCenteringView:self.expandIcon
                                           withView:self.contentView
                                       horizontally:NO
                                         vertically:YES
                                          activated:YES];
  UITapGestureRecognizer *tapRecognizer =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gscx_toggleIsExpanded)];
  [self addGestureRecognizer:tapRecognizer];
  self.setupConstraints = YES;
}

- (void)setExpandable:(BOOL)expandable {
  _expandable = expandable;
  self.expandIcon.hidden = !expandable;
  // Non expandable headers never display an expand or collapse icon, so it's unintuitive to
  // announce them as buttons.
  if (self.expandable) {
    self.accessibilityTraits = super.accessibilityTraits | UIAccessibilityTraitButton;
  } else {
    self.accessibilityTraits = super.accessibilityTraits & ~UIAccessibilityTraitButton;
  }
  [self gscx_setAccessibilityHint];
  if (!self.isExpandable && self.isExpanded) {
    if (self.expandHeaderToggled) {
      self.expandHeaderToggled(NO);
    }
    self.expanded = NO;
  }
}

- (void)setExpanded:(BOOL)expanded {
  if (expanded && !self.isExpandable) {
    return;
  }
  _expanded = expanded;
  [self.expandIcon setImage:[self gscx_expandIconImage] forState:UIControlStateNormal];
  self.expandIcon.accessibilityLabel = [self gscx_toggleActionName];
  [self gscx_setAccessibilityHint];
}

- (BOOL)accessibilityActivate {
  if (!self.isExpandable) {
    return NO;
  }
  return [self gscx_toggleIsExpanded];
}

- (nullable NSArray<UIAccessibilityCustomAction *> *)accessibilityCustomActions {
  if (!self.isExpandable) {
    return nil;
  }
  UIAccessibilityCustomAction *action =
      [[UIAccessibilityCustomAction alloc] initWithName:[self gscx_toggleActionName]
                                                 target:self
                                               selector:@selector(gscx_toggleIsExpanded)];
  return @[ action ];
}

#pragma mark - Private

/**
 * Toggles @c expanded and invokes @c expandHeaderToggled, if non-nil.
 *
 * @return @c YES if the completion handler was invoked, @c NO if it is nil.
 */
- (BOOL)gscx_toggleIsExpanded {
  if (!self.isExpandable) {
    return NO;
  }
  self.expanded = !self.isExpanded;
  if (self.expandHeaderToggled) {
    self.expandHeaderToggled(self.isExpanded);
    return YES;
  }
  return NO;
}

/**
 * Sets the value of @c accessibilityHint for the current state of @c expandable and @c expanded.
 */
- (void)gscx_setAccessibilityHint {
  if (!self.isExpandable) {
    self.accessibilityHint = nil;
    return;
  }
  self.accessibilityHint = self.isExpanded ? kGSCXScannerIssueExpandableTableViewHeaderCollapseHint
                                           : kGSCXScannerIssueExpandableTableViewHeaderExpandHint;
}

/**
 * @return The name of the custom accessibility action that expands or collapses the section based
 * on the current state of @c expanded.
 */
- (NSString *)gscx_toggleActionName {
  return self.isExpanded ? kGSCXScannerIssueExpandableTableViewHeaderCollapseActionName
                         : kGSCXScannerIssueExpandableTableViewHeaderExpandActionName;
}

/**
 * @return The image of @c expandIcon for the current value of @c expanded.
 */
- (UIImage *)gscx_expandIconImage {
  NSString *imageName = self.isExpanded ? kGSCXCollapseIconImageName : kGSCXExpandIconImageName;
  NSBundle *imageBundle =
      [NSBundle bundleForClass:[GSCXScannerIssueExpandableTableViewHeader class]];
  return [UIImage imageNamed:imageName inBundle:imageBundle compatibleWithTraitCollection:nil];
}

@end

NS_ASSUME_NONNULL_END
