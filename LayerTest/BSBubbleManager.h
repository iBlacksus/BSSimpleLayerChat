//
//  BSBubbleManager.h
//  BSSimpleLayerChat
//
//  Created by iBlacksus on 10/7/15.
//  Copyright © 2015 iBlacksus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSBubbleManager : NSObject

@property (nonatomic) UIImage *incomingBubbleImage;
@property (nonatomic) UIImage *outgoingBubbleImage;

+ (BSBubbleManager *)sharedManager;

@end
