//
//  ViewController.m
//  WKWebViewSample
//
//  Created by Queuey on 16/8/31.
//  Copyright © 2016年 queuey. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

/**
 *	接收JS调用方法
 */
NSString * const kScriptMessageName = @"observe";

@interface ViewController ()
<
WKNavigationDelegate,
WKUIDelegate,
WKScriptMessageHandler
>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ViewController


#pragma mark - life cycle
- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	
	[self.view addSubview:self.webView];
	
	NSString *urlString = @"https://jsbin.com/meniw";
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
	
	[self.webView evaluateJavaScript:@"JS方法" completionHandler:^(id _Nullable done, NSError * _Nullable error) {
		
	}];
	
	//向JS中注入代码
	NSString *jsMethodString = @"";
	WKUserScript *script = [[WKUserScript alloc] initWithSource:jsMethodString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
	[self.webView.configuration.userContentController addUserScript:script];
}


#pragma mark - WKScriptMessageHandler
/**
 *	WKScriptMessageHandler协议方法，通过JS调用APP方法进入这个方法中。
 *
 *	@param userContentController	APP和JS关联的桥梁，可以添加或移除userScript
 *	@param message		JS传递给APP的信息，常用参数为message.body && message.name
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
	NSString *messageName = message.name;
	
	NSLog(@"JS调用APP的方法为：%@ 参数为：%@",messageName,message.body);
	if ([messageName isEqualToString:kScriptMessageName]) {
		NSString *messageBody = [NSString stringWithFormat:@"%@",message.body];
		self.title = messageBody;
		if ([messageBody isEqualToString:@"systemVersion"]) {
			//自己需要实现的代码
		}
	}
	
	//通过反向映射到APP方法中
	messageName = [messageName stringByAppendingString:@":"];
	SEL selector = NSSelectorFromString(messageName);
	if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self performSelector:selector withObject:message.body];
#pragma clang diagnostic pop
	}
	
}

#pragma mark - WKNavigationDelegate



#pragma mark - WKUIDelegate

//看一眼就知道
- (void)webViewDidClose:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0) {
	
}

//警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
	
}

//确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
	
}

//输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
	
}


#pragma mark - event response
- (void)observe:(NSString *)typeString {
	NSLog(@"反向映射到abserve 参数为：%@",typeString);
}


#pragma mark - getters and setters

- (WKWebView *)webView {
	if (!_webView) {
		_webView = ({
			WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
			[configuration.userContentController addScriptMessageHandler:self name:kScriptMessageName];
			WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration: configuration];
			webView.navigationDelegate = self;
			webView;
		});
	}
	return _webView;
}



@end
