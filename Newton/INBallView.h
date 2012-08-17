#import <UIKit/UIKit.h>

@interface INBallView : UIView

@property BOOL dragging;
@property CGPoint velocity;
@property NSTimeInterval timestamp;

@property (strong, nonatomic) NSTimer *timer;

@end
