//
//  NewsPageController.m
//  ManUFans
//
//  Created by 邱峰 on 13-10-25.
//  Copyright (c) 2013年 邱峰. All rights reserved.
//

#import "NewsPageController.h"

@interface NewsPageController ()

@end

@implementation NewsPageController

@synthesize news=_news;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
