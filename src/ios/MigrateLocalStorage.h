#import <Cordova/CDVPlugin.h>

@interface MigrateLocalStorage : CDVPlugin {}

- (BOOL) copyFrom:(NSString*)src to:(NSString*)dest;
- (void) migrateLocalStorageUiToWk;
- (void) migrateLocalStorageWkToUi;

@end
