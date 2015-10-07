//
//  ViewController.m
//  BSSimpleLayerChat
//
//  Created by iBlacksus on 10/6/15.
//  Copyright © 2015 iBlacksus. All rights reserved.
//

#import "BSViewController.h"
#import "BSLayerManager.h"
#import "BSBubbleCell.h"
#import "BSBubbleManager.h"
#import "BSMessageHelper.h"

@interface BSViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (nonatomic) LYRConversation *conversation;
@property (nonatomic, retain) LYRQueryController *queryController;

- (IBAction)add:(id)sender;

@end

@implementation BSViewController

#pragma mark - Accessors -

#pragma mark - Life cycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Loading...";
    
    if (!layerAppID.length) {
        [self showError:[NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Set your Layer App ID in BSLayerManager!"}]];
        return;
    }
    
    [[BSLayerManager sharedManager] connectWithCompletion:^(NSError *error) {
        if (error) {
            [self showError:error];
            return;
        }
        
        [self setupLayerNotificationObservers];
        [self askUserID];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.queryController) {
        return 0;
    }
    
    return [self.queryController numberOfObjectsInSection:0];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self.queryController objectAtIndexPath:indexPath];
    LYRMessagePart *messagePart = message.parts.firstObject;
    
    return [BSBubbleCell heightForMessage:[[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self.queryController objectAtIndexPath:indexPath];
    LYRMessagePart *messagePart = message.parts.firstObject;
    BOOL isCurrentUserMessage = [message.sender.userID isEqualToString:[BSLayerManager sharedManager].userID];
    
    NSString *identifier = NSStringFromClass([BSBubbleCell class]);
    BSBubbleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.bubbleImage = (isCurrentUserMessage) ? [BSBubbleManager sharedManager].outgoingBubbleImage : [BSBubbleManager sharedManager].incomingBubbleImage;
    cell.message = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    cell.sideType = (isCurrentUserMessage) ? BSBubbleCellSideTypeOutgoing : BSBubbleCellSideTypeIncoming;
    
    [cell configure];
    
    return cell;
}

#pragma mark - LYRQueryControllerDelegate -

- (void)queryControllerWillChangeContent:(LYRQueryController *)queryController
{
    [self.tableView beginUpdates];
}

- (void)queryController:(LYRQueryController *)controller
        didChangeObject:(id)object
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(LYRQueryControllerChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case LYRQueryControllerChangeTypeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case LYRQueryControllerChangeTypeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case LYRQueryControllerChangeTypeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case LYRQueryControllerChangeTypeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
    
}

- (void)queryControllerDidChangeContent:(LYRQueryController *)queryController
{
    [self.tableView endUpdates];
    [self scrollToBottom];
    
}

#pragma mark - Layer Notifications -

- (void)didReceiveLayerClientWillBeginSynchronizationNotification:(NSNotification *)notification
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didReceiveLayerClientDidFinishSynchronizationNotification:(NSNotification *)notification
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
{
    [self fetchLayerConversation];
}

#pragma mark - Actions -

- (IBAction)add:(id)sender
{
    NSString *messageText = [BSMessageHelper randomMessage];
    
    if (!self.conversation) {
        [self fetchLayerConversation];
    }
    
    LYRMessagePart *messagePart = [LYRMessagePart messagePartWithText:messageText];
    
    NSString *pushMessage= [NSString stringWithFormat:@"%@ says %@",[BSLayerManager sharedManager].layerClient.authenticatedUserID ,messageText];
    LYRMessage *message = [[BSLayerManager sharedManager].layerClient newMessageWithParts:@[messagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: pushMessage} error:nil];
    
    NSError *error;
    if (![self.conversation sendMessage:message error:&error]){
        [self showError:error];
        NSLog(@"Message send failed: %@", error);
        return;
    }
    
    if (!self.queryController) {
        [self setupQueryController];
    }
}

#pragma mark - General methods -

- (NSUInteger)numberOfMessages
{
    LYRQuery *message = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    
    NSError *error;
    NSOrderedSet *messageList = [[BSLayerManager sharedManager].layerClient executeQuery:message error:&error];
    
    return messageList.count;
}

- (void)scrollToBottom
{
    NSUInteger messages = [self numberOfMessages];
    
    if (self.conversation && messages > 1) {
        NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
        if (!numberOfRows) {
            return;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRows-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    }
}

- (void)setupLayerNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLayerObjectsDidChangeNotification:)
                                                 name:LYRClientObjectsDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLayerClientWillBeginSynchronizationNotification:)
                                                 name:LYRClientWillBeginSynchronizationNotification
                                               object:[BSLayerManager sharedManager].layerClient];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLayerClientDidFinishSynchronizationNotification:)
                                                 name:LYRClientDidFinishSynchronizationNotification
                                               object:[BSLayerManager sharedManager].layerClient];
}

- (BOOL)createConversation
{
    NSError *error;
    self.conversation = [[BSLayerManager sharedManager].layerClient newConversationWithParticipants:[NSSet setWithArray:[BSLayerManager sharedManager].users] options:nil error:&error];
    if (!self.conversation) {
        [self showError:error];
        NSLog(@"New Conversation creation failed: %@", error);
        return NO;
    }
    
    return YES;
}

- (void)fetchLayerConversation
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"participants" predicateOperator:LYRPredicateOperatorIsEqualTo value:[BSLayerManager sharedManager].users];
    query.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO] ];
    
    NSError *error;
    NSOrderedSet *conversations = [[BSLayerManager sharedManager].layerClient executeQuery:query error:&error];
    if (error) {
        [self showError:error];
        NSLog(@"Query failed with error %@", error);
        return;
    }
    
    self.conversation = conversations.lastObject;
    if (!conversations.count) {
        if (![self createConversation]) {
            return;
        }
    }
    
    if (!self.queryController) {
        [self setupQueryController];
    }
}

- (void)setupQueryController
{
    self.queryController = [[BSLayerManager sharedManager] getQueryController:self.conversation];
    self.queryController.delegate = self;
    
    [self.tableView reloadData];
    [self.conversation markAllMessagesAsRead:nil];
    [self scrollToBottom];
}

- (void)showError:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)askUserID
{
    if ([BSLayerManager sharedManager].layerClient.authenticatedUserID) {
        [self userAuthenticated];
        [self fetchLayerConversation];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Choose user ID" preferredStyle:UIAlertControllerStyleAlert];
    for (NSString *userID in [BSLayerManager sharedManager].users) {
        [alert addAction:[UIAlertAction actionWithTitle:userID style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self authWithUserID:userID];
        }]];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)authWithUserID:(NSString *)userID
{
    [[BSLayerManager sharedManager] authWithUserID:userID completion:^(NSError *error) {
        if (error) {
            [self showError:error];
            return;
        }
        
        [self userAuthenticated];
        [self fetchLayerConversation];
    }];
}

- (void)userAuthenticated
{
    self.title = [BSLayerManager sharedManager].layerClient.authenticatedUserID;
    self.addButton.enabled = YES;
}

#pragma mark - Segues -

@end
