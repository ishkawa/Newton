#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "INBallView.h"

@interface INViewController : UIViewController

<GKPeerPickerControllerDelegate, GKSessionDelegate, INBallViewDelegate>

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) GKSession *session;
@property (strong, nonatomic) NSString *peerID;

@end
