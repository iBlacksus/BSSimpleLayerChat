//
//  LayerManager.h
//  BSSimpleLayerChat
//
//  Created by iBlacksus on 10/6/15.
//  Copyright © 2015 iBlacksus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

static NSString *const layerAppID = @"";

typedef void (^BSLayerManagerCompletionHandler)(NSError *error);

@interface BSLayerManager : NSObject <LYRClientDelegate>

@property (nonatomic, readonly) NSArray *users;
@property (nonatomic, readonly) NSString *userID;
@property (nonatomic, readonly) LYRClient *layerClient;

+ (BSLayerManager *)sharedManager;

- (void)connectWithCompletion:(BSLayerManagerCompletionHandler)completion;
- (void)authWithUserID:(NSString *)userID completion:(BSLayerManagerCompletionHandler)completion;
- (LYRQueryController *)getQueryController:(LYRConversation *)conversation;

@end
