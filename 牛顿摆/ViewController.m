//
//  ViewController.m
//  牛顿摆
//
//  Created by 王奥东 on 16/12/5.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ViewController.h"
#import "swingBallView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    swingBallView *ball = [[swingBallView alloc] initWithFrame:self.view.bounds ballColor:[UIColor orangeColor]];
    [self.view addSubview:ball];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
