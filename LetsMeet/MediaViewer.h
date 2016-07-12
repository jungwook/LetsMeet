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

@interface MediaView : UIButton
@property (nonatomic, assign) BOOL isCircle;
@property (nonatomic, assign) BOOL showsShadow;
@property (nonatomic, assign) BOOL showsSex;
@property (nonatomic, assign) BOOL showsBorder;
- (void) setImage:(UIImage *)image;
- (void) loadMediaFromMessage:(Bullet*)message completion:(S3GetBlock)block;
- (void) loadMediaFromUserMedia:(UserMedia*)media animated:(BOOL)animated;
- (void) loadMediaFromUserMedia:(UserMedia *)media completion:(S3GetBlock)block;
- (void) loadMediaFromUser:(User*)user animated:(BOOL)animated;
- (void) loadMediaFromUser:(User*)user completion:(S3GetBlock)block animated:(BOOL)animated;
- (void) setMapLocationForUser:(User*)user;
@end

@interface MediaViewer : UIView <MKMapViewDelegate>
+ (void)showMediaFromView:(UIView*)view filename:(id)filename mediaType:(MediaTypes)mediaType isReal:(BOOL)isReal;
+ (void)showMapFromView:(UIView*)view user:(User*)user photo:(UIImage*)photo;
@end
