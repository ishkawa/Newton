#import "UIColor+Code.h"

@implementation UIColor (Code)

+ (UIColor *)colorWithCode:(NSString *)code
{
    code = [code stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    NSString *redString   = [code substringWithRange:NSMakeRange(0, 2)];
    NSString *greenString = [code substringWithRange:NSMakeRange(2, 2)];
    NSString *blueString  = [code substringWithRange:NSMakeRange(4, 2)];
    
    NSUInteger redValue;
    NSUInteger greenValue;
    NSUInteger blueValue;
    
    [[NSScanner scannerWithString:redString] scanHexInt:&redValue];
    [[NSScanner scannerWithString:greenString] scanHexInt:&greenValue];
    [[NSScanner scannerWithString:blueString] scanHexInt:&blueValue];
    
    return [UIColor colorWithRed:(CGFloat)redValue/255.f
                           green:(CGFloat)greenValue/255.f
                            blue:(CGFloat)blueValue/255.f
                           alpha:1.f];
}

+ (UIColor *)colorWithIndex:(NSInteger)index
{
    static NSArray *colorCodes = nil;
    if (colorCodes == nil) {
        colorCodes = @[ @"fff799", @"6dcff6", @"f49ac1"];
    }
    NSString *code = [colorCodes objectAtIndex:index%colorCodes.count];
    
    return [UIColor colorWithCode:code];
}

@end
