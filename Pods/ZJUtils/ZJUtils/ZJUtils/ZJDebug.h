//
//  ZJDebug.h
//
//  Modified from Three20 Debugging tools by lian jie on 5/31/10.

/**
 * Modified from Three20 Debugging tools.
 *
 * Provided in this header are a set of debugging tools. This is meant quite literally, in that
 * all of the macros below will only function when the DEBUG preprocessor macro is specified.
 *
 * TTDASSERT(<statement>);
 * If <statement> is false, the statement will be wrZJen to the log and if you are running in
 * the simulator with a debugger attached, the app will break on the assertion line.
 *
 * TTDPRINT(@"formatted log text %d", param1);
 * Print the given formatted text to the log.
 *
 * TTDPRINTMETHODNAME();
 * Print the current method to the log.
 *
 * TTDCONDITIONLOG(<statement>, @"formatted log text %d", param1);
 * Only if <statement> is true then the formatted text will be wrZJen to the log.
 *
 * TTDINFO/TTDWARNING/TTDERROR(@"formatted log text %d", param1);
 * Will only write the formatted text to the log if TTMAXLOGLEVEL is greater than the respective
 * TTD* method's log level. See below for log levels.
 *
 * The default maximum log level is TTLOGLEVEL_WARNING.
 */
#define ZJDEBUG
#define ZJLOGLEVEL_INFO     10
#define ZJLOGLEVEL_WARNING  3
#define ZJLOGLEVEL_ERROR    1

#ifndef ZJMAXLOGLEVEL

#ifdef DEBUG
    #define ZJMAXLOGLEVEL ZJLOGLEVEL_INFO
#else
    #define ZJMAXLOGLEVEL ZJLOGLEVEL_ERROR
#endif

#endif

// The general purpose logger. This ignores logging levels.
#ifdef ZJDEBUG
  #define ZJDPRINT(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
  #define ZJDPRINT(xx, ...)  ((void)0)
#endif

// Prints the current method's name.
#define ZJDPRINTMETHODNAME() ZJDPRINT(@"%s", __PRETTY_FUNCTION__)

// Log-level based logging macros.
#if ZJLOGLEVEL_ERROR <= ZJMAXLOGLEVEL
  #define ZJDERROR(xx, ...)  ZJDPRINT(xx, ##__VA_ARGS__)
#else
  #define ZJDERROR(xx, ...)  ((void)0)
#endif

#if ZJLOGLEVEL_WARNING <= ZJMAXLOGLEVEL
  #define ZJDWARNING(xx, ...)  ZJDPRINT(xx, ##__VA_ARGS__)
#else
  #define ZJDWARNING(xx, ...)  ((void)0)
#endif

#if ZJLOGLEVEL_INFO <= ZJMAXLOGLEVEL
  #define ZJDINFO(xx, ...)  ZJDPRINT(xx, ##__VA_ARGS__)
#else
  #define ZJDINFO(xx, ...)  ((void)0)
#endif

#ifdef ZJDEBUG
  #define ZJDCONDITIONLOG(condition, xx, ...) { if ((condition)) { \
                                                  ZJDPRINT(xx, ##__VA_ARGS__); \
                                                } \
                                              } ((void)0)
#else
  #define ZJDCONDITIONLOG(condition, xx, ...) ((void)0)
#endif


#define ZJAssert(condition, ...)                                       \
do {                                                                      \
    if (!(condition)) {                                                     \
        [[NSAssertionHandler currentHandler]                                  \
            handleFailureInFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__] \
                                file:[NSString stringWithUTF8String:__FILE__]  \
                            lineNumber:__LINE__                                  \
                            description:__VA_ARGS__];                             \
    }                                                                       \
} while(0)
