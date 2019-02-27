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

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Encapsulates information about all accessibility issues discovered during a scan for a single
 *  element.
 */
@interface GSCXScannerIssue : NSObject

/**
 *  The names of all the checks the element failed.
 */
@property(strong, nonatomic) NSArray<NSString *> *gtxCheckNames;
/**
 *  The descriptions of all the checks the element failed.
 */
@property(strong, nonatomic) NSArray<NSString *> *gtxCheckDescriptions;
/**
 *  The frame of the associated element in screen coordinates.
 */
@property(assign, nonatomic) CGRect frame;
/**
 *  The accessibility label of the associated element.
 */
@property(strong, nonatomic, nullable) NSString *accessibilityLabel;

/**
 *  Initializes a GSCXScannerIssue instance with given check names, descriptions,
 *  and frame. Frame should be in screen coordinates.
 *
 *  @param gtxCheckNames An array of strings representing all the check names associated with a
 *                       single element. Must have equal count to @c gtxCheckDescriptions.
 *  @param gtxCheckDescriptions An array of strings representing all the descriptions associated
 *                              with a single element. Must have equal count to @c gtxCheckNames.
 *  @param frameInScreenBounds The frame of the element with accessibility issues, in screen
 *                             coordinates.
 *  @param accessibilityLabel The accessibility label of the UI element with accessibility issues.
 *  @return An initialized GSCXScannerIssue instance.
 */
- (instancetype)initWithCheckNames:(NSArray<NSString *> *)gtxCheckNames
                 checkDescriptions:(NSArray<NSString *> *)gtxCheckDescriptions
               frameInScreenBounds:(CGRect)frameInScreenBounds
                accessibilityLabel:(nullable NSString *)accessibilityLabel;

/**
 *  Constructs a GSCXScannerIssue instance with given check names, descriptions,
 *  and frame. Frame should be in screen coordinates.
 *
 *  @param gtxCheckNames An array of strings representing all the check names associated with a
 *                       single element. Must have equal count to @c gtxCheckDescriptions.
 *  @param gtxCheckDescriptions An array of strings representing all the descriptions associated
 *                              with a single element. Must have equal count to @c gtxCheckNames.
 *  @param frameInScreenBounds The frame of the element with accessibility issues, in screen
 *                             coordinates.
 *  @param accessibilityLabel The accessibility label of the UI element with accessibility issues.
 *  @return A GSCXScannerIssue instance.
 */
+ (instancetype)issueWithCheckNames:(NSArray<NSString *> *)gtxCheckNames
                  checkDescriptions:(NSArray<NSString *> *)gtxCheckDescriptions
                frameInScreenBounds:(CGRect)frameInScreenBounds
                 accessibilityLabel:(nullable NSString *)accessibilityLabel;

/**
 *  The number of accessibility issues associated with this issue.
 */
- (NSUInteger)underlyingIssueCount;

@end

NS_ASSUME_NONNULL_END
