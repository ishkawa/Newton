#import <UIKit/UIKit.h>

@protocol INBallViewDelegate;

@interface INBallView : UIView

@property BOOL dragging;
@property CGPoint velocity;
@property NSTimeInterval timestamp;

@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) id <INBallViewDelegate> delegate;

@end


@protocol INBallViewDelegate <NSObject>

- (void)ballViewDidGoOut:(INBallView *)ballView;

@end
