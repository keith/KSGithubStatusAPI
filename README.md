# KSGithubStatusAPI

This API Controller use Github's [system status API](https://github.com/blog/1348-github-system-status-api) and returns the current status


## Usage

```objc
[[KSGithubStatusAPI sharedClient] checkStatus:^(NSNumber *available, NSError *error) {
    if ([available boolValue]) {
        NSLog(@"Github is available");
    } else {
        NSLog(@"Github isn't available");
    }
    
    NSLog(@"Details: %@", [[KSGithubStatusAPI sharedClient] currentStatusDetails]);
    
    NSLog(@"Last Checked: %@", [[KSGithubStatusAPI sharedClient] lastCheckedDate]);
    NSLog(@"Last Checked Pretty: %@", [[KSGithubStatusAPI sharedClient] lastCheckedPrettyDate]);
}];
```

### Installation

1. Use [CocoaPods](http://cocoapods.org/), in your Podfile

		pod 'KSGithubStatusAPI', '~> 0.1.0'

2. Add [AFNetworking](http://afnetworking.com/) and [Reachability](https://github.com/tonymillion/Reachability) to your project. Add both `KSGithubStatusAPI` files to your project, then just import `KSGithubStatusAPI.h`.
