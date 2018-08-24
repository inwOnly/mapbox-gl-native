#import "MGLLogging_Private.h"

#import <os/log.h>

static os_log_t mapbox_log;

@implementation MGLLogging

+ (void)initialize
{
    mapbox_log = os_log_create("com.mapbox.maps-ios-sdk", "SDK");
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _loggingLevel = MGLLoggingLevelNone;
        self.handler = nil;
    }
    
    return self;
}

- (void)setHandler:(void (^)(MGLLoggingLevel, NSString *, NSString *))handler {
    
    if (!handler) {
        _handler = [self mapboxBlockHandler];
    } else {
        _handler = handler;
    }
}

- (void)info:(NSString *)fileName message:(id)message, ...
{
    va_list parameterValues;
    va_start(parameterValues, message);
    NSString *formattedMessage = [[NSString alloc] initWithFormat:message arguments:parameterValues];
    va_end(parameterValues);
    [self log:MGLLoggingLevelInfo fileName:fileName message:formattedMessage];
}

- (void)debug:(NSString *)fileName message:(id)message, ...
{
    va_list parameterValues;
    va_start(parameterValues, message);
    NSString *formattedMessage = [[NSString alloc] initWithFormat:message arguments:parameterValues];
    va_end(parameterValues);
    [self log:MGLLoggingLevelDebug fileName:fileName message:formattedMessage];
}

- (void)error:(NSString *)fileName message:(id)message, ...
{
    va_list parameterValues;
    va_start(parameterValues, message);
    NSString *formattedMessage = [[NSString alloc] initWithFormat:message arguments:parameterValues];
    va_end(parameterValues);
    [self log:MGLLoggingLevelError fileName:fileName message:formattedMessage];
}

- (void)fault:(NSString *)fileName message:(id)message, ...
{
    va_list parameterValues;
    va_start(parameterValues, message);
    NSString *formattedMessage = [[NSString alloc] initWithFormat:message arguments:parameterValues];
    va_end(parameterValues);
    [self log:MGLLoggingLevelFault fileName:fileName message:formattedMessage];
}

- (void)log:(MGLLoggingLevel)level fileName:(NSString *)fileName message:(NSString *)formattedMessage
{
    if (self.loggingLevel != MGLLoggingLevelNone && self.handler) {
        self.handler(level, fileName, formattedMessage);
    }
}

- (BlockHandler)mapboxBlockHandler {
    __weak __typeof__(self) weakSelf = self;
    BlockHandler mapboxHandler = ^(MGLLoggingLevel level, NSString *fileName, NSString *message) {
        if (weakSelf.loggingLevel != MGLLoggingLevelNone && level <= weakSelf.loggingLevel) {
            os_log_type_t logType = [weakSelf logTypeFromMGLLoggingLevel:level];
            NSString *formattedMessage = [NSString stringWithFormat:@"%@ %@", fileName, message];
            const char *msg = [formattedMessage UTF8String];
            os_log_with_type(mapbox_log, logType, "%{public}s", msg);
        }
    };
    
    return mapboxHandler;
}

- (os_log_type_t)logTypeFromMGLLoggingLevel:(MGLLoggingLevel)loggingLevel
{
    os_log_type_t logType;
    switch (loggingLevel) {
        case MGLLoggingLevelInfo:
            logType = OS_LOG_TYPE_INFO;
            break;
        case MGLLoggingLevelDebug:
            logType = OS_LOG_TYPE_DEBUG;
            break;
        case MGLLoggingLevelError:
            logType = OS_LOG_TYPE_ERROR;
            break;
        case MGLLoggingLevelFault:
            logType = OS_LOG_TYPE_FAULT;
            break;
        default:
            logType = OS_LOG_TYPE_DEFAULT;
            break;
    }
    return logType;
}

@end
