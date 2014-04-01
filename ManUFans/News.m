//
//  News.m
//  ManUFans
//
//  Created by 邱峰 on 13-10-24.
//  Copyright (c) 2013年 邱峰. All rights reserved.
//

#import "News.h"
#import "TFHpple.h"
#import "ManUnitedNewsEntities.h"

@interface News ()

@property (nonatomic,copy) NSString* mainWeb;
@property (nonatomic, retain) NSMutableArray* flag;


@end

@implementation News
{
    NSArray* titleArray;
    NSArray* hrefArray;
}

@synthesize mainWeb=_mainWeb;
@synthesize flag=_flag;
@synthesize delegate;

static News* _sharedNews;

+(News*) sharedNews
{
    if (_sharedNews==nil)
    {
        _sharedNews=[[News alloc] init];
    }
    return _sharedNews;
}

+(void) purge
{
    _sharedNews=nil;
}

-(NSMutableArray*) flag
{
    if (_flag==nil)
    {
        _flag=[[NSMutableArray alloc] init];
    }
    return _flag;
}

-(NSString*) mainWeb
{
    if (_mainWeb==nil)
    {
        _mainWeb=@"http://www.manunited.com.cn";
    }
    return _mainWeb;
}


-(BOOL) isExistNewsByUrlString:(NSString*)href inArray:(NSArray*) dataArray
{

    return NO;
}

-(void) resetFlagWithCount:(int)count
{
    [self.flag removeAllObjects];
    for (int i=0; i<count; i++)
    {
        [self.flag addObject:@(false)];
    }
}

-(void) saveNewData
{
    if (titleArray==nil) return ;
    
    NSArray* database=[ManUnitedNewsEntities findAll];
    
    [self resetFlagWithCount:(int)titleArray.count];
    
    for (int i=0; i<titleArray.count; i++)
    {
        NSString* href=[self.mainWeb stringByAppendingString:[[hrefArray objectAtIndex:i] objectForKey:@"href"]];
        NSString* title=((TFHppleElement*) [titleArray objectAtIndex:i]).content;
        [self updateNewsWithHref:href title:title andId:(int)titleArray.count*i inDataArray:database];
    }
    
    [self clearUnflagObjInDataArray:database];
    
    titleArray=nil;
    hrefArray=nil;
}

-(void) clearUnflagObjInDataArray:(NSArray*)array
{
    for (int i=0; i<array.count; i++)
    {
        if ([[self.flag objectAtIndex:i] boolValue]==false)
        {
            ManUnitedNewsEntities* obj=[array objectAtIndex:i];
            [obj deleteEntity];
        }
    }
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}

