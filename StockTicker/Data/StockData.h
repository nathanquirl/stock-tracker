//
//  StockData.h
//  StockTicker
//
//  Created by Nathan Quirl on 9/17/14.
//  Copyright (c) 2014 Cinespan, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockData : NSObject

@property (nonatomic, assign) CGFloat closePrice;
@property (nonatomic, strong) NSDate* date;

@end
