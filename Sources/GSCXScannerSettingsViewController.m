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

#import "GSCXScannerSettingsViewController.h"

#import "GSCXScannerOverlayViewController.h"
#import "GSCXScannerSettingsItem.h"
#import "UIViewController+GSCXAppearance.h"

NS_ASSUME_NONNULL_BEGIN

// TODO: Localize these strings and load them from an external resource instead of
// hardcoding them.

NSString *const kGSCXScannerSettingsTableAccessibilityIdentifier =
    @"kGSCXScannerSettingsTableAccessibilityIdentifier";

NSString *const kGSCXSettingsContinuousScanButtonText = @"Start Continuous Scanning";

NSString *const kGSCXSettingsContinuousScanButtonAccessibilityIdentifier =
    @"kGSCXSettingsContinuousScanButtonAccessibilityIdentifier";

NSString *const kGSCXSettingsNoIssuesFoundText = @"Continuous Scan Report Empty.";

NSString *const kGSCXSettingsReportButtonTitle = @"Continuous Scan Report";

NSString *const kGSCXSettingsReportButtonAccessibilityIdentifier =
    @"kGSCXSettingsReportButtonAccessibilityIdentifier";

/**
 * The duration, in seconds, of the entrance and exit animation of the settings view controller.
 */
static const NSTimeInterval kGSCXScannerSettingsAnimationDurationSeconds = 0.4;

/**
 * The easing curve of the entrance and exit animation of the settings view controller.
 */
static const UIViewAnimationOptions kGSCXScannerSettingsAnimationCurve =
    UIViewAnimationOptionCurveEaseOut;

/**
 * The reuse identifier for the default cell in the settings table.
 */
static NSString *const kGSCXScannerSettingsTableViewCellReuseIdentifier = @"settingsItemCell";

@interface GSCXScannerSettingsViewController () <UITableViewDataSource> {
  /**
   * The frame of settings page before its entrance animation and after its exit animation. This is
   * used to set @c initialConstraints.
   */
  CGRect _initialFrame;
}

/**
 * The blur view used as the background of this view controller.
 */
@property(weak, nonatomic) IBOutlet UIVisualEffectView *blurView;

/**
 * The table containing all options and actions.
 */
@property(weak, nonatomic) IBOutlet UITableView *tableView;

/**
 * The constraints of the blur view before this view controller's entrance
 * animation and after this view controller's exit animation.
 */
@property(strong, nonatomic) NSArray<NSLayoutConstraint *> *initialConstraints;

/**
 * The constraints of the blur view after this view controller's entrance animation, making it a
 * centered modal.
 */
@property(strong, nonatomic) NSArray<NSLayoutConstraint *> *modalConstraints;

/**
 * The items used to populate the table.
 */
@property(strong, nonatomic) NSArray<id<GSCXScannerSettingsItemConfiguring>> *settingsItems;

/**
 * Listens for taps on table view cells containing switches.
 */
@property(strong, nonatomic) UITapGestureRecognizer *switchTapGestureRecognizer;

/**
 * Scans the view hierarchy for accessibility issues.
 */
@property(strong, nonatomic) GSCXScanner *scanner;

/**
 * Prevents @c scanner from scanning the table view or its descendants. This prevents the scanner
 * from scanning the table view during an animation, which produces false positives.
 */
@property(strong, nonatomic, nullable) id<GTXExcludeListing> tableViewHierarchyExcludeList;

/**
 * Animates any view hierarchy changes that occur in @c animations using the default duration and
 * easing curve. Animating constraints is automatically handled. If the user has enabled "reduce
 * motion" in the Settings app, the transitions are applied immediately without animation.
 *
 * @param animations A block containing view hierarchy changes to be animated. Supports animated
 * constraints.
 * @param completion An optional completion block to run when the animation has finished. The
 * parameter passed to the block is @c YES if the animation completed successfully or @c NO if it
 * hasn't.
 */
- (void)gscx_animate:(void (^)(void))animations completion:(nullable void (^)(BOOL))completion;

/**
 * Sets @c initialConstraints to an array of @c NSLayoutConstraint instances that make the same
 * frame as @c _initialFrame.
 */
- (void)gscx_initializeInitialConstraints;

/**
 * Sets @c modalConstraints to an array of @c NSLayoutConstraint instances that make a frame in the
 * center of the screen, covering the center but leaving empty space on the edges.
 */
- (void)gscx_initializeModalConstraints;

@end

@implementation GSCXScannerSettingsViewController

