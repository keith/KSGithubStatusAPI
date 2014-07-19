# KSGithubStatusAPI

This API Controller use Github's [system status API](https://github.com/blog/1348-github-system-status-api) and returns the current status


## Usage

```objc
KSGithubStatusAPI *statusAPI = [[KSGithubStatusAPI alloc] init];
[statusAPI checkStatus:^(KSGithubStatus *status) {
    if (status.isAvailable) {
        NSLog(@"Github is available");
    } else {
        NSLog(@"Github isn't available");
    }

    NSLog(@"Status: %@", status.status);
    NSLog(@"Details: %@", status.details);

    NSLog(@"Last Checked: %@", status.readableCreatedAtDate);
    NSLog(@"Last Checked: %@", statusAPI.readableLastCheckedDate);

    NSLog(@"Github updated date: %@", status.readableGithubUpdatedDate);
}];
```

### Installation

1. Use [CocoaPods](http://cocoapods.org/), in your Podfile

		pod 'KSGithubStatusAPI', '~> 0.2.0'

2. Add [Reachability](https://github.com/tonymillion/Reachability) to your project. Add all `.h` and `.m` files to your project.
