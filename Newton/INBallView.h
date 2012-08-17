#import <UIKit/UIKit.h>

@protocol INBallViewDelegate;

@interface INBallView : UIView

@property BOOL dragging;
@property CGPoint velocity;
@property NSTimeInterval timestamp;

@property (weak, nonatomic) id <INBallViewDelegate> delegate;

- (void)move;

@end


@protocol INBallViewDelegate <NSObject>

- (void)ballViewDidGoOut:(INBallView *)ballView;

@end
