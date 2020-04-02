#import "FlutterslideuppanelPlugin.h"
#if __has_include(<flutterslideuppanel/flutterslideuppanel-Swift.h>)
#import <flutterslideuppanel/flutterslideuppanel-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutterslideuppanel-Swift.h"
#endif

@implementation FlutterslideuppanelPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterslideuppanelPlugin registerWithRegistrar:registrar];
}
@end
