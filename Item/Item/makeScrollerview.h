//
//  makeScrollerview.h
//  assemble
//
//  Created by qf on 15/8/22.
//  Copyright © 2015年 qf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface makeScrollerview : NSObject<UIScrollViewDelegate>

-(instancetype)initWithScrollerViewFrame:(CGRect)ScrollerFrame withPageControlFrame:(CGRect )PageFrame withParentView:(UIImageView *)ImageView withPhotoArray:(NSArray *)photoArray;

-(void)CreatScrollerView;


@end
