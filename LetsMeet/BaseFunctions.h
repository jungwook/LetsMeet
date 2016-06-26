//
//  BaseFunctions.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 5..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>

#define __LF NSLog(@"%s", __FUNCTION__);

CALayer*    drawImageOnLayer(UIImage *image, CGSize size);
UIImage*    scaleImage(UIImage* image, CGSize size);
void        drawImage(UIImage *image, UIView* view);
void        circleizeView(UIView* view, CGFloat percent);
float       heading(PFGeoPoint* fromLoc, PFGeoPoint* toLoc);
float       Heading(PFUser* from, PFUser* to);
CGRect      hiveToFrame(CGPoint hive, CGFloat radius, CGFloat inset, CGPoint center);
CGRect      rectForString(NSString *string, UIFont *font, CGFloat maxWidth);
NSData*     compressedImageData(NSData* data, CGFloat width);
MediaTypes  mediaTypeFromProfileMediaTypes(ProfileMediaTypes type);
NSString*   randomObjectId();
NSString*   distanceString(double distance);
CGFloat     ampAtIndex(NSUInteger index, NSData* data);