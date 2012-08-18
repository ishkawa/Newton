#import "INBallView.h"
#import <QuartzCore/QuartzCore.h>

@implementation INBallView

- (id)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.dragging = NO;
        self.velocity = CGPointMake(0.f, 0.f);
        self.timestamp = [[NSProcessInfo processInfo] systemUptime];
        self.frame = CGRectMake(0, 0, 75, 75);
        
        [self startObservingColorKey];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"color"];
}

#pragma mark - coding

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self startObservingColorKey];
        self.frame = CGRectMake(0, 0, 75, 75);
        self.velocity = [[coder decodeObjectForKey:@"velocity"] CGPointValue];
        self.center   = [[coder decodeObjectForKey:@"center"] CGPointValue];
        self.color    = [coder decodeObjectForKey:@"color"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[NSValue valueWithCGPoint:self.velocity] forKey:@"velocity"];
    [coder encodeObject:[NSValue valueWithCGPoint:self.center] forKey:@"center"];
    [coder encodeObject:self.color forKey:@"color"];
}

#pragma mark - key value observation

- (void)startObservingColorKey
{
    [self addObserver:self
           forKeyPath:@"color"
              options:NSKeyValueObservingOptionNew
              context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"color"]) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, self.frame.size.width*2.f, self.frame.size.height*2.f);
        layer.backgroundColor = self.color.CGColor;
        layer.masksToBounds = YES;
        layer.cornerRadius = self.frame.size.width;
        
        UIGraphicsBeginImageContext(layer.frame.size);
        [layer renderInContext:UIGraphicsGetCurrentContext()];
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - action

- (void)move
{
    if (self.dragging) {
        return;
    }
    [UIView animateWithDuration:INTERVAL
                          delay:0.f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.center = CGPointMake(self.center.x + self.velocity.x*INTERVAL,
                                                   self.center.y + self.velocity.y*INTERVAL);
                     }
                     completion:nil];

    // bound
    if (self.center.x < 0 || self.center.x > self.superview.frame.size.width) {
        self.velocity = CGPointMake(-self.velocity.x, self.velocity.y);
    }
    if (self.center.y < 0) {
        self.velocity = CGPointMake(self.velocity.x, -self.velocity.y);
    }
    
    // move to pair screen
    if (self.center.y > self.superview.frame.size.height) {
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

#pragma mark - touch event handling

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

@end
