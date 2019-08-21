//
//  EmptyVC.h
//  SportTracker
//
//  Created by Domenico Barretta on 11/08/17.
//  Copyright © 2017 Domenico Barretta. All rights reserved.
//

#import "EmptyVC.h"

@interface EmptyVC ()

@end

@implementation EmptyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController popViewControllerAnimated:YES];
};

@end