- (instancetype)initWithInitialFrame:(CGRect)frame
                               items:(NSArray<id<GSCXScannerSettingsItemConfiguring>> *)items
                             scanner:(GSCXScanner *)scanner {
  self =
      [super initWithNibName:@"GSCXScannerSettingsViewController"
                      bundle:[NSBundle bundleForClass:[GSCXScannerSettingsViewController class]]];
  if (self) {
    _initialFrame = frame;
    id<GSCXScannerSettingsItemConfiguring> dismissButtonItem =
        [GSCXScannerSettingsItem buttonItemWithTitle:kGSCXDismissSettingsTitle
                                              target:self
                                              action:@selector(gscx_dismissSettings:)
                             accessibilityIdentifier:kGSCXDismissSettingsAccessibilityIdentifier];
    _settingsItems = [items arrayByAddingObject:dismissButtonItem];
    _scanner = scanner;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self gscx_initializeInitialConstraints];
  [self gscx_initializeModalConstraints];
  [NSLayoutConstraint activateConstraints:self.initialConstraints];
  self.tableView.accessibilityIdentifier = kGSCXScannerSettingsTableAccessibilityIdentifier;
  self.tableView.dataSource = self;
  [self.tableView registerClass:[GSCXScannerSettingsTableViewCell class]
         forCellReuseIdentifier:kGSCXScannerSettingsTableViewCellReuseIdentifier];
  self.tableView.alpha = 0.0;
  // Manually setting this value prevents the autolayout constraints in the settings table view
  // cells from shrinking the cells' heights lower than the minimum height of the buttons plus the
  // top and bottom margins. Add 1 to account for the table view cell separators.
  self.tableView.rowHeight = (kGSCXScannerSettingsTableViewCellButtonMinimumHeight +
                              2 * kGSCXScannerSettingsTableViewCellButtonMargin + 1);
  self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
  self.blurView.layer.cornerRadius = kGSCXSettingsCornerRadius;
  self.blurView.clipsToBounds = YES;
  [self gscx_setBlurStyleForCurrentAppearance];

  self.switchTapGestureRecognizer =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gscx_tapped:)];
}

- (void)animateInWithCompletion:(nullable void (^)(BOOL))completion {
  [self gscx_registerExcludeListForTableViewHierarchy];
  __weak __typeof__(self) weakSelf = self;
  // clang-format off
  // Disabling autoformatting because the autoformatter places self and gscx_animate: on separate
  // lines, which doesn't look as good as the keeping them on same line. This is likely because this
  // method accepts multiple block parameters.
  [self gscx_animate:^(void) {
    __typeof__(self) strongSelf = weakSelf;
    [NSLayoutConstraint deactivateConstraints:strongSelf.initialConstraints];
    [NSLayoutConstraint activateConstraints:strongSelf.modalConstraints];
  }
      completion:^(BOOL finished) {
    [weakSelf gscx_animate:^{
      weakSelf.tableView.alpha = 1.0;
    }
        completion:^(BOOL finished) {
      [weakSelf gscx_deregisterExcludeListForTableViewHierarchy];
      if (completion) {
        completion(finished);
      }
    }];
  }];
  // clang-format on
}

- (void)animateOutWithCompletion:(nullable void (^)(BOOL))completion {
  [self gscx_registerExcludeListForTableViewHierarchy];
  __weak __typeof__(self) weakSelf = self;
  // clang-format off
  [self gscx_animate:^(void) {
    weakSelf.tableView.alpha = 0.0;
  }
      completion:^(BOOL finished) {
    [weakSelf gscx_animate:^{
      __typeof__(self) strongSelf = weakSelf;
      [NSLayoutConstraint deactivateConstraints:strongSelf.modalConstraints];
      [NSLayoutConstraint activateConstraints:strongSelf.initialConstraints];
    }
        completion:^(BOOL finished) {
      [weakSelf gscx_deregisterExcludeListForTableViewHierarchy];
      if (completion) {
        completion(finished);
      }
    }];
  }];
  // clang-format on
}

- (BOOL)accessibilityPerformEscape {
  [self gscx_dismissSettings:nil];
  return YES;
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
  [super traitCollectionDidChange:previousTraitCollection];
  [self gscx_setBlurStyleForCurrentAppearance];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return (NSInteger)self.settingsItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GSCXScannerSettingsTableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:kGSCXScannerSettingsTableViewCellReuseIdentifier
                                      forIndexPath:indexPath];
  cell.backgroundColor = [UIColor clearColor];
  cell.textLabel.textColor = [self gscx_textColorForCurrentAppearance];
  [cell.button setTitleColor:[self gscx_textColorForCurrentAppearance]
                    forState:UIControlStateNormal];
  cell.button.titleLabel.adjustsFontSizeToFitWidth = YES;
  cell.button.titleLabel.adjustsFontForContentSizeCategory = YES;
  [self.settingsItems[(NSUInteger)indexPath.row] configureTableViewCell:cell];
  NSMutableAttributedString *attributedTitle;
  if (cell.button.titleLabel.attributedText != nil) {
    attributedTitle = [[NSMutableAttributedString alloc]
        initWithAttributedString:cell.button.titleLabel.attributedText];
  } else {
    attributedTitle =
        [[NSMutableAttributedString alloc] initWithString:cell.button.titleLabel.text];
  }
  [attributedTitle addAttribute:NSForegroundColorAttributeName
                          value:[self gscx_textColorForCurrentAppearance]
                          range:NSMakeRange(0, attributedTitle.string.length)];
  [cell.button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
  [cell setNeedsUpdateConstraints];
  [cell removeGestureRecognizer:self.switchTapGestureRecognizer];
  if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
    cell.isAccessibilityElement = YES;
    [cell addGestureRecognizer:self.switchTapGestureRecognizer];
  } else {
    cell.isAccessibilityElement = NO;
  }
  return cell;
}