-(void) updateNewsWithHref:(NSString*)href title:(NSString*)title andId:(int)newsId inDataArray:(NSArray*)array
{
    
    for (int i=0; i<array.count; i++)
    {
        ManUnitedNewsEntities* obj=[array objectAtIndex:i];
        if ([obj.contentUrl isEqualToString:href])
        {
            obj.newsID=@(newsId);
            obj.title=title;
            obj.contentUrl=href;
            [self.flag replaceObjectAtIndex:i withObject:@(true)];
            [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
            return ;
        }
    }
    
    ManUnitedNewsEntities* newMan=[ManUnitedNewsEntities createEntity];
    newMan.newsID=@(newsId);
    newMan.title=title;
    newMan.contentUrl=href;
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}


-(void) getNewsTitleFromWeb
{
    NSError* error;
    NSString* newsWeb=[self.mainWeb stringByAppendingString:@"/zh-CN/NewsAndFeatures/FootballNews.aspx?pageno=" ];
    NSURL* newsUrl=[NSURL URLWithString:[newsWeb stringByAppendingString:@"1"]];    //第一页
    
    NSString* htmlString=[NSString stringWithContentsOfURL:newsUrl encoding:NSUTF8StringEncoding error:&error];
    
    if (error)
    {
        NSLog(@"%@",error);
        UIAlertView* errorView=[[UIAlertView alloc] initWithTitle:@"获取信息失败" message:@"检查网络是否正常，如一切正常，请联系我们,谢谢您的支持" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [errorView show];
        return ;
    }

    NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple* xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    titleArray=[xpathParser  searchWithXPathQuery:@"//div[@id='nln_newsListContent']/text()"];
    hrefArray=[xpathParser searchWithXPathQuery:@"//a[@class='nln_newsList3']"];
    
}

-(NSArray*) getNews
{
    NSArray* array=[ManUnitedNewsEntities findAllSortedBy:@"newsID" ascending:YES];
    NSMutableArray* res=[[NSMutableArray alloc] init];
    for (ManUnitedNewsEntities* obj in array)
    {
        NSString* title=obj.title;
        if (self.delegate!=nil)
        {
            [self.delegate addObject:obj.contentUrl];
        }
        [res addObject:title];
    }
    
    return res;
}


-(NSString*) getContentFromeCurrentUrl:(NSString*)href
{
    NSError* error=nil;
    NSString* htmlString=[NSString stringWithContentsOfURL:[[NSURL alloc] initWithString:href] encoding:NSUTF8StringEncoding error:&error];
    
    if (error) return nil;
    
    NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple* xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    TFHppleElement* ele=[[xpathParser searchWithXPathQuery:@"//div[@class='newsStory']"] firstObject];
    
    return ele.raw;
}

-(NSString*) getNewsContentFromWebSite:(NSString*)href
{
    NSError* error=nil;
    NSString* htmlString=[NSString stringWithContentsOfURL:[[NSURL alloc] initWithString:href] encoding:NSUTF8StringEncoding error:&error];
    
    if (error)
    {
        NSLog(@"%@",error);
        UIAlertView* errorView=[[UIAlertView alloc] initWithTitle:@"获取信息失败" message:@"检查网络是否正常，如一切正常，请联系我们,谢谢您的支持" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [errorView show];
        return [NSString stringWithFormat:@"errorWithNoConnect"];
    }
    
  
    
    NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple* xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    NSMutableString* res=[[NSMutableString alloc] init];
    //处理图片
    @try {
        TFHppleElement* image=[[xpathParser searchWithXPathQuery:@"//div[@id='mainImgDiv']"] firstObject];
        NSMutableString* imageDiv=[image.raw mutableCopy];
        NSRange widthRange=[imageDiv rangeOfString:@"width:"];
        unsigned long endIndex=[imageDiv rangeOfString:@"px"].location;
        widthRange=NSMakeRange(widthRange.length+widthRange.location,endIndex-widthRange.length-widthRange.location);
        
        int width=[[imageDiv substringWithRange:widthRange] intValue];
        
        NSRange heightRange=[imageDiv rangeOfString:@"height:"];
        endIndex=[[imageDiv substringFromIndex:heightRange.location] rangeOfString:@"px"].location+widthRange.location+widthRange.length+3;
        heightRange=NSMakeRange(heightRange.location+heightRange.length, endIndex-heightRange.length-heightRange.location);
        int height=[[imageDiv substringWithRange:heightRange] intValue];
        [imageDiv replaceCharactersInRange:widthRange withString:[NSString stringWithFormat:@"%d",310]];
        [imageDiv replaceCharactersInRange:heightRange withString:[NSString stringWithFormat:@"%f",height/ ((float)width/310)]];
        [imageDiv insertString:[NSString stringWithFormat:@"background-size:310px,%fpx;",height/ ((float)width/310)] atIndex:[imageDiv rangeOfString:@">"].location-1];
        NSLog(@"%@",imageDiv);
        [res appendString:imageDiv];
    }
    @catch (NSException *exception) {
    
    }
    
    //内容
    TFHppleElement* ele=[[xpathParser searchWithXPathQuery:@"//div[@class='newsStory']"] firstObject];
    [res appendString:ele.raw];
    
    ///新闻不止一页
    TFHppleElement* pageNumEle=[[xpathParser searchWithXPathQuery:@"//span[@id='phmaincontent_0_phcontent_0_ctl00_pgPaginator1']/span/text()"] firstObject];
    NSRange range=[pageNumEle.content rangeOfString:@"的"];
    int pageNum=[[pageNumEle.content substringFromIndex: range.location+1] intValue];

    for (int i=2; i<=pageNum; i++)
    {
        [res appendString:[self getContentFromeCurrentUrl:[href stringByAppendingFormat:@"?pageno=%d",i] ] ];
    }
    return res;
}

-(NSString*) getNewsContentByHref:(NSString*)href
{
    NSArray* array=[ManUnitedNewsEntities findAllSortedBy:@"newsID" ascending:YES];
    for (ManUnitedNewsEntities* obj in array)
    {
        if ([obj.contentUrl isEqualToString:href])
        {
            if (obj.content!=nil || [obj.content isEqualToString:@""]) return obj.content;
            else
            {
                obj.content=[self getNewsContentFromWebSite:href];
                [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
                return obj.content;
            }
        }
    }
    return [self getNewsContentFromWebSite:href];
}

@end
