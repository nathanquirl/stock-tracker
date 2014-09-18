//
//  ViewController.m
//  StockTicker
//
//  Created by Nathan Quirl on 9/17/14.
//  Copyright (c) 2014 Cinespan, Inc. All rights reserved.
//

#import "ViewController.h"
#import "StockGraphView.h"
#import "DataManager.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet StockGraphView *stockGraphView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear
{
    [self updateGraphData];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (void)updateGraphData
{
    [[DataManager sharedInstance] loadStockDataWithCompletion:^(NSArray *stockData, NSError *error) {
        
        if (!error) {
            [self.stockGraphView updateWithStockData:stockData];
        }
    }];
}

- (IBAction)refreshData:(id)sender
{
    [self updateGraphData];
}

@end
