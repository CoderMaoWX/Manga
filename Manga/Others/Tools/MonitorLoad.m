//
//  MonitorLoad.m
//  Manga
//
//  Created by 610582 on 2021/8/4.
//

#import "MonitorLoad.h"
#import "iManga-Swift.h"

@implementation MonitorLoad

+ (void)load {
//    ApiClass *api = [[ApiClass alloc] init];
//    [api studyApi];
    [UIViewController swizzlingMethod];
}

+ (void)initialize {
    
    //[NSURLSessionConfiguration defaultSessionConfiguration].connectionProxyDictionary = @{};    
}

@end
