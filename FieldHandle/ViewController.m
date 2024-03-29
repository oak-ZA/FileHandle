//
//  ViewController.m
//  FieldHandle
//
//  Created by 张奥 on 2019/10/14.
//  Copyright © 2019 张奥. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<CALayerDelegate>
@property (nonatomic, strong) CATiledLayer *tiledLayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self cutImageAndSave];
    [self addTiledLayer];
}

/**
 *  平铺layer 可用于展示大图
 *  展示大图时可能会引起卡顿(阻塞主线程),将大图切分成小图,然后用到他们(需要展示)的时候再加载(读取)
 */
- (void)addTiledLayer{
    //BingWallpaper-2015-11-22.jpg
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    
    //    UIImage *image = [UIImage imageNamed:@"BingWallpaper-2015-11-22.jpg"];
    
    CATiledLayer *tiledLayer = [CATiledLayer layer];
    //layer->像素 和 点 的概念不同 一个点是[UIScreen mainScreen].scale个像素
    //    CGFloat screenScale = [UIScreen mainScreen].scale;
    //    tiledLayer.contentsScale = screenScale;
    tiledLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);//image.size.width, image.size.height);
    tiledLayer.delegate = self;
    
    _tiledLayer = tiledLayer;
    
    scrollView.contentSize = tiledLayer.frame.size;
    //CGSizeMake(image.size.width / screenScale, image.size.height / screenScale);
    [scrollView.layer addSublayer:tiledLayer];
    [tiledLayer setNeedsDisplay];
}

/** 切图并保存到沙盒中 */
- (void)cutImageAndSave{
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *imageName = [NSString stringWithFormat:@"%@/test-00-00.png",filePath];
    UIImage *tileImage = [UIImage imageWithContentsOfFile:imageName];
    NSLog(@"%@",imageName);
    if (tileImage) return;
    
    UIImage *image = [UIImage imageNamed:@"xiaofeifang_bg@2x.jpg"];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    //    [self.view addSubview:imageView];
    CGFloat WH = 256;
    CGSize size = image.size;
    
    //ceil 向上取整
    NSInteger rows = ceil(size.height / WH);
    NSInteger cols = ceil(size.width / WH);
    
    for (NSInteger y = 0; y < rows; ++y) {
        for (NSInteger x = 0; x < cols; ++x) {
            UIImage *subImage = [self captureView:imageView frame:CGRectMake(x*WH, y*WH, WH, WH)];
            NSString *path = [NSString stringWithFormat:@"%@/test-%02ld-%02ld.png",filePath,x,y];
            [UIImagePNGRepresentation(subImage) writeToFile:path atomically:YES];
        }
    }
}


/** 切图 */
- (UIImage*)captureView:(UIView *)theView frame:(CGRect)fra{
    //开启图形上下文 将heView的所有内容渲染到图形上下文中
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    
    //获取图片
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef ref = CGImageCreateWithImageInRect(img.CGImage, fra);
    UIImage *i = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    
    return i;
}

/**
 *  加载图片
 *  CALayerDelegate
 *  支持多线程绘制，-drawLayer:inContext:方法可以在多个线程中同时地并发调用
 *  所以请小心谨慎地确保你在这个方法中实现的绘制代码是线程安全的.(不懂哎)
 */
- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)ctx{
    
    //获取图形上下文的位置与大小
    CGRect bounds = CGContextGetClipBoundingBox(ctx);
    //floor 向下取整
    NSInteger x = floor(bounds.origin.x / layer.tileSize.width);
    // * [UIScreen mainScreen].scale);
    NSInteger y = floor(bounds.origin.y / layer.tileSize.height);
    // * [UIScreen mainScreen].scale);
    
    //load tile image
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *imageName = [NSString stringWithFormat:@"%@/test-%02ld-%02ld.png",filePath,x,y];
    UIImage *tileImage = [UIImage imageWithContentsOfFile:imageName];
    
    UIGraphicsPushContext(ctx);
    //绘制
    
    [tileImage drawInRect:bounds];
    UIGraphicsPopContext();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
