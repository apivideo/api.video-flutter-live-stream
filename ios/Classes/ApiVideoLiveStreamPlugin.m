#import "ApiVideoLiveStreamPlugin.h"
#if __has_include(<apivideo_live_stream/apivideo_live_stream-Swift.h>)
#import <apivideo_live_stream/apivideo_live_stream-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "apivideo_live_stream-Swift.h"
#endif

@implementation ApiVideoLiveStreamPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftApiVideoLiveStreamPlugin registerWithRegistrar:registrar];
}
@end
