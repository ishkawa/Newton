#import "INViewController.h"

@implementation INViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:INTERVAL
                                                      target:self
                                                    selector:@selector(animateBallViews)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    return self;
}

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

#pragma mark - action

- (void)showPeerPicker
{
    GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    
    [picker show];
}

- (void)animateBallViews
{
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[INBallView class]]) {
            INBallView *ballView = (INBallView *)subview;
            [ballView move];
        }
    }
}

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
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    
    [picker dismiss];
}

#pragma mark - session delegate

- (void)session:(GKSession *)session
           peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state
{
    if (state == GKPeerStateConnected) {
        self.session = session;
        self.peerID  = peerID;
        
        [[[UIAlertView alloc] initWithTitle:@"connected"
                                    message:nil
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    if (state == GKPeerStateDisconnected) {
        self.session = nil;
        self.peerID  = nil;
        
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
    if (!self.session) {
        ballView.velocity = CGPointMake(ballView.velocity.x, -ballView.velocity.y);
        return;
    }
    
    NSDictionary *dictionary = @{
        @"velocity" : [NSValue valueWithCGPoint:ballView.velocity],
        @"center"   : [NSValue valueWithCGPoint:ballView.center],
    };
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    
    [self sendData:data];
    [ballView removeFromSuperview];
}

@end
