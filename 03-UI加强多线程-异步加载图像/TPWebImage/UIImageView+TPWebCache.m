//
//  UIImageView+TPWebCache.m
//  03-UI加强多线程-异步加载图像
//
//  Created by 小贝 on 16/5/30.
//  Copyright © 2016年 小贝. All rights reserved.
//

#import "UIImageView+TPWebCache.h"
#import "TPWebImageManager.h"

@implementation UIImageView (TPWebCache)

- (void)tp_setImageWithURLString:(NSString *)urlString {

    [[TPWebImageManager shareManager] downloadImageWithURLString:urlString completion:^(UIImage * image) {
        self.image = image;
    }];
}
@end
