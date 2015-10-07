//
//  BSMessageHelper.m
//  BSSimpleLayerChat
//
//  Created by iBlacksus on 10/7/15.
//  Copyright © 2015 iBlacksus. All rights reserved.
//

#import "BSMessageHelper.h"

static NSString * const kMessageOne = @"Lorem ipsum...";
static NSString * const kMessageTwo = @"Vestibulum dapibus, lacus eget aliquam gravida, ipsum nisi tristique ex, a pretium erat diam efficitur urna. Morbi a hendrerit metus.";
static NSString * const kMessageThree = @"Aenean vulputate commodo tortor non finibus. Vestibulum rutrum blandit massa, vehicula volutpat ligula dapibus vitae. Curabitur posuere, lectus nec vehicula ultrices, nulla felis ultrices nisi, a finibus augue urna id turpis. Etiam tempor facilisis maximus. Nulla et varius libero. Nunc commodo ut massa quis lacinia. Sed porttitor diam elit, in blandit quam placerat sit amet. Maecenas at elit non risus aliquam laoreet. Cras ullamcorper, odio quis consequat porta, nibh libero vestibulum diam, eu ullamcorper eros diam vitae tellus. Curabitur eros felis, iaculis pulvinar ligula ut, vestibulum lobortis nibh. Vestibulum laoreet est turpis, a fermentum ex luctus quis. Mauris at enim at justo eleifend dapibus.";

@implementation BSMessageHelper

+ (NSString *)randomMessage
{
    NSInteger randomInteger = rand() % 3;
    
    switch (randomInteger) {
        case 0: return kMessageOne;
        case 1: return kMessageTwo;
        case 2: return kMessageThree;
        default: return kMessageOne;
    }
}

@end
