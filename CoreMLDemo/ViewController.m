//
//  ViewController.m
//  CoreMLDemo
//
//  Created by zhangjialin on 2017/6/13.
//  Copyright © 2017年 zhangjialin. All rights reserved.
//

#import "ViewController.h"
#import "GoogLeNetPlaces.h"

@interface ViewController ()

@property (nonatomic, strong) GoogLeNetPlaces *model;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 初始化模型对象
    self.model = [[GoogLeNetPlaces alloc] init];
    // 初始化需要输入的图片信息
    UIImage *image = [UIImage imageNamed:@"test"];
    CGImageRef cgImage = image.CGImage;
    // 得到输出
    GoogLeNetPlacesOutput *outPut = [self.model predictionFromSceneImage:[self pixelBufferFromCGImage:cgImage] error:nil];
    // 打印输出结果
    NSLog(@"Dict:%@, \n label:%@", outPut.sceneLabelProbs, outPut.sceneLabel);
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameWidth, frameHeight, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameWidth, frameHeight, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0, frameWidth, frameHeight), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

@end
