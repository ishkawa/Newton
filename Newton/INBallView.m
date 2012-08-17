#import "INBallView.h"
#import <QuartzCore/QuartzCore.h>

#define INTERVAL 0.01
#define ATTENUATION_RATE 10.f

@implementation INBallView

- (id)init
{
    self = [super init];
    if (self) {
        self.dragging = NO;
        self.velocity = CGPointMake(0.f, 0.f);
        self.timestamp = [[NSProcessInfo processInfo] systemUptime];
        self.backgroundColor = [UIColor darkGrayColor];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:INTERVAL
                                                      target:self
                                                    selector:@selector(move)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    return self;
}

- (void)move
{
    if (self.dragging) {
        return;
    }
    self.center = CGPointMake(self.center.x + self.velocity.x*INTERVAL,
                              self.center.y + self.velocity.y*INTERVAL);

    // bound
    if (self.center.x < 0 || self.center.x > self.superview.frame.size.width) {
        self.velocity = CGPointMake(-self.velocity.x, self.velocity.y);
    }
    if (self.center.y < 0) {
        self.velocity = CGPointMake(self.velocity.x, -self.velocity.y);
    }
    if (self.center.y > self.superview.frame.size.height) {
        [self.timer invalidate];
        self.timer = nil;
        
        [self.delegate ballViewDidGoOut:self];
    }
    
    // attenuation
    CGFloat xVelocity = 0.f;
    CGFloat yVelocity = 0.f;
    
    if (fabs(self.velocity.x) > ATTENUATION_RATE ) {
        CGFloat sign = self.velocity.x < 0.f ? 1.f : -1.f;
        CGFloat ratio = fabs(self.velocity.x) / (fabs(self.velocity.x) + fabs(self.velocity.y));
        xVelocity = self.velocity.x + sign * ratio * ATTENUATION_RATE;
    }
    if (fabs(self.velocity.y) > ATTENUATION_RATE ) {
        CGFloat sign = self.velocity.y < 0.f ? 1.f : -1.f;
        CGFloat ratio = fabs(self.velocity.y) / (fabs(self.velocity.x) + fabs(self.velocity.y));
        yVelocity = self.velocity.y + sign * ratio * ATTENUATION_RATE;
    }
    self.velocity = CGPointMake(xVelocity, yVelocity);
}

- (void)updateWithTouches:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint point  = [touch locationInView:self.superview];
    
    CGFloat dt = touch.timestamp - self.timestamp;
    CGFloat dx = point.x - self.center.x;
    CGFloat dy = point.y - self.center.y;
    
    self.velocity  = CGPointMake(dx/dt, dy/dt);
    self.center    = point;
    self.timestamp = touch.timestamp;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.dragging = YES;
    [self updateWithTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateWithTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.dragging = NO;
}

@end
