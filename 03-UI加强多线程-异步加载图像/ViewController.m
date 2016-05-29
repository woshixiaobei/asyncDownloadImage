//
//  ViewController.m
//  03-UI加强多线程-异步加载图像
//
//  Created by 小贝 on 16/5/29.
//  Copyright © 2016年 小贝. All rights reserved.
//

#import "ViewController.h"
#import "TPAppModel.h"
#import "TPAppCell.h"
#import "AFNetworking.h"


static NSString * cellId = @"cellId";
@interface ViewController ()<UITableViewDataSource>

/**
 *  表格视图
 */
@property (nonatomic, strong) UITableView *tableView;
/**
 *  应用程序列表数组
 */
@property (nonatomic, strong) NSArray <TPAppModel *>*appList;

@end

@implementation ViewController

- (void)loadView {

    _tableView= [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.view = _tableView;
    
    //注册原型cell
    [_tableView registerNib:[UINib nibWithNibName:@"TPAppCell" bundle:nil] forCellReuseIdentifier:cellId];
    _tableView.dataSource = self;
    

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}
#pragma mark-加载数据
- (void) loadData {

    //1.获取http请求管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //2.使用GET方法,获取网络方法
    [manager GET:@"https://raw.githubusercontent.com/woshixiaobei/asyncDownloadImage/master/json" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray * responseObject) {
        NSLog(@"%@,%@",responseObject,[responseObject class]);
        NSLog(@"%@",[NSThread currentThread]);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败11");
    }];
    

}

#pragma mark-实现UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.textLabel.text = @(indexPath.row).description;
    return cell;
}

@end
