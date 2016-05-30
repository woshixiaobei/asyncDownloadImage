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
    _tableView.rowHeight = 100;
    //注册原型cell
    [_tableView registerNib:[UINib nibWithNibName:@"TPAppCell" bundle:nil] forCellReuseIdentifier:cellId];
    _tableView.dataSource = self;
    

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //异步执行加载数据,方法执行完毕以后,不会自己得到结果.
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}
#pragma mark-加载数据
- (void) loadData {

    //1.获取http请求管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //2.使用GET方法,获取网络方法
    [manager GET:@"https://raw.githubusercontent.com/woshixiaobei/asyncDownloadImage/master/app1json" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *responseObject) {
        NSLog(@"%@",[NSThread currentThread]);
        
        //服务器返回字典或者数组(AFN 已经做好了一直可以直接字典转模型了);
        NSLog(@"%@,%@",responseObject, [responseObject class]);
        //遍历数组,字典转模型
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSDictionary *dic in responseObject) {
            TPAppModel *model = [[TPAppModel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            
            [arrayM addObject:model];
        }
        self.appList = arrayM.copy;
        
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
    }];

}

#pragma mark-实现UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _appList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    TPAppCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    //设置cell
    TPAppModel * model = _appList[indexPath.row];
    cell.nameLabel.text = model.name;
    cell.downloadLabel.text = model.download;
    cell.iconView.image = [UIImage imageNamed:model.icon];

    return cell;
}

@end
