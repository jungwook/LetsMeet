//
//  UserCell.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 19..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserCell.h"
#import "AppEngine.h"
#import "IndentedLabel.h"

@interface UserCell()
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet IndentedLabel *unread;
@property (weak, nonatomic) IBOutlet UILabel *lastMessage;
@property (weak, nonatomic) IBOutlet IndentedLabel *distance;
@property (weak, nonatomic) IBOutlet IndentedLabel *when;

@property (weak, nonatomic) PFObject *user;
@end


@implementation UserCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.unread setAutoresizingMask:UIViewAutoresizingNone];
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
        return [NSString stringWithFormat:@"%.0f m", distance*1000];
    }
    else {
        return [NSString stringWithFormat:@"%.0f km", distance];
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

- (NSString*) unreadString:(NSUInteger)count forUser:(PFUser*) user
{
    return [NSString stringWithFormat:@"%ld", count];
}

- (void)setUser:(PFUser *)user andMessages:(NSArray *)messages
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fromUser.objectId == %@ AND isRead == false", user.objectId];
    NSUInteger unreadCount = [[messages filteredArrayUsingPredicate:predicate] count];
    
    int sex = [[user valueForKey:@"sex"] boolValue];
    PFObject* lastMessage = [messages lastObject];
    
    UIColor *sexColor = sex ? [UIColor colorWithRed:255.f/255.0f green:111.f/255.0f blue:207.f/255.0f alpha:1] : [UIColor colorWithRed:42.f/255.0f green:111.f/255.0f blue:207.f/255.0f alpha:1];
    
    PFGeoPoint *location = user[@"location"];
    PFGeoPoint *here = [[AppEngine engine] currentLocation];
    
    double distance = [here distanceInKilometersTo:location];
    self.distance.text = [self distanceString:distance];
    self.nickname.text = user[@"nickname"];
    self.nickname.textColor = sexColor;
    
    [self circleizeView:self.unread by:0.5f];
    [self circleizeView:self.photoView by:0.5f];
    [self circleizeView:self.distance by:0.2f];
    [self circleizeView:self.when by:0.2f];
    
    [self.lastMessage setTextAlignment:NSTextAlignmentLeft];
    [self.lastMessage setLineBreakMode:NSLineBreakByWordWrapping];
    self.lastMessage.text = [lastMessage[@"msgContent"] stringByAppendingString:@"\n\n"];
    
    NSDate *lastMessageDate = [lastMessage updatedAt];
    
    NSTimeInterval since = [[NSDate date] timeIntervalSinceDate:lastMessageDate];
    self.when.text = messages ? [self sinceString:since] : @"시작하세요!";
    
    self.unread.text = [self unreadString:unreadCount forUser:user];
    self.unread.alpha = unreadCount > 0 ? 1.0 : 0.0f;
}

- (void) circleizeView:(UIView*) view by:(CGFloat)percent
{
    view.layer.cornerRadius = view.frame.size.height * percent;
    view.layer.masksToBounds = YES;
}

@end