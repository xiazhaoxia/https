//
//  ViewController.h
//  browsercertificate
//
//  Created by suxia on 3/30/17.
//  Copyright © 2017 suxia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ViewController : UIViewController <WKNavigationDelegate,
WKUIDelegate>


@end

@interface WKPreferences (MyPreferences)
- (void)_setOfflineApplicationCacheIsEnabled:(BOOL)offlineApplicationCacheIsEnabled;
@end


