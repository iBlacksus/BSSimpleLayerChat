//
//  BSBubbleManager.m
//  BSSimpleLayerChat
//
//  Created by iBlacksus on 10/7/15.
//  Copyright © 2015 iBlacksus. All rights reserved.
//

#import "BSBubbleManager.h"

@implementation BSBubbleManager

#pragma mark - Life cycle -

+ (BSBubbleManager *)sharedManager
{
    static BSBubbleManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self new];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createBubbleImages];
    }
    return self;
}

#pragma mark - Public methods -

- (void)createBubbleImages
{
    UIImage *bubbleImage = [UIImage imageNamed:@"bubble"];
    self.incomingBubbleImage = [self applyMaskWithColor:[UIColor colorWithRed:0.8977 green:0.9119 blue:0.9166 alpha:1.0] toImage:bubbleImage];
    self.outgoingBubbleImage = [self applyMaskWithColor:[UIColor colorWithRed:0.3865 green:0.7232 blue:0.8772 alpha:1.0] toImage:bubbleImage];
    // flip incoming image horizontaly
    self.incomingBubbleImage = [UIImage imageWithCGImage:self.incomingBubbleImage.CGImage
                                                   scale:self.incomingBubbleImage.scale
                                             orientation:UIImageOrientationUpMirrored];
    
    self.incomingBubbleImage = [self getStretchableImage:self.incomingBubbleImage];
    self.outgoingBubbleImage = [self getStretchableImage:self.outgoingBubbleImage];
}

- (UIImage *)applyMaskWithColor:(UIColor *)color toImage:(UIImage *)image
{
    CGRect imageRect = CGRectMake(0.f, 0.f, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, image.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1.f, -1.f);
    CGContextTranslateCTM(context, 0.f, -imageRect.size.height);
    CGContextClipToMask(context, imageRect, image.CGImage);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, imageRect);
    
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return maskedImage;
}

- (UIImage *)getStretchableImage:(UIImage *)image
{
    CGPoint center = CGPointMake(image.size.width / 2.f, image.size.height / 2.f);
    UIEdgeInsets insets = UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
    
    return [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
}


@end
