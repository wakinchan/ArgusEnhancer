@interface AZSocialManager
+ (id)instance;
- (id)friends;
- (void)getFriendList:(id)list fromConnectionType:(int)type;
@end

%hook AZHexCellDataImageURL
static NSString *leaderboard;
- (void)setUrlString:(id)urlString
{
    if ([urlString hasPrefix:@"http://api.azumio.com/view/leaderboard/"]) {
        AZSocialManager *maneger = [[%c(AZSocialManager) instance] init];
        __block int steps = 0; __block int userId = 0;
        [maneger getFriendList:^{
            for (NSDictionary *dict in [maneger friends]) {
                if ([dict[@"name"] isEqualToString:leaderboard]) {
                    steps = [dict[@"summary"][@"steps"] intValue];
                    userId = [dict[@"id"] intValue];
                }
            }
        } fromConnectionType:2];
        if (!steps && !userId) return %orig;
        // http://api.azumio.com/view/leaderboard/tile?text=[user name]%0Ais+leading+with%0A[steps]+steps&userId=[user id]
        NSString *apiUrl = [NSString stringWithFormat:@"http://api.azumio.com/view/leaderboard/tile?text=%@\nis+walking\n%d+steps&userId=%d", leaderboard, steps, userId];
        apiUrl = [apiUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        %orig(apiUrl);
    } else {
    	%orig;
    }
}
%end

#define PREF_PATH @"/var/mobile/Library/Preferences/com.kindadev.argusenhancer.plist"

static void LoadSettings()
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    id existLeaderboard = [dict objectForKey:@"leaderboard"];
    leaderboard = existLeaderboard ? [existLeaderboard copy] : nil;
}

static void PostNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    LoadSettings();
}

%ctor
{
    @autoreleasepool {
        %init();
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PostNotification, CFSTR("com.kindadev.argusenhancer.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        LoadSettings();
    }
}