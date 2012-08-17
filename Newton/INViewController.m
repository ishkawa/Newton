#import "INViewController.h"

@implementation INViewController

- (void)loadView
{
    [super loadView];
    
    INBallView *ballView = [[INBallView alloc] init];
    ballView.frame = CGRectMake(0, 0, 100, 100);
    ballView.delegate = self;
    [self.view addSubview:ballView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showPeerPicker];
}

- (void)showPeerPicker
{
    GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    
    [picker show];
}

#pragma mark - action

- (void)sendData:(NSData *)data
{
    [self.session sendData:data
                   toPeers:@[ self.peerID ]
              withDataMode:GKSendDataReliable
                     error:nil];
}

#pragma mark - data receive handler

- (void)receiveData:(NSData *)data
           fromPeer:(NSString *)peer
          inSession:(GKSession *)session
            context:(void *)context
{
    NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    CGPoint velocity = [[dictionary objectForKey:@"velocity"] CGPointValue];
    CGPoint center = [[dictionary objectForKey:@"center"] CGPointValue];
    
    INBallView *ballView = [[INBallView alloc] init];
    ballView.frame    = CGRectMake(0, 0, 100, 100);
    ballView.center   = CGPointMake(self.view.frame.size.width - center.x, center.y);
    ballView.velocity = CGPointMake(-velocity.x, -velocity.y);
    ballView.delegate = self;
    
    [self.view addSubview:ballView];
}

#pragma mark - peer picker delegate

- (void)peerPickerController:(GKPeerPickerController *)picker
              didConnectPeer:(NSString *)peerID
                   toSession:(GKSession *)session
{
    self.peerID = peerID;
    self.session = session;
    self.session.delegate = self;
    
    [session setDataReceiveHandler:self withContext:nil];
    [picker dismiss];
}

#pragma mark - session delegate

- (void)session:(GKSession *)session
           peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state
{
    // TODO: toggle balls user interaction
    if (state == GKPeerStateConnected) {
        [[[UIAlertView alloc] initWithTitle:@"connected"
                                    message:nil
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    if (state == GKPeerStateDisconnected) {
        [[[UIAlertView alloc] initWithTitle:@"disconnected"
                                    message:nil
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - ball view delegate

- (void)ballViewDidGoOut:(INBallView *)ballView
{
    NSDictionary *dictionary = @{
        @"velocity" : [NSValue valueWithCGPoint:ballView.velocity],
        @"center"   : [NSValue valueWithCGPoint:ballView.center],
    };
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    
    [self sendData:data];
    [ballView removeFromSuperview];
}

@end
