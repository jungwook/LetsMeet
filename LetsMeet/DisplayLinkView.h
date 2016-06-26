//
//  DisplayLinkView.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 26..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisplayLinkView : UIView
@property (nonatomic, strong) NSMutableData *audioData;
@property (nonatomic) BOOL isRecording;
@property (nonatomic) CGFloat progress;
@end

