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
@property (weak, nonatomic) IBOutlet IndentedLabel *when;
@property (weak, nonatomic) IBOutlet IndentedLabel *distance;
@property (weak, nonatomic) IBOutlet UIView *photo;
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

- (void)setUser:(PFUser *)user andMessages:(NSArray *)messages location:(PFGeoPoint*)location collectionView:(UICollectionView*)collectionView
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fromUser == %@ AND isRead != true", user.objectId];
    
    NSArray *unreadMessages = [messages filteredArrayUsingPredicate:predicate];
    NSUInteger unreadCount = [unreadMessages count];
    
//    int sex = [[user valueForKey:AppKeySexKey] boolValue];
    id lastMessage = [messages lastObject];
    
//    UIColor *sexColor = (sex == AppMaleUser) ? AppMaleUserColor : AppFemaleUserColor;
    
//    NSLog(@"HERE:%@ AND THERE:%@", here, location);
    
    double distance = [location distanceInKilometersTo:user.location];
//    drawImage([UIImage imageNamed:sex ? @"guy" : @"girl"], self); //SET DEFAULT PICTURE FOR NOW...
    self.distance.text = [self distanceString:distance];
    NSDate *lastMessageDate = lastMessage[AppKeyUpdatedAtKey];
    NSTimeInterval since = [[NSDate date] timeIntervalSinceDate:lastMessageDate];
    self.when.text = messages ? [self sinceString:since] : @"시작하세요!";
    [self circleizeView:self.distance by:0.2f];
    [self circleizeView:self.when by:0.2f];
    
    /*
    [self circleizeView:self.unread by:0.5f];
    [self circleizeView:self.photoView by:0.5f];
    
    [self.lastMessage setTextAlignment:NSTextAlignmentLeft];
    [self.lastMessage setLineBreakMode:NSLineBreakByWordWrapping];
    self.lastMessage.text = [lastMessage[@"msgContent"] stringByAppendingString:@"\n\n"];
    
    
    
    self.unread.text = [self unreadString:unreadCount forUser:user];
    self.unread.alpha = unreadCount > 0 ? 1.0 : 0.0f;
    
     */
    
    [CachedFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        UIImage *profilePhoto = [UIImage imageWithData:data];
        if ([[collectionView visibleCells] containsObject:self]) {
            self.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                drawImage(profilePhoto, self);
                self.alpha = 1.0;
            }];
        }
        
    } fromFile:user.profilePhoto];
    /*
*/
}

- (void) circleizeView:(UIView*) view by:(CGFloat)percent
{
    view.layer.cornerRadius = view.frame.size.height * percent;
    view.layer.masksToBounds = YES;
}
@end
