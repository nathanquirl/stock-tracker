//
//  DataManager.h
//  StockTicker
//
//  Created by Nathan Quirl on 9/17/14.
//  Copyright (c) 2014 Cinespan, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StockData.h"

@interface DataManager : NSObject

//=========================================================
// loadStockDataWithCompletion
//
// parameters:
// stockData: Calls completion handler with array of StockData items

- (void)loadStockDataWithCompletion:(void (^)(NSArray* stockData, NSError* error))completion;

+ (DataManager*)sharedInstance;

@end
