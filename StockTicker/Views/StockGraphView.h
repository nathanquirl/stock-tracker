//
//  StockGraphView.h
//  StockTicker
//
//  Created by Nathan Quirl on 9/17/14.
//  Copyright (c) 2014 Cinespan, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface StockGraphView : NSView

- (void)updateWithStockData:(NSArray*)stockData;

@end
