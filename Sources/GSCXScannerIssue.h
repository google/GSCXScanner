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
 * Encapsulates information about all accessibility issues discovered during a scan for a single
 * element.
 */
@interface GSCXScannerIssue : NSObject

/**
 * The names of all the checks the element failed.
 */
@property(strong, nonatomic) NSArray<NSString *> *gtxCheckNames;

/**
 * The descriptions of all the checks the element failed.
 */
@property(strong, nonatomic) NSArray<NSString *> *gtxCheckDescriptions;

/**
 * The memory address of the associated element as an integer. Must be an integer instead of a
 * pointer because we only care about comparing the addresses of two issues. We do not want to
 * accidentally retain elements or have users attempt to access their properties.
 */
@property(assign, nonatomic) NSUInteger elementAddress;

/**
 * The class of the associated element.
 */
@property(strong, nonatomic) Class elementClass;

/**
 * The frame of the associated element in screen coordinates.
 */
@property(assign, nonatomic) CGRect frame;

/**
 * The accessibility label of the associated element.
 */
@property(strong, nonatomic, nullable) NSString *accessibilityLabel;

/**
 * The accessibility identifier of the associated element.
 */
@property(strong, nonatomic, nullable) NSString *accessibilityIdentifier;

/**
 * A human-readable description of the associated element.
 */
@property(strong, nonatomic, nullable) NSString *elementDescription;

/**
 * Initializes a GSCXScannerIssue instance with given check names, descriptions,
 * and frame. Frame should be in screen coordinates.
 *
 * @param gtxCheckNames An array of strings representing all the check names associated with a
 * single element. Must have equal count to @c gtxCheckDescriptions.
 * @param gtxCheckDescriptions An array of strings representing all the descriptions associated
 * with a single element. Must have equal count to @c gtxCheckNames.
 * @param frameInScreenBounds The frame of the element with accessibility issues, in screen
 * coordinates.
 * @param accessibilityLabel The accessibility label of the UI element with accessibility issues.
 * @param elementDescription A description of the failing element.
 *
 * @return An initialized GSCXScannerIssue instance.
 */
- (instancetype)initWithCheckNames:(NSArray<NSString *> *)gtxCheckNames
                 checkDescriptions:(NSArray<NSString *> *)gtxCheckDescriptions
                    elementAddress:(NSUInteger)elementAddress
                      elementClass:(Class)elementClass
               frameInScreenBounds:(CGRect)frameInScreenBounds
                accessibilityLabel:(nullable NSString *)accessibilityLabel
           accessibilityIdentifier:(nullable NSString *)accessibilityIdentifier
                elementDescription:(NSString *)elementDescription;

/**
 * Constructs a new @c GSCXScannerIssue instance representing an issue with the same UI element,
 * combining the underlying GTX issues of @c self and @c issue.
 *
 * @param issue The issue to combine this issue with. Must represent the same associated element, as
 * determined by @c hasEqualElementAsIssue:
 * @return A @c GSCXScannerIssue instance with the same associated element as @c self and @c issue
 * with the combined set of unique GTX checks and descriptions.
 */
- (instancetype)issueByCombiningWithDuplicateIssue:(GSCXScannerIssue *)duplicateIssue;

/**
 * Constructs a GSCXScannerIssue instance with given check names, descriptions,
 * and frame. Frame should be in screen coordinates.
 *
 * @param gtxCheckNames An array of strings representing all the check names associated with a
 * single element. Must have equal count to @c gtxCheckDescriptions.
 * @param gtxCheckDescriptions An array of strings representing all the descriptions associated
 * with a single element. Must have equal count to @c gtxCheckNames.
 * @param frameInScreenBounds The frame of the element with accessibility issues, in screen
 * coordinates.
 * @param accessibilityLabel The accessibility label of the UI element with accessibility issues.
 *
 * @return A GSCXScannerIssue instance.
 */
+ (instancetype)issueWithCheckNames:(NSArray<NSString *> *)gtxCheckNames
                  checkDescriptions:(NSArray<NSString *> *)gtxCheckDescriptions
                     elementAddress:(NSUInteger)elementAddress
                       elementClass:(Class)elementClass
                frameInScreenBounds:(CGRect)frameInScreenBounds
                 accessibilityLabel:(nullable NSString *)accessibilityLabel
            accessibilityIdentifier:(nullable NSString *)accessibilityIdentifier;

/**
 * Constructs a GSCXScannerIssue instance with given check names, descriptions,
 * and frame. Frame should be in screen coordinates.
 *
 * @param gtxCheckNames An array of strings representing all the check names associated with a
 * single element. Must have equal count to @c gtxCheckDescriptions.
 * @param gtxCheckDescriptions An array of strings representing all the descriptions associated
 * with a single element. Must have equal count to @c gtxCheckNames.
 * @param frameInScreenBounds The frame of the element with accessibility issues, in screen
 * coordinates.
 * @param accessibilityLabel The accessibility label of the UI element with accessibility issues.
 * @param elementDescription A description of the failing element.
 *
 * @return A GSCXScannerIssue instance.
 */
+ (instancetype)issueWithCheckNames:(NSArray<NSString *> *)gtxCheckNames
                  checkDescriptions:(NSArray<NSString *> *)gtxCheckDescriptions
                     elementAddress:(NSUInteger)elementAddress
                       elementClass:(Class)elementClass
                frameInScreenBounds:(CGRect)frameInScreenBounds
                 accessibilityLabel:(nullable NSString *)accessibilityLabel
            accessibilityIdentifier:(nullable NSString *)accessibilityIdentifier
                 elementDescription:(NSString *)elementDescription;

/**
 * The number of accessibility issues associated with this issue.
 */
- (NSUInteger)underlyingIssueCount;

/**
 * @return A HTML description of the issue.
 */
- (NSString *)htmlDescription;

/**
 * Determines if the element associated with this issue is the same as the element associated with
 * @c issue. There is no deterministic way to determine if two issues have the same associated
 * element, so a variety of heuristics are used. These heuristics are guaranteed to be stable across
 * runs of the program. They are guaranteed to be reflexive and symmetric but _not_ transitive.
 *
 * @param issue The issue whose element to compare with this issue's element.
 * @return @c YES if both issues' associated elements are the same, @c NO otherwise.
 */
- (BOOL)hasEqualElementAsIssue:(GSCXScannerIssue *)issue;

/**
 * Returns the unique issues in @c array. Duplicates are combined into a single issue containing the
 * unique GTX check names and descriptions.
 *
 * @param array An array of @c GSCXScannerIssue instances to dedupe.
 * @return An array of unique @c GSCXScannerIssue instances.
 */
+ (NSArray<GSCXScannerIssue *> *)arrayByDedupingArray:(NSArray<GSCXScannerIssue *> *)array;

@end

NS_ASSUME_NONNULL_END
