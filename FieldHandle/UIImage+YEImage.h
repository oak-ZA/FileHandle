//
//  UIImage+YEImage.h
//  FieldHandle
//
//  Created by 张奥 on 2019/10/14.
//  Copyright © 2019 张奥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (YEImage)

//+(UIImage*)imageWithName:(NSString *)name;
//+(UIImage *)imageWithFilePath:(NSString *)path;
+(UIImage*)changTheNewSize:(CGSize)newSize WithImage:(UIImage*)image;
//+(NSData*)reduceTheMemoryWithImage:(UIImage*)image;
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;
+(NSData*)reduceTheMemoryWithImage:(UIImage*)image andSize:(CGSize)size;
+(UIImage *)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*)image;
/**截取View作为图片**/
+ (UIImage *)snapshot:(UIView *)view;
-(UIImage*)getSubImage:(CGRect)rect;
-(UIImage*)scaleToSize:(CGSize)size;

@end