#pragma mark - Private

- (void)gscx_setBlurStyleForCurrentAppearance {
  self.blurView.effect =
      [UIBlurEffect effectWithStyle:[self gscx_blurEffectStyleForCurrentAppearance]];
}

- (IBAction)gscx_dismissSettings:(nullable id)sender {
  if (self.dismissBlock) {
    self.dismissBlock(self);
  }
}

- (void)gscx_initializeInitialConstraints {
  NSDictionary<NSString *, id> *views = @{@"blurView" : self.blurView};
  NSDictionary<NSString *, id> *metrics = @{
    @"leading" : @(CGRectGetMinX(_initialFrame)),
    @"width" : @(CGRectGetWidth(_initialFrame)),
    @"top" : @(CGRectGetMinY(_initialFrame)),
    @"height" : @(CGRectGetHeight(_initialFrame))
  };
  NSArray *horizontalConstraints =
      [NSLayoutConstraint constraintsWithVisualFormat:@"|-leading-[blurView(==width)]"
                                              options:0
                                              metrics:metrics
                                                views:views];
  NSArray *verticalConstraints =
      [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[blurView(==height)]"
                                              options:0
                                              metrics:metrics
                                                views:views];
  self.initialConstraints =
      [horizontalConstraints arrayByAddingObjectsFromArray:verticalConstraints];
}

- (void)gscx_initializeModalConstraints {
  CGFloat offset = 0.0;
  NSDictionary<NSString *, id> *views = @{@"blurView" : self.blurView};
  NSDictionary<NSString *, id> *metrics = @{@"offset" : @(offset)};
  NSArray *horizontalConstraints =
      [NSLayoutConstraint constraintsWithVisualFormat:@"|-offset-[blurView]-offset-|"
                                              options:0
                                              metrics:metrics
                                                views:views];
  NSArray *verticalConstraints =
      [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-offset-[blurView]-offset-|"
                                              options:0
                                              metrics:metrics
                                                views:views];
  self.modalConstraints = [horizontalConstraints arrayByAddingObjectsFromArray:verticalConstraints];
}

- (void)gscx_animate:(void (^)(void))animations completion:(nullable void (^)(BOOL))completion {
  // Flush any remaining layout calculations.
  [self.view layoutIfNeeded];
  __weak __typeof__(self) weakSelf = self;
  void (^animationWrapper)(void) = ^(void) {
    __typeof__(self) strongSelf = weakSelf;
    animations();
    // Force a layout change to animate constraint changes, if applicable.
    [strongSelf.view layoutIfNeeded];
  };
  if (UIAccessibilityIsReduceMotionEnabled()) {
    // If the user has enabled reduce motion, running the block outside of UIView
    // animationWithDuration applies the changes immediately instead of animating them.
    animationWrapper();
    completion(YES);
  } else {
    [UIView animateWithDuration:kGSCXScannerSettingsAnimationDurationSeconds
                          delay:0.0
                        options:kGSCXScannerSettingsAnimationCurve
                     animations:animationWrapper
                     completion:completion];
  }
}

- (void)gscx_tapped:(UITapGestureRecognizer *)sender {
  UIView *view = sender.view;
  if ([view isKindOfClass:[UITableViewCell class]]) {
    UITableViewCell *cell = (UITableViewCell *)view;
    if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
      UISwitch *s = (UISwitch *)cell.accessoryView;
      [s setOn:!s.on animated:YES];
      [s sendActionsForControlEvents:UIControlEventValueChanged];
    }
  }
}

- (void)gscx_registerExcludeListForTableViewHierarchy {
  UITableView *tableView = self.tableView;
  self.tableViewHierarchyExcludeList =
      [GTXExcludeListBlock excludeListWithBlock:^BOOL(id element, NSString *checkName) {
        if ([element respondsToSelector:@selector(accessibilityContainer)]) {
          // UIAccessibilityElement instances do not have a superview method, but UITableView uses
          // subclasses of UIAccessibilityElement to represent some things which the scanner flags
          // incorrectly. In those cases, the UITableView is the accessibility container, so
          // checking for that excludeLists only the elements in the settings table view. Other
          // table views are unaffected.
          if ([element accessibilityContainer] == tableView) {
            return YES;
          }
        }
        if (![element respondsToSelector:@selector(superview)]) {
          // The following algorithm will crash if the element does not respond to superview. Only
          // UIView instances can be descendants of the table view, so an element that does not
          // respond to superview is guaranteed not to be in the hierarchy.
          return NO;
        }
        while (element != nil) {
          if (element == tableView) {
            return YES;
          }
          element = [element superview];
        }
        return NO;
      }];
  [self.scanner registerExcludeList:self.tableViewHierarchyExcludeList];
}

- (void)gscx_deregisterExcludeListForTableViewHierarchy {
  [self.scanner deregisterExcludeList:self.tableViewHierarchyExcludeList];
  self.tableViewHierarchyExcludeList = nil;
}

@end

NS_ASSUME_NONNULL_END
