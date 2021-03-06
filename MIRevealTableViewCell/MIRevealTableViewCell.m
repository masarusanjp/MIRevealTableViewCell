//
//  MIRevealTableViewCell.m
//  MIRevealTableViewCell
//
//  Created by Masaru Ichikawa on 2012/08/14.
//  Copyright (c) 2012年 Masaru Ichikawa. All rights reserved.
//

#import "MIRevealTableViewCell.h"

#define kMIRevealTableViewCellDefaultAnimationDuration 0.2
#define kMIRevealTableViewCellBackViewShowThreshold 10

@interface MIRevealTableViewCell()

@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, assign) CGPoint currentFrontContentViewOrigin;
@property (nonatomic, assign) CGPoint startFrontContentViewOrigin;
@property (nonatomic, retain) UIView *frontContentView;
@property (nonatomic, retain) UIView *backContentView;

- (void)addDirectionPointForLocation:(CGPoint)currentLocation prevLocation:(CGPoint)prevLocation;
- (NSInteger)calcrateDraggingDirection;
- (void)setTableViewScrollEnabled:(BOOL)enabled;
- (void)touchesEndedProcess;

@end

@implementation MIRevealTableViewCell

@synthesize startLocation                 = _startLocation;
@synthesize currentFrontContentViewOrigin = _currentFrontContentViewOrigin;
@synthesize startFrontContentViewOrigin   = _startFrontContentViewOrigin;
@synthesize frontContentViewDragging      = _frontContentViewDragging;
@synthesize frontContentView              = _frontContentView;
@synthesize backContentView               = _backContentView;
@synthesize revealCellDelegate            = _revealCellDelegate;
@synthesize swipeEnabled                  = _swipeEnabled;
@synthesize isFrontContentViewAnimating   = _isFrontContentViewAnimating;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.frontContentView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.backContentView  = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.frontContentView.backgroundColor = [UIColor clearColor];
        self.backContentView.backgroundColor  = [UIColor clearColor];
        self.swipeEnabled = YES;
        [self.contentView addSubview:self.backContentView];
        [self.contentView addSubview:self.frontContentView];
    }
    return self;
}

