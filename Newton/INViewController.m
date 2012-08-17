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

@end
