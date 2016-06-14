//
//  BaseFunctions.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 5..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "BaseFunctions.h"
#import "NSMutableDictionary+Bullet.h"

CALayer* drawImageOnLayer(UIImage *image, CGSize size)
{
    CALayer *layer = [CALayer layer];
    [layer setBounds:CGRectMake(0, 0, size.width, size.height)];
    [layer setContents:(id)image.CGImage];
    [layer setContentsGravity:kCAGravityResizeAspect];
    [layer setMasksToBounds:YES];
    return layer;
}

UIImage* scaleImage(UIImage* image, CGSize size) {
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
    [drawImageOnLayer(image,size) renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return smallImage;
}

void drawImage(UIImage *image, UIView* view)
{
    [view.layer setContents:(id)image.CGImage];
    [view.layer setContentsGravity:kCAGravityResizeAspectFill];
    [view.layer setMasksToBounds:YES];
}

void circleizeView(UIView* view, CGFloat percent)
{
    view.layer.cornerRadius = view.frame.size.height * percent;
    view.layer.masksToBounds = YES;
}

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

float heading(PFGeoPoint* fromLoc, PFGeoPoint* toLoc)
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}

float Heading(User* from, User* to)
{
    PFGeoPoint *fromLoc = from.location;
    PFGeoPoint *toLoc = to.location;
    if (from != to && (fromLoc.latitude == toLoc.latitude && fromLoc.longitude == toLoc.longitude)) {
        printf("SAME LOCATION FOR:%s - %s\n", [from.nickname UTF8String], [to.nickname UTF8String]);
    }
    return heading(fromLoc, toLoc);
}

CGRect hiveToFrame(CGPoint hive, CGFloat radius, CGFloat inset, CGPoint center)
{
    const int offx[] = { 1, -1, -2, -1, 1, 2};
    const int offy[] = { 1, 1, 0, -1, -1, 0};
    
    int level = hive.x;
    int quad = hive.y;
    
    int sx = level, sy = -level;
    
    for (int i=0; i<quad; i++) {
        int side = (int) i / (level);
        int ox = offx[side];
        int oy = offy[side];
        
        sx += ox;
        sy += oy;
    }
    
    const CGFloat f = 2-inset/radius;
    const CGFloat f2 = f*1.154;
    
    CGFloat x = center.x+(sx-0.5f)*radius;
    CGFloat y = center.y+(sy-0.5f)*radius*1.5*1.154;
    
    return CGRectMake(x, y, f*radius, f2*radius);
}

NSData* compressedImageData(NSData* data, CGFloat width)
{
    UIImage *image = [UIImage imageWithData:data];
    const CGFloat thumbnailWidth = width;
    CGFloat thumbnailHeight = image.size.width ? thumbnailWidth * image.size.height / image.size.width : 200;
    image = scaleImage(image, CGSizeMake(thumbnailWidth, thumbnailHeight));
    return UIImageJPEGRepresentation(image, kJPEGCompressionMedium);
}

CGRect rectForString(NSString *string, UIFont *font, CGFloat maxWidth)
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    CGRect rect = CGRectIntegral([string boundingRectWithSize:CGSizeMake(maxWidth, 0)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{
                                                                NSFontAttributeName: font,
                                                                } context:nil]);
    
    return rect;
}
