//
//  MediaViewer.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 15..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "S3File.h"
@import MapKit;

typedef BOOL(^ShouldRefreshBlock)(NSData * data, NSError * error, BOOL fromCache);

@interface MediaView : UIButton
@property (nonatomic, assign) BOOL isCircle;
- (void)setImage:(UIImage *)image;
- (void) loadMediaFromMessage:(Bullet*)message completion:(S3GetBlock)block;
- (void) loadMediaFromMessage:(Bullet*)message shouldRefresh:(ShouldRefreshBlock)block;
- (void) loadMediaFromUserMedia:(UserMedia*)media;
- (void) loadMediaFromUser:(User*)user;
- (void) loadMediaFromUser:(User*)user completion:(S3GetBlock)block;
- (void) loadMediaFromUser:(User*)user shouldRefresh:(ShouldRefreshBlock)block;
- (void) setMapLocationForUser:(User*)user;
@end

@interface MediaViewer : UIView <MKMapViewDelegate>
+ (void)showMediaFromView:(UIView*)view filename:(id)filename mediaType:(MediaTypes)mediaType isReal:(BOOL)isReal;
+ (void)showMapFromView:(UIView*)view user:(User*)user photo:(UIImage*)photo;
@end
