//
//  ViewController.m
//  ManUFans
//
//  Created by 邱峰 on 13-10-24.
//  Copyright (c) 2013年 邱峰. All rights reserved.
//

#import "ViewController.h"
#import "News.h"
#import "ManUnitedNewsEntities.h"

@interface ViewController ()

@end

@implementation ViewController
- (IBAction)save:(id)sender
{
   // NSLog(@"%d",((ManUnitedNewsEntities*)[ManUnitedNewsEntities findFirst]).newsID);
    int i=0;
    for (ManUnitedNewsEntities* ab in [ManUnitedNewsEntities findAll])
    {
        ab.title=[NSString stringWithFormat:@"a%d",i++];
        ab.contentUrl=@"a";
    }
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}

- (IBAction)log:(id)sender
{
    NSLog(@"%lu",(unsigned long)[[News sharedNews] getNews].count);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   // [[News sharedNews] getNews];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
