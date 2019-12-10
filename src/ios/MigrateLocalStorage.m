#import "MigrateLocalStorage.h"

@implementation MigrateLocalStorage

- (BOOL) copyFrom:(NSString*)src to:(NSString*)dest
{
    NSFileManager* fileManager = [NSFileManager defaultManager];

    // Bail out if source file does not exist
    if (![fileManager fileExistsAtPath:src]) {
        return NO;
    }

    // Bail out if dest file exists
    if ([fileManager fileExistsAtPath:dest]) {
        return NO;
    }

    // create path to dest
    if (![fileManager createDirectoryAtPath:[dest stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil]) {
        return NO;
    }

    // copy src to dest
    return [fileManager copyItemAtPath:src toPath:dest error:nil];
}

- (void) migrateLocalStorageWkToUi
{
    // Migrate WKWebView local storage files to UIWebView. Adapted from
    // https://github.com/Telerik-Verified-Plugins/WKWebView/blob/master/src/ios/MyMainViewController.m

    NSString* appLibraryFolder = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* target; // UIWebView LocalStorage Path

    target = [appLibraryFolder stringByAppendingPathComponent:@"WebKit/LocalStorage/file__0.localstorage"];

    // WKWebView LocalStorage Path
    NSString* original = [[NSString alloc] initWithString: [appLibraryFolder stringByAppendingPathComponent:@"WebKit"]];

#if TARGET_IPHONE_SIMULATOR
    // the simulutor squeezes the bundle id into the path
    NSString* bundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    original = [original stringByAppendingPathComponent:bundleIdentifier];
#endif

    original = [original stringByAppendingPathComponent:@"WebsiteData/LocalStorage/file__0.localstorage"];

    // Only copy data if no existing localstorage data exists yet for UIWebView
    if (![[NSFileManager defaultManager] fileExistsAtPath:target]) {
        NSLog(@"No existing localstorage data found for UIWebView. Migrating data from WKWebView");
        [self copyFrom:original to:target];
        [self copyFrom:[original stringByAppendingString:@"-shm"] to:[target stringByAppendingString:@"-shm"]];
        [self copyFrom:[original stringByAppendingString:@"-wal"] to:[target stringByAppendingString:@"-wal"]];
    }
    else {
        NSLog(@"Existing localstorage data found for UIWebView");
    }
    // Remove WKWebView localstorage data
    [[NSFileManager defaultManager] removeItemAtPath:original error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[original stringByAppendingString:@"-shm"] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[original stringByAppendingString:@"-wal"] error:nil];
}

- (void) migrateLocalStorageUiToWk
{
    // Migrate UIWebView local storage files to WKWebView. Adapted from
    // https://github.com/Telerik-Verified-Plugins/WKWebView/blob/master/src/ios/MyMainViewController.m

    NSString* appLibraryFolder = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString* original;

    if ([[NSFileManager defaultManager] fileExistsAtPath:[appLibraryFolder stringByAppendingPathComponent:@"WebKit/LocalStorage/file__0.localstorage"]]) {
        original = [appLibraryFolder stringByAppendingPathComponent:@"WebKit/LocalStorage"];
    } else {
        original = [appLibraryFolder stringByAppendingPathComponent:@"Caches"];
    }

    original = [original stringByAppendingPathComponent:@"file__0.localstorage"];

    NSString* target = [[NSString alloc] initWithString: [appLibraryFolder stringByAppendingPathComponent:@"WebKit"]];

#if TARGET_IPHONE_SIMULATOR
    // the simulutor squeezes the bundle id into the path
    NSString* bundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    target = [target stringByAppendingPathComponent:bundleIdentifier];
#endif

    target = [target stringByAppendingPathComponent:@"WebsiteData/LocalStorage/file__0.localstorage"];

    // Only copy data if no existing localstorage data exists yet for wkwebview
    if (![[NSFileManager defaultManager] fileExistsAtPath:target]) {
        NSLog(@"No existing localstorage data found for WKWebView. Migrating data from UIWebView");
        [self copyFrom:original to:target];
        [self copyFrom:[original stringByAppendingString:@"-shm"] to:[target stringByAppendingString:@"-shm"]];
        [self copyFrom:[original stringByAppendingString:@"-wal"] to:[target stringByAppendingString:@"-wal"]];
    }
    else {
        NSLog(@"Existing localstorage data found for WKWebView");
    }
    // Remove UIWebView localstorage data
    [[NSFileManager defaultManager]removeItemAtPath:original error:nil];
    [[NSFileManager defaultManager]removeItemAtPath:[original stringByAppendingString:@"-shm"] error:nil];
    [[NSFileManager defaultManager]removeItemAtPath:[original stringByAppendingString:@"-wal"] error:nil];
}

- (void)pluginInitialize
{
    [self migrateLocalStorageUiToWk];
//    [self migrateLocalStorageWkToUi];
}


@end
