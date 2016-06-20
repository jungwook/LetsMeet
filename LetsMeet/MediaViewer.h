//
//  MediaViewer.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 15..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "S3File.h"

typedef BOOL(^ShouldRefreshBlock)(NSData * data, NSError * error, BOOL fromCache);

@interface MediaView : UIView
@property (nonatomic, strong) UIImage* image;

- (void) loadMediaFromFile:(id)filename mediaType:(MediaTypes)mediaType completion:(S3GetBlock)block;
- (void) loadMediaFromFile:(id)filename mediaType:(MediaTypes)mediaType shouldRefresh:(ShouldRefreshBlock)block;
- (void) loadMediaFromMessage:(Bullet*)message completion:(S3GetBlock)block;
- (void) loadMediaFromMessage:(Bullet*)message shouldRefresh:(ShouldRefreshBlock)block;
- (void) loadMediaFromUser:(User*)user completion:(S3GetBlock)block;
- (void) loadMediaFromUser:(User*)user shouldRefresh:(ShouldRefreshBlock)block;

@end

@interface MediaViewer : UIView
+ (void)showMediaFromView:(UIView*)view filename:(id)filename mediaType:(MediaTypes)mediaType;
@end
