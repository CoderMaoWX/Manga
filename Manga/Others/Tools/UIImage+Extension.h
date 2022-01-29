//
//  UIImage+Extension.h
//  iManga
//
//  Created by 610582 on 2022/1/29.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

/**
 Create an animated image with GIF data. After created, you can access
 the images via property '.images'. If the data is not animated gif, this
 function is same as [UIImage imageWithData:data scale:scale];
 
 @discussion     It has a better display performance, but costs more memory
                 (width * height * frames Bytes). It only suited to display small
                 gif such as animated emoticon. If you want to display large gif,
                 see `YYImage`.
 
 @param data     GIF data.
 
 @param scale    The scale factor
 
 @return A new image created from GIF, or nil when an error occurs.
 */
+ (nullable UIImage *)yy_imageWithSmallGIFData:(NSData *_Nullable)data scale:(CGFloat)scale;

@end
