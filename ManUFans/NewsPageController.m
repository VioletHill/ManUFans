//
//  NewsPageController.m
//  ManUFans
//
//  Created by 邱峰 on 13-10-25.
//  Copyright (c) 2013年 邱峰. All rights reserved.
//

#import "NewsPageController.h"
#import "News.h"

@interface NewsPageController ()

@property (nonatomic,retain) IBOutlet UIWebView *webView;
@property (nonatomic,retain) UIActivityIndicatorView* span;
@end

@implementation NewsPageController

@synthesize newsHref=_newsHref;
@synthesize span=_span;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }

    return self;
}

-(UIWebView*) webView
{
    if (_webView==nil)
    {
        _webView=[[UIWebView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:_webView];
    }
    return _webView;
}

-(UIActivityIndicatorView*) span
{
    if (_span==nil)
    {
        _span=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _span.center=CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height/2);
        [_span startAnimating];
    }
    return _span;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.span];

    self.webView.hidden=true;
}

-(void) viewDidAppear:(BOOL)animated
{
    NSString* a=[[News sharedNews] getNewsContentByHref:self.newsHref];
    
    if ([a isEqualToString:@"errorWithNoConnect"])
    {
        a=nil;
    }
    else if ( a==nil || [a isEqualToString:@""])
    {
        UIAlertView* alertView=[[UIAlertView alloc] initWithTitle:@"数据加载失败" message:@"对不起，数据加载失败，该消息可能已经被官方取消或无法解析" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    [self.webView loadHTMLString:a baseURL:nil];
    [self.span removeFromSuperview];
    self.webView.hidden=false;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
