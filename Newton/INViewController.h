#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface INViewController : UIViewController <GKPeerPickerControllerDelegate, GKSessionDelegate>

@property (strong, nonatomic) GKSession *session;
@property (strong, nonatomic) NSString  *peerID;

@end
