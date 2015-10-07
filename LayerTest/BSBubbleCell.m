//
//  BSBubbleCell.m
//  BSSimpleLayerChat
//
//  Created by iBlacksus on 10/1/15.
//  Copyright © 2015 iBlacksus. All rights reserved.
//

#import "BSBubbleCell.h"

static CGFloat const kMessageLabelWidthFrame = 48.f;
static CGFloat const kMessageLabelHeightFrame = 34.f;
static CGFloat const kMessageLabelFontSize = 14.f;
static NSString *const kMessageLabelFontName = @"HelveticaNeue";

@interface BSBubbleCell ()

@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageLeadingConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageTrailingConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstant;

@end

@implementation BSBubbleCell

+ (CGFloat)heightForMessage:(NSString *)message
{
    return [BSBubbleCell sizeForMessage:message].height + kMessageLabelHeightFrame;
}

+ (CGFloat)widthForMessage:(NSString *)message
{
    return [BSBubbleCell sizeForMessage:message].width;
}

+ (CGSize)sizeForMessage:(NSString *)message
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width - kMessageLabelWidthFrame;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:kMessageLabelFontName size:kMessageLabelFontSize]};
    
    CGRect rect = [message boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:attributes
                                        context:nil];
    
    return rect.size;
}

- (void)configure
{
    self.bubbleImageView.image = self.bubbleImage;
    self.messageLabel.text = self.message;
    self.messageLabel.textAlignment = (self.sideType == BSBubbleCellSideTypeOutgoing) ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
    CGFloat width = [BSBubbleCell widthForMessage:self.message];
    
    CGFloat widthDifference = CGRectGetWidth(self.frame) - width - self.messageLabelLeadingConstant.constant - self.messageLabelTrailingConstant.constant - 5.f;
    
    if (self.sideType == BSBubbleCellSideTypeOutgoing) {
        self.bubbleImageTrailingConstant.constant = 0.f;
        self.bubbleImageLeadingConstant.constant = widthDifference;
    } else {
        self.bubbleImageTrailingConstant.constant = widthDifference;
        self.bubbleImageLeadingConstant.constant = 0.f;
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.bubbleImageView setNeedsLayout];
            [self.bubbleImageView layoutIfNeeded];
        });
    });
}

@end
