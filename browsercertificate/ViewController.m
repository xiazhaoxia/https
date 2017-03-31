//
//  ViewController.m
//  browsercertificate
//
//  Created by suxia on 3/30/17.
//  Copyright © 2017 suxia. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (strong, nonatomic) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:@"https://slc10yvj.us.oracle.com/epharmam_enu?isAdfmContainer=1"];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    WKPreferences *thisPref = [[WKPreferences alloc] init];
    thisPref.javaScriptCanOpenWindowsAutomatically = YES;
    thisPref.javaScriptEnabled = YES;
    [thisPref _setOfflineApplicationCacheIsEnabled:YES];
    theConfiguration.preferences = thisPref;
  
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:theConfiguration];
      _webView.navigationDelegate=self;
    [_webView loadRequest:request];


    [self.view addSubview:_webView];
    [self.view sendSubviewToBack:_webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation: (WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation: (WKNavigation *)navigation{
    
}

-(void)webView:(WKWebView *)webView didFailNavigation: (WKNavigation *)navigation withError:(NSError *)error {
    
}


-(void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    NSLog(@"Allow all");
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSData *iosTrustedCertDerData =
    [NSData dataWithContentsOfFile:[bundle pathForResource:@"slc05enc"
                                                    ofType:@"cer"]];
    
    
    SecCertificateRef certificate =
    SecCertificateCreateWithData(NULL,
                                 (CFDataRef) iosTrustedCertDerData);
    
    assert(certificate != NULL);
    
    NSArray* certArray = @[ (__bridge id)certificate ];
    
    /*completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);*/
    
    
    OSStatus err;
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    SecTrustResultType  trustResult = kSecTrustResultInvalid;
    NSURLCredential *credential = nil;
    
    //获取服务器的trust object
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    
    //将读取的证书设置为serverTrust的根证书
    err = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)certArray);
    err = SecTrustSetAnchorCertificatesOnly(serverTrust, 0);
    
    if(err == noErr){
        //通过本地导入的证书来验证服务器的证书是否可信，如果将SecTrustSetAnchorCertificatesOnly设置为NO，则只要通过本地或者系统证书链任何一方认证就行
        err = SecTrustEvaluate(serverTrust, &trustResult);
    }
    
    if (err == errSecSuccess && (trustResult == kSecTrustResultProceed || trustResult == kSecTrustResultUnspecified)){
            //认证成功，则创建一个凭证返回给服务器
            disposition = NSURLSessionAuthChallengeUseCredential;
             credential= [[NSURLCredential alloc]initWithTrust:serverTrust];
        
        }
        else{
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
        
        //回调凭证，传递给服务器
        if(completionHandler){
            completionHandler(disposition, credential);
        }
}

@end
