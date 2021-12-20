#import "ApivideolivestreamPlugin.h"
#if __has_include(<apivideolivestream/apivideolivestream-Swift.h>)
#import <apivideolivestream/apivideolivestream-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "apivideolivestream-Swift.h"
#endif

@implementation ApivideolivestreamPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftApivideolivestreamPlugin registerWithRegistrar:registrar];
}
@end