- (void)dealloc {
    self.backContentView = nil;
    self.frontContentView = nil;
    self.revealCellDelegate = nil;
    [super dealloc];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (!selected && animated) {
        self.backContentView.hidden = YES;
    }
    else {
        self.backContentView.hidden = NO;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.backContentView.hidden = highlighted;
}

#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.frontContentViewDragging && !self.isFrontContentViewAnimating) {
        CGRect r = self.backContentView.frame;
        r.size = self.contentView.frame.size;
        self.backContentView.frame = r;
        r.origin = self.frontContentView.frame.origin;
        self.frontContentView.frame = r;
    }
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.swipeEnabled) {
        self.startLocation = [[touches anyObject] locationInView:self.frontContentView];
        self.currentFrontContentViewOrigin = self.contentView.frame.origin;
        self.startFrontContentViewOrigin = self.currentFrontContentViewOrigin;
        
        for (int i = 0; i < kMIRevealTableViewCellPointsSize; i++) {
            _directionPoints[i] = 0;
        }
        _directionPointCursor = 0;
        
        if ([self.revealCellDelegate respondsToSelector:@selector(revealTableViewCellDidBeginTouchesCell:)]) {
            [self.revealCellDelegate revealTableViewCellDidBeginTouchesCell:self];
        }
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.swipeEnabled) {
        
        CGPoint pt = [[touches anyObject] locationInView:self.frontContentView];
        CGSize div = CGSizeMake(pt.x - self.startLocation.x, pt.y - self.startLocation.y);

        
        CGPoint currentLocation = self.currentFrontContentViewOrigin;
        currentLocation.x += div.width;
        currentLocation.y += div.height;
        
        // TODO:
        if (currentLocation.x > 0) {
            currentLocation.x = 0;
        }
        
        [self addDirectionPointForLocation:currentLocation prevLocation:self.currentFrontContentViewOrigin];
        
        self.currentFrontContentViewOrigin = currentLocation;
        
        if (abs(self.currentFrontContentViewOrigin.x - self.startFrontContentViewOrigin.x) > 4) {
            self.frontContentViewDragging = YES;
            [self setTableViewScrollEnabled:NO];
        }
        if ([self.revealCellDelegate respondsToSelector:@selector(revealTableViewCellDidDragFrontView:position:)]) {
            [self.revealCellDelegate revealTableViewCellDidDragFrontView:self position:self.currentFrontContentViewOrigin];
        }
        if (self.frontContentViewDragging) {
            self.highlighted = NO;
            CGRect r = self.frontContentView.frame;
            r.origin.x = currentLocation.x;
            self.frontContentView.frame = r;
        }
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEndedProcess {
    if (self.swipeEnabled) {
        if (self.frontContentViewDragging) {
            self.frontContentViewDragging = NO;
            [self setTableViewScrollEnabled:YES];
            
            NSInteger direction = [self calcrateDraggingDirection];
            if (fabs(self.currentFrontContentViewOrigin.x - self.startFrontContentViewOrigin.x) < kMIRevealTableViewCellBackViewShowThreshold) {
                [self hideBackContentViewAnimated:YES];
            }
            else {
                if (direction == kMIRevealTableViewCellSlideDirectionLeft) {
                    [self showBackContentViewAnimated:YES];
                }
                else {
                    [self hideBackContentViewAnimated:YES];
                }
            }
        }
        if ([self.revealCellDelegate respondsToSelector:@selector(revealTableViewCellDidEndTouchesCell:)]) {
            [self.revealCellDelegate revealTableViewCellDidEndTouchesCell:self];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEndedProcess];
    [super touchesEnded:touches withEvent:event];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEndedProcess];
    [super touchesCancelled:touches withEvent:event];
}

#pragma mark - public methods

- (void)showBackContentViewAnimated:(BOOL)animated {
    CGRect r = self.frontContentView.frame;
    r.origin.x = -r.size.width;
     
    if ([self.revealCellDelegate respondsToSelector:@selector(revealTableViewCellWillShowBackContentView:)]) {
        [self.revealCellDelegate revealTableViewCellWillShowBackContentView:self];
    }
    
    if (animated) {
        CGFloat duration = kMIRevealTableViewCellDefaultAnimationDuration;
        CGFloat width = self.contentView.frame.size.width;
        if (width == 0) {
            width = 1;
        }
        CGFloat t = duration * (width+self.currentFrontContentViewOrigin.x) / width;
        if (t > duration) {
            t = duration;
        }
        self.isFrontContentViewAnimating = YES;
        [UIView animateWithDuration:t
                             delay:0.0
                           options:UIViewAnimationCurveLinear
                        animations:^{
                            self.frontContentView.frame = r;
                        }
                        completion:^(BOOL finished) {
                            self.isFrontContentViewAnimating = NO;
                            if ([self.revealCellDelegate respondsToSelector:@selector(revealTableViewCellDidShowBackContentView:)]) {
                                [self.revealCellDelegate revealTableViewCellDidShowBackContentView:self];
                            }
                        }];
    }
    else {
        self.frontContentView.frame = r;
        if ([self.revealCellDelegate respondsToSelector:@selector(revealTableViewCellDidShowBackContentView:)]) {
            [self.revealCellDelegate revealTableViewCellDidShowBackContentView:self];
        }
    }
}

- (void)hideBackContentViewAnimated:(BOOL)animated {
    CGRect r = self.frontContentView.frame;
    r.origin.x = 0;
    
    if ([self.revealCellDelegate respondsToSelector:@selector(revealTableViewCellWillHideBackContentView:)]) {
        [self.revealCellDelegate revealTableViewCellWillHideBackContentView:self];
    }
    
    if (animated) {
        CGFloat duration = kMIRevealTableViewCellDefaultAnimationDuration;
        CGFloat width = self.contentView.frame.size.width;
        if (width == 0) {
            width = 1;
        }
        
        CGFloat t = duration * (-self.currentFrontContentViewOrigin.x) / width;
        if (t > duration) {
            t = duration;
        }
        self.isFrontContentViewAnimating = YES;
        [UIView animateWithDuration:t
                             delay:0.0
                           options:UIViewAnimationCurveLinear
                        animations:^{
                            self.frontContentView.frame = r;
                        }
                        completion:^(BOOL finished) {
                            self.isFrontContentViewAnimating = NO;
                            if ([self.revealCellDelegate respondsToSelector:@selector(revealTableViewCellDidHideBackContentView:)]) {
                                [self.revealCellDelegate revealTableViewCellDidHideBackContentView:self];
                            }
                        }];
    }
    else {
        self.frontContentView.frame = r;
        if ([self.revealCellDelegate respondsToSelector:@selector(revealTableViewCellDidHideBackContentView:)]) {
            [self.revealCellDelegate revealTableViewCellDidHideBackContentView:self];
        }
    }
}

#pragma mark - helper functions

- (void)setTableViewScrollEnabled:(BOOL)enabled {
    UIView *view = self.superview;
    
    while (view != nil && ![view isKindOfClass:[UITableView class]]) {
        view = view.superview;
    }
    
    [(UITableView*)view setScrollEnabled:enabled];
}

- (void)addDirectionPointForLocation:(CGPoint)pos prevLocation:(CGPoint)prevLocation{
    
    // タッチ位置は揺れるので正確な方向を知るためにどちら側に指を動かしたのかを記録しておく
    CGFloat point = 0.0;
    if (pos.x >= prevLocation.x) {
        point = pos.x - prevLocation.x;
        if (point > 5.0) {
            point = 5.0;
        }
    }
    else {
        point = pos.x - prevLocation.x;
        if (point < -5.0) {
            point = -5.0;
        }
    }
    
    _directionPoints[_directionPointCursor]  = point;
    _directionPointCursor++;
    if (_directionPointCursor >= kMIRevealTableViewCellPointsSize) {
        _directionPointCursor = 0;
    }
}

- (NSInteger)calcrateDraggingDirection {
    CGFloat point = 0.0;
    
    for (NSInteger i = 0; i < kMIRevealTableViewCellPointsSize; i++) {
        point += _directionPoints[i];
    }
    
    if (point > 0) {
        return kMIRevealTableViewCellSlideDirectionRight;
    }
    else {
        return kMIRevealTableViewCellSlideDirectionLeft;
    }
}

@end
