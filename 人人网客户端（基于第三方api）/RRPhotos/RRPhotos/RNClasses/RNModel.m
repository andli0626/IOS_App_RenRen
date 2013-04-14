//
//  RNModel.m
//  RRSpring
//
//  Created by hai zhang on 3/6/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "RNModel.h"
#import "RCBaseRequest.h"
#import "RCMainUser.h"


//////////////////////////////////
@implementation RNModel
@synthesize query = _query;
@synthesize method = _method;
@synthesize request = _request;
@synthesize result = _result;
@synthesize currentPageIdx = _currentPageIdx;
@synthesize pageSize = _pageSize;
@synthesize total = _total;
@synthesize resultAry = _resultAry;
@synthesize isLoadMore=_isLoadMore;

- (void)dealloc {
    RN_DEBUG_LOG;
    self.query = nil;
    self.method = nil;
    RL_RELEASE_SAFELY(_delegates);
    self.request = nil;
    self.result = nil;
    self.resultAry = nil;
    
    [super dealloc];
}


- (id)init {
    if (self = [super init]) {
        self.query = [NSMutableDictionary dictionary];
        RCMainUser *mainUser = [RCMainUser getInstance];
        [self.query setValue:mainUser.sessionKey forKey:@"session_key"];
        
        self.method = nil;
        self.currentPageIdx = 1;
        self.pageSize = 100;
        self.total = 100;
        self.resultAry = [NSMutableArray arrayWithCapacity:100];

        _delegates = TTCreateNonRetainingArray();
        
        RCBaseRequest *request = [[RCBaseRequest alloc] init];
        __block typeof(self) bself = self;
        request.onCompletion = ^(id result){
            [bself didFinishLoad:result];
        };
        
        request.onError = ^(RCError* error) {
            [bself didFailLoadWithError:error];
        };
        
        self.request = request;
        RL_RELEASE_SAFELY(request);
    }
    
    return self;
}
- (NSMutableArray *)delegates {
    return _delegates;
}

- (void)load:(BOOL)more {
    if (self.method == nil) {
        return;
    }
    self.isLoadMore = more;
    // 已经请求所有数据，不需要加载更多
    if (more && self.total <= [_resultAry count]) {
        return;
    }
    
    if (more) {
        _currentPageIdx = [_resultAry count] / _pageSize + 1;
    } else {
        _currentPageIdx = 1;
    }
    
    [_query setObject:[NSNumber numberWithInt:_currentPageIdx] forKey:@"page"];
    [_query setObject:[NSNumber numberWithInt:_pageSize] forKey:@"page_size"];
    [_request sendQuery:_query withMethod:_method];
    [self didStartLoad];
}

- (void) search:(NSString *)text 
{

}

#pragma mark - 网络回调
- (void)didStartLoad {
    [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
}

- (void)didFinishLoad:(id)result {
    self.result = result;
    
    [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
}


- (void)didFailLoadWithError:(RCError *)error {
    [_delegates perform:@selector(model:didFailLoadWithError:) withObject:self
             withObject:error];
}

- (void)didCancelLoad {
    [self.request cancelRequest];
    [_delegates perform:@selector(modelDidCancelLoad:) withObject:self];
}


@end
