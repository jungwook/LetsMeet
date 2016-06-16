//
//  MediaViewer.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 15..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMediaView : UIView
@end

@interface MediaViewer : UIView
+ (void)showMediaFromView:(UIView*)view filename:(id)filename isPhoto:(BOOL)isPhoto;
@end
