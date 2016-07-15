//
//  SayBarButtonItem.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "SayBarButtonItem.h"
#import "Post.h"

@implementation SayBarButtonItem

- (void)awakeFromNib
{
    __LF
    
    self.action = @selector(doPost:);
}


- (void) doPost:(id)sender
{
    __LF
    
    Post *post = [[[NSBundle mainBundle] loadNibNamed:@"Post" owner:self options:nil] firstObject];

    post.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [[AppDelegate globalDelegate].window.rootViewController presentViewController:post animated:YES completion:nil];
}

@end
