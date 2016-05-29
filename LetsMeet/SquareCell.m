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

@interface SquareCell()
@property (weak, nonatomic) IBOutlet UIView *photo;

@end


@implementation SquareCell
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
    return [NSString stringWithFormat:@"%ld", (unsigned long)count];
}

- (void)setUser:(PFUser *)user andMessages:(NSArray *)messages collectionView:(UICollectionView*)collectionView
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fromUser == %@ AND isRead != true", user.objectId];
    
    NSArray *unreadMessages = [messages filteredArrayUsingPredicate:predicate];
    NSUInteger unreadCount = [unreadMessages count];
    
    int sex = [[user valueForKey:AppKeySexKey] boolValue];
    id lastMessage = [messages lastObject];
    
    UIColor *sexColor = (sex == AppMaleUser) ? AppMaleUserColor : AppFemaleUserColor;
    
    PFGeoPoint *location = user[AppKeyLocationKey];
    PFGeoPoint *here = [[AppEngine engine] currentLocation];
    
//    NSLog(@"HERE:%@ AND THERE:%@", here, location);
    
    double distance = [here distanceInKilometersTo:location];
    /*
    self.distance.text = [self distanceString:distance];
    self.nickname.text = user[AppKeyNicknameKey];
    self.nickname.textColor = sexColor;
    
    [self circleizeView:self.unread by:0.5f];
    [self circleizeView:self.photoView by:0.5f];
    [self circleizeView:self.distance by:0.2f];
    [self circleizeView:self.when by:0.2f];
    
    [self.lastMessage setTextAlignment:NSTextAlignmentLeft];
    [self.lastMessage setLineBreakMode:NSLineBreakByWordWrapping];
    self.lastMessage.text = [lastMessage[@"msgContent"] stringByAppendingString:@"\n\n"];
    
    NSDate *lastMessageDate = lastMessage[AppKeyUpdatedAtKey];
    
    NSTimeInterval since = [[NSDate date] timeIntervalSinceDate:lastMessageDate];
    self.when.text = messages ? [self sinceString:since] : @"시작하세요!";
    
    self.unread.text = [self unreadString:unreadCount forUser:user];
    self.unread.alpha = unreadCount > 0 ? 1.0 : 0.0f;
    
    drawImage([UIImage imageNamed:sex ? @"guy" : @"girl"], self.photoView); //SET DEFAULT PICTURE FOR NOW...
     */
    
    [CachedFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        UIImage *profilePhoto = [UIImage imageWithData:data];
        if ([[collectionView visibleCells] containsObject:self]) {
            drawImage(profilePhoto, self);
        }
    } fromFile:user.profilePhoto];
}

- (void) circleizeView:(UIView*) view by:(CGFloat)percent
{
    view.layer.cornerRadius = view.frame.size.height * percent;
    view.layer.masksToBounds = YES;
}
@end
