#import "MGLLogging.h"

@interface MGLLogging (Private)

- (void)info:(NSString *)fileName message:(id)message, ...;
- (void)debug:(NSString *)fileName message:(id)message, ...;
- (void)error:(NSString *)fileName message:(id)message, ...;
- (void)fault:(NSString *)fileName message:(id)message, ...;

@end
