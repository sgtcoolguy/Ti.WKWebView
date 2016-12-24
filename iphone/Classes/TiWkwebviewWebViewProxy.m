/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiWkwebviewWebViewProxy.h"
#import "TiWkwebviewWebView.h"
#import "TiUtils.h"
#import "TiHost.h"

@implementation TiWkwebviewWebViewProxy

- (TiWkwebviewWebView *)webView
{
    return (TiWkwebviewWebView *)self.view;
}

#pragma mark - Public APIs

#pragma mark Getters

- (id)disableBounce
{
    return NUMBOOL(![[[[self webView] webView] scrollView] bounces]);
}

- (id)scrollsToTop
{
    return NUMBOOL([[[[self webView] webView] scrollView] scrollsToTop]);
}

- (id)allowsBackForwardNavigationGestures
{
    return NUMBOOL([[[self webView] webView] allowsBackForwardNavigationGestures]);
}

- (id)userAgent
{
    return [[[self webView] webView] customUserAgent] ?: [NSNull null];
}

- (id)url
{
    return [[[[self webView] webView] URL] absoluteString];
}

- (id)title
{
    return [[[self webView] webView] title];
}

- (id)progress
{
    return NUMDOUBLE([[[self webView] webView] estimatedProgress]);
}

- (id)loading
{
    return NUMBOOL([[[self webView] webView] isLoading]);
}

- (id)secure
{
    return NUMBOOL([[[self webView] webView] hasOnlySecureContent]);
}

- (id)backForwardList
{
    WKBackForwardList *list = [[[self webView] webView] backForwardList];
    
    NSMutableArray *backList = [NSMutableArray arrayWithCapacity:list.backList.count];
    NSMutableArray *forwardList = [NSMutableArray arrayWithCapacity:list.forwardList.count];
    
    for (WKBackForwardListItem *item in list.backList) {
        [backList addObject:[TiWkwebviewWebViewProxy dictionaryFromBackForwardItem:item]];
    }
    
    for (WKBackForwardListItem *item in list.forwardList) {
        [forwardList addObject:[TiWkwebviewWebViewProxy dictionaryFromBackForwardItem:item]];
    }
    
    return @{
        @"currentItem": [TiWkwebviewWebViewProxy dictionaryFromBackForwardItem:[list currentItem]],
        @"backItem": [TiWkwebviewWebViewProxy dictionaryFromBackForwardItem:[list backItem]],
        @"forwardItem": [TiWkwebviewWebViewProxy dictionaryFromBackForwardItem:[list forwardItem]],
        @"backList": backList,
        @"forwardList": forwardList
    };
}

#pragma mark Methods

- (void)stopLoading:(id)unused
{
    [[[self webView] webView] stopLoading];
}

- (void)reload:(id)unused
{
    [[[self webView] webView] reload];
}

- (void)goBack:(id)unused
{
    [[[self webView] webView] goBack];
}

- (void)goForward:(id)unused
{
    [[[self webView] webView] goForward];
}

- (id)canGoBack:(id)unused
{
    return NUMBOOL([[[self webView] webView] canGoBack]);
}

- (id)canGoForward:(id)unused
{
    return NUMBOOL([[[self webView] webView] canGoForward]);
}

- (void)evalJS:(id)args
{
    NSString *code = nil;
    KrollCallback *callback = nil;
    
    ENSURE_ARG_AT_INDEX(code, args, 0, NSString);
    ENSURE_ARG_AT_INDEX(callback, args, 1, KrollCallback);

    [[self webView] stringByEvaluatingJavaScriptFromString:code
                                     withCompletionHandler:^(NSString *result, NSError *error) {
        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
            @"result": result ?: [NSNull null],
            @"success": NUMBOOL(error == nil)
        }];
        
        if (error) {
            [event setObject:[error localizedDescription] forKey:@"error"];
        }
        
        [callback call:[[NSArray alloc] initWithObjects:&event count:1] thisObject:self];
    }];
}

#pragma mark Utilities

+ (NSDictionary *)dictionaryFromBackForwardItem:(WKBackForwardListItem *)item
{
    return @{@"url": item.URL.absoluteString, @"initialUrl": item.initialURL.absoluteString, @"title": item.title};
}

@end
