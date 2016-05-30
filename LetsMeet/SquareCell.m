//
//  SquareCell.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 29..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "SquareCell.h"
#import "PFUser+Attributes.h"
#import "AppEngine.h"   
#import "CachedFile.h"
#import "IndentedLabel.h"

@interface SquareCell()
@property (weak, nonatomic) IBOutlet IndentedLabel *distance;
@property (weak, nonatomic) IBOutlet IndentedLabel *unread;
@property (weak, nonatomic) IBOutlet IndentedLabel *nickname;
@property (weak, nonatomic) IBOutlet IndentedLabel *broadcast;
@property (weak, nonatomic) IBOutlet UIView *photo;
@property (weak, nonatomic) UICollectionView *parent;
@end


@implementation SquareCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"DEALLOC CELL");
}

- (NSString*) distanceString:(double)distance
{
    if (distance > 500) {
        return [NSString stringWithFormat:@"TOO FAR!"];
    }
    else if (distance < 1.0f) {
        return [NSString stringWithFormat:@"%.0fm", distance*1000];
    }
    else {
        return [NSString stringWithFormat:@"%.0fkm", distance];
    }
    
}

- (NSString*) sinceString:(NSTimeInterval) since
{
    if (since < 60.f) {
        return [NSString stringWithFormat:@"%.0f 초전", since];
    }
    else if (since < 60.f*60.f) {
        return [NSString stringWithFormat:@"%.0f 분전", since/60.f];
    }
    else if (since < 60.f*60.f*24.f) {
        return [NSString stringWithFormat:@"%.0f 일전", since/(60.f*60.f)];
    }
    else if (since < 60.f*60.f*24.f*7.f) {
        return [NSString stringWithFormat:@"%.0f 주전", since/(60.f*60.f*24.f)];
    }
    else if (since < 60.f*60.f*24.f*7*30.f) {
        return [NSString stringWithFormat:@"%.0f 개월전", since/(60.f*60.f*24.f*7.f)];
    }
    else {
        return @"TOO LONG";
    }
}

- (NSString*) unreadString:(NSUInteger)count
{
    return [NSString stringWithFormat:@"%ld", (unsigned long)count];
}

- (void)setUnreadCount:(NSArray *)messages
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fromUser == %@ AND isRead != true", self.user.objectId];
    NSUInteger count = [[messages filteredArrayUsingPredicate:predicate] count];
    self.unread.text = [NSString stringWithFormat:@"%ld", count];
    self.unread.alpha = count > 0 ? 1.0 : 0.0f;
    [self circleizeView:self.unread by:0.5f];
}

- (void)setDistanceMessage:(PFGeoPoint*)location
{
    double distance = [location distanceInKilometersTo:self.user.location];
    self.distance.text = [self distanceString:distance];
    [self circleizeView:self.distance by:0.2f];
}

- (void)setUserNickname
{
    self.nickname.text = self.user.nickname;
    [self circleizeView:self.nickname by:0.1f];
}

- (void)setUser:(PFUser *)user andMessages:(NSArray *)messages location:(PFGeoPoint*)location collectionView:(UICollectionView*)collectionView
{
    _user = user;
    [self setUnreadCount:messages];
    [self setDistanceMessage:location];
    [self setUserNickname];
    
    self.parent = collectionView;
    
    NSDate *lastBroadcast = user.broadcastMessageAt;
    
    NSTimeInterval secs = fabs([lastBroadcast timeIntervalSinceNow]);
    self.broadcast.alpha = lastBroadcast ? (secs < [user.broadcastDuration floatValue] ? 1 : 0) : 0;

    self.backgroundColor = self.user.sex ? AppMaleUserColor : AppFemaleUserColor;
}

- (void)setProfilePhoto:(UIImage*)photo
{
    self.photo.alpha = 0.0;
    drawImage(photo, self.photo);
    [UIView animateWithDuration:0.2 animations:^{
        self.photo.alpha = 1.0;
    }];

}

- (void)openBroadcastMessage
{
    UIView *view = self.broadcast;
    
    [UIView animateWithDuration:0.3/1.5 animations:^{
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        self.broadcast.alpha = 5.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
            self.broadcast.alpha = 7.0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                view.transform = CGAffineTransformIdentity;
                self.broadcast.alpha = 1.0;
            }];
        }];
    }];
}

- (void)closeBroadcastMessage
{
    UIView *view = self.broadcast;
    
    [UIView animateWithDuration:0.3/1.5 animations:^{
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        self.broadcast.alpha = 7.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
            self.broadcast.alpha = 5.0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                view.transform = CGAffineTransformIdentity;
                self.broadcast.alpha = 0.0;
            } completion:^(BOOL finished) {
            }];
        }];
    }];

}

- (void)setBroadcastMessage:(NSString *)message duration:(NSNumber *)duration
{
    self.user.broadcastMessage = message;
    self.user.broadcastMessageAt = [NSDate date];
    self.user.broadcastDuration = duration;
    self.broadcast.text = message;
    [self openBroadcastMessage];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([duration floatValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray * cells = [self.parent visibleCells];
        [cells enumerateObjectsUsingBlock:^(SquareCell* cell, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([cell.user.objectId isEqualToString:self.user.objectId]) {
                [cell closeBroadcastMessage];
                *stop = YES;
            }
        }];
    });
    
}

- (void) circleizeView:(UIView*) view by:(CGFloat)percent
{
    view.layer.cornerRadius = view.frame.size.height * percent;
    view.layer.masksToBounds = YES;
}
@end
