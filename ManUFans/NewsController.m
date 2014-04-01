//
//  NewsController.m
//  ManUFans
//
//  Created by 邱峰 on 13-10-24.
//  Copyright (c) 2013年 邱峰. All rights reserved.
//

#import "NewsController.h"
#import "News.h"
#import "NewsPageController.h"

@interface NewsController ()

@property (nonatomic,retain) NSMutableArray* dataTitleArray;
@property (nonatomic,retain) NSMutableArray* dataHrefArray;
@property (nonatomic,retain) NSMutableArray* hrefArray;

@end

@implementation NewsController


@synthesize dataTitleArray=_dataTitleArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSMutableArray*) dataHrefArray
{
    if (_dataHrefArray==nil)
    {
        _dataHrefArray=[[NSMutableArray alloc] init];
    }
    return _dataHrefArray;
}

-(NSMutableArray*) hrefArray
{
    if (_hrefArray==nil)
    {
        _hrefArray=[[NSMutableArray alloc] init];
    }
    return _hrefArray;
}

-(NSMutableArray*) dataTitleArray
{
    if (_dataTitleArray==nil)
    {
        //第一次的调用时，deletage是dataHrefArray
        [News sharedNews].delegate=self.dataHrefArray;
        _dataTitleArray=[[[News sharedNews] getNews] mutableCopy];
    }
    return _dataTitleArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (_refreshHeaderView == nil)
    {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.frame.size.height, self.view.bounds.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
        view.navigationHeight=64;           //顶部的高度 不是navigationbar的高度。。。
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataTitleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[self.tableView dequeueReusableCellWithIdentifier:@"MyCell"];
    
    NSString* obj=[self.dataTitleArray objectAtIndex:indexPath.row];
    cell.textLabel.text=obj;
    
    return cell;
}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell* cell=(UITableViewCell*)sender;
    NSIndexPath* indexPath=[self.tableView indexPathForCell:cell];
    
    NewsPageController* viewController=segue.destinationViewController;
    viewController.newsHref=[self.dataHrefArray objectAtIndex:indexPath.row];
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource
{
	_reloading = YES;
    [NSThread detachNewThreadSelector:@selector(doInBackground) toTarget:self withObject:nil];
}

-(void) addNewsFrom:(NSArray*)array
{
    
    NSString* firstData=[self.dataTitleArray firstObject];
    for (int i=0; i<array.count; i++)
    {
        NSString* obj=[array objectAtIndex:i];
        if (firstData==nil || ![obj isEqualToString:firstData])
        {
            [self.dataTitleArray insertObject:obj atIndex:i];
            [self.dataHrefArray insertObject:[self.hrefArray objectAtIndex:i] atIndex:i];
        }
        else
        {
            break;
        }
    }
    
    [self.tableView reloadData];
}


- (void)doneLoadingTableViewData
{
    [[News sharedNews] saveNewData];
    //每次调用前要先清空href
    self.hrefArray=nil;
    [News sharedNews].delegate=self.hrefArray;
    [self addNewsFrom:[[News sharedNews] getNews]];
    _reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
}

-(void)doInBackground
{
    [[News sharedNews] getNewsTitleFromWeb];
    //后台操作线程执行完后，到主线程更新UI
    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
}



#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}



@end
