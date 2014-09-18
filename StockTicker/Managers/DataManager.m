//
//  DataManager.m
//  StockTicker
//
//  Created by Nathan Quirl on 9/17/14.
//  Copyright (c) 2014 Cinespan, Inc. All rights reserved.
//

#import "DataManager.h"

static NSString* kStockDataKey = @"stockdata";
static NSString* kClosePriceKey = @"close";
static NSString* kDateKey = @"date";

@interface DataManager ()
@end

@implementation DataManager

+ (DataManager*)sharedInstance
{
    static DataManager *s_sharedInstance = nil;
    
    // Thread-safe allocation
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        s_sharedInstance = [[DataManager alloc] init];
    });
    
    return s_sharedInstance;
}


- (void)loadStockDataWithCompletion:(void (^)(NSArray* stockData, NSError* error))completion
{
    NSError* error = nil;
    
    NSData* data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"stockprices" ofType:@"json"]];
    
    // Convert JSON response into dictionary
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if (error) {
        NSLog(@"Error: unable to parse JSON data");
        
        if (completion)
            completion(nil, error);
    }
    else {
    
        NSArray *stockData = [json objectForKey:kStockDataKey];
        
        // Convert to more efficient data structure
        NSMutableArray* items = [[NSMutableArray alloc] init];
        
        // Setup conversion of string to NSDate
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        for (NSDictionary* item in stockData) {
            StockData* stockObject = [[StockData alloc] init];
            
            stockObject.date =  [dateFormatter dateFromString:[item objectForKey:kDateKey]];
            stockObject.closePrice = [[item objectForKey:kClosePriceKey] floatValue];

            [items addObject:stockObject];
        }
        
        if (completion)
            completion(items, nil);
    }
}

@end
