#import "INViewController.h"
#import "INBallView.h"

@implementation INViewController

- (void)loadView
{
    [super loadView];
    
    for (NSInteger i=0; i<10; i++) {
        INBallView *ballView = [[INBallView alloc] init];
        ballView.frame = CGRectMake(0, 0, 100, 100);
        [self.view addSubview:ballView];
    }
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

- (void)send
{
    NSLog(@"sent");
    [self.session sendData:[@"hogehoge" dataUsingEncoding:NSUTF8StringEncoding]
                   toPeers:@[self.peerID]
              withDataMode:GKSendDataReliable
                     error:nil];
}

#pragma mark - data receive handler

- (void)receiveData:(NSData *)data
           fromPeer:(NSString *)peer
          inSession:(GKSession *)session
            context:(void *)context
{
    NSLog(@"received");
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
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self send];
    });
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

@end
