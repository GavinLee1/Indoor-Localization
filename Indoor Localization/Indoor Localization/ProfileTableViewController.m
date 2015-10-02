//
//  ProfileViewController.m
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/9/25.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "ProfileTableHeadView.h"

@interface ProfileTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end


@implementation ProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"---------------------------------------------");
    ProfileTableHeadView *headView = [ProfileTableHeadView headView];
    self.tableView.tableHeaderView = headView;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
