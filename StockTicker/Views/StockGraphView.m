//
//  StockGraphView.m
//  StockTicker
//
//  Created by Nathan Quirl on 9/17/14.
//  Copyright (c) 2014 Cinespan, Inc. All rights reserved.
//

#import "StockGraphView.h"
#import "StockData.h"

static NSString* kLabelFontName = @"Helvetica";

const CGFloat kChartRuleLength = 800;
const CGFloat kLabelFontSize = 20;

@interface StockGraphView ()

@property (nonatomic, strong) CAShapeLayer *graphLayer;
@property (nonatomic, strong) CAShapeLayer *chartLayer;

@property (nonatomic, assign) CGFloat labelVerticalOffset;
@property (nonatomic, assign) NSInteger highPrice;
@property (nonatomic, assign) CGFloat priceDelta;
@property (nonatomic, assign) CGFloat dateDelta;
@property (nonatomic, assign) CGFloat labelWidth;
@property (nonatomic, assign) CGFloat lowPrice;
@property (nonatomic, assign) CGFloat margin;

@end

@implementation StockGraphView

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    // Load root layer here
    [self setLayer:[CALayer layer]];
    [self setWantsLayer:YES];
    
    self.layer.frame = self.bounds;
    self.layer.backgroundColor = [NSColor grayColor].CGColor;

    [self setupDefaults];
}

- (void)setupDefaults
{
    _dateDelta = 125.0;
    _priceDelta = 2.0;
    _lowPrice = 91.0;
    _labelVerticalOffset = 40.0;
    _highPrice = 105;
    _labelWidth = 62;
    _margin = 20.0;
}

#pragma mark - Helper Methods

- (CATextLayer*)createTextLabelWithFrame:(CGRect)frame WithText:(NSString*)text
{
    CATextLayer *label = [[CATextLayer alloc] init];
    
    [label setFont:(__bridge CFTypeRef)(kLabelFontName)];
    [label setFontSize:kLabelFontSize];

    [label setString:text];
    [label setFrame:frame];

    [label setAlignmentMode:kCAAlignmentCenter];
    [label setForegroundColor:[[NSColor whiteColor] CGColor]];
    
    return label;
}

- (CGFloat)verticalWithPrice:(CGFloat)price
{
    return (price - self.lowPrice) / self.priceDelta * self.labelVerticalOffset + 80.0;
}

- (CGFloat)horizontalWithPosition:(CGFloat)position
{
    return (position * self.dateDelta) + self.labelWidth + (self.margin * 2.0);
}

#pragma mark - Layer Setup

- (void)setupGraphLayer
{
    if (!self.graphLayer) {
        self.graphLayer = [CAShapeLayer layer];
        self.graphLayer.frame = self.bounds;
        self.graphLayer.strokeColor = [[NSColor redColor] CGColor];
        self.graphLayer.fillColor = nil;
        self.graphLayer.lineWidth = 2.0f;
        self.graphLayer.lineJoin = kCALineJoinBevel;
        
        [self.layer addSublayer:self.graphLayer];
    }
}

- (void)setupChartLayerWithData:(NSArray*)stockData
{
    if (!self.chartLayer) {
        
        // Setup shape layer for chart
        self.chartLayer = [CAShapeLayer layer];
        self.chartLayer.frame = self.bounds;
        self.chartLayer.strokeColor = [[NSColor lightGrayColor] CGColor];
        self.chartLayer.fillColor = nil;
        self.chartLayer.lineWidth = 1.0f;
        self.chartLayer.lineJoin = kCALineJoinBevel;
        
        [self.layer addSublayer:self.chartLayer];

        // Setup paths for chart layout
        CGMutablePathRef cpath = CGPathCreateMutable();

        CGFloat xorigin = [self horizontalWithPosition:0.0];
        CGFloat dx = xorigin;
        
        NSInteger pdx = self.priceDelta;
        NSInteger high = self.highPrice;
        
        // Vertical Price Data and Horizontal rules
        for (NSInteger price = self.lowPrice; price <= high; price += pdx) {
            
            NSString* priceText = [NSString stringWithFormat:@"$%ld", (long)price];
            
            CGFloat y = [self verticalWithPrice:price];

            // Add stock price label; Center label on rules
            CATextLayer *label = [self createTextLabelWithFrame:CGRectMake(20, y - 12.5, self.labelWidth, 25)
                                                       WithText:priceText];
            
            [self.chartLayer addSublayer:label];

            // Add horizontal chart graph line
            CGPathMoveToPoint(cpath, nil, dx, y);
            CGPathAddLineToPoint(cpath, nil, kChartRuleLength, y);
        }

        // Vertical line
        CGPathMoveToPoint(cpath, nil, xorigin, [self verticalWithPrice:self.lowPrice]);
        CGPathAddLineToPoint(cpath, nil, xorigin, [self verticalWithPrice:self.highPrice + self.priceDelta]);
        
        // Horizonal Date Labels
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"M/d"];
        
        for (StockData* item in stockData) {
            NSString* dateString = [formatter stringFromDate:item.date];
            
            // Add date label; Center label on data point
            CATextLayer *label = [self createTextLabelWithFrame:CGRectMake(dx - 31, 30, self.labelWidth, 25)
                                                       WithText:dateString];
            
            [self.chartLayer addSublayer:label];
            dx += self.dateDelta;
        }
        
        self.chartLayer.path = cpath;
        CFRelease(cpath);
    }
}

#pragma mark - Updating Graph Display

- (void)updateWithStockData:(NSArray*)stockData
{
    [self setupChartLayerWithData:stockData];
    [self setupGraphLayer];
    
    if ([stockData count]) {
        
        CGMutablePathRef cpath = CGPathCreateMutable();
        CGFloat dx = [self horizontalWithPosition:0.0];

        CGFloat y = [self verticalWithPrice:[[stockData objectAtIndex:0] closePrice]];
        CGPathMoveToPoint(cpath, nil, dx, y);
        
        for (StockData* item in stockData) {

            y = [self verticalWithPrice:item.closePrice];
            
            CGPathAddLineToPoint(cpath, nil, dx, y);
            dx += self.dateDelta;
        }
        
        self.graphLayer.path = cpath;
        
        CFRelease(cpath);
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.removedOnCompletion = YES;
        pathAnimation.duration = 5.0;
        pathAnimation.fromValue = @(0.0f);
        pathAnimation.toValue = @(1.0f);
        [self.graphLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    }
}

@end
