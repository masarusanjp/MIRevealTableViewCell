//
// Copyright 2012 Masaru Ichikawa
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <UIKit/UIKit.h>

#define kMIRevealTableViewCellPointsSize 5


enum MIRevealTableViewCellSlideDirection {
    kMIRevealTableViewCellSlideDirectionLeft = 1,
    kMIRevealTableViewCellSlideDirectionRight = 1 << 1,
};

@protocol MIRevealTableViewCellDelegate;

@interface MIRevealTableViewCell : UITableViewCell {
    CGFloat _directionPoints[kMIRevealTableViewCellPointsSize];
    NSInteger _directionPointCursor;
}

@property (nonatomic, readonly, retain) UIView *frontContentView;
@property (nonatomic, readonly, retain) UIView *backContentView;
@property (nonatomic, assign) id<MIRevealTableViewCellDelegate> revealCellDelegate;

- (void)showBackContentViewAnimated:(BOOL)animated;
- (void)hideBackContentViewAnimated:(BOOL)animated;

@end

@protocol MIRevealTableViewCellDelegate<NSObject>
@optional
- (void)revealTableViewCellDidBeginTouchesCell:(MIRevealTableViewCell*)cell;
- (void)revealTableViewCellDidEndTouchesCell:(MIRevealTableViewCell*)cell;
- (void)revealTableViewCellWillShowBackContentView:(MIRevealTableViewCell*)cell;
- (void)revealTableViewCellDidShowBackContentView:(MIRevealTableViewCell*)cell;
- (void)revealTableViewCellWillHideBackContentView:(MIRevealTableViewCell*)cell;
- (void)revealTableViewCellDidHideBackContentView:(MIRevealTableViewCell*)cell;
@end