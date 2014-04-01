//
//  News.h
//  ManUFans
//
//  Created by 邱峰 on 13-10-24.
//  Copyright (c) 2013年 邱峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface News : NSObject

+(News*) sharedNews;
+(void) purge;

/*
 改函数不会更新数据库
 */
-(void) getNewsTitleFromWeb;

-(NSArray*) getNews;
/*
 更新数据库 需要注意读写顺序
 */
-(void) saveNewData;

-(NSString*) getNewsContentByHref:(NSString*)href;

@property(nonatomic,weak) id delegate;

@end

