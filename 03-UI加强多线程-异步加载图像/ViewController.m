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
#import "UIImageView+WebCache.h"


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
/**
 *  下载队列
 */
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
/**
 *  图像缓冲池
 */
@property (nonatomic, strong) NSMutableDictionary *imageCache;
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
    
    //实例化队列
    _downloadQueue = [[NSOperationQueue alloc]init];
    
    //实例化图像缓冲池
    _imageCache = [NSMutableDictionary dictionary];
    
    //异步执行加载数据,方法执行完毕以后,不会自己得到结果.
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
    //释放资源
    //1.下载好的网络图片-模型添加属性保存图像,不好释放,下一步就是添加图像缓冲池,方便释放
    //2.没有完成的下载操作
    [_imageCache removeAllObjects];
    [_downloadQueue cancelAllOperations];
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

   
    //判断缓冲池中是否缓存,model.icon对应的image
    UIImage *cacheImage = _imageCache[model.icon];
    if (cacheImage != nil) {
        cell.iconView.image = cacheImage;
        return cell;
    }
    
    //加载网络图片
    NSURL *url = [NSURL URLWithString:model.icon];
    
    UIImage *placeHolder = [UIImage imageNamed:@"user_default"];
    cell.iconView.image = placeHolder;
    
    
    //异步加载图像
    //1.添加操作
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        
        //0.模拟延迟
        [NSThread sleepForTimeInterval:1.0];
        //1>.将数据转换为二进制数据
        NSData *data = [NSData dataWithContentsOfURL:url];
        //2>.将二进制数据转为图像
        UIImage *image = [UIImage imageWithData:data];
        
        //将图像添加到图像缓冲池中
        [self.imageCache setObject:image forKey:model.icon];
        
        //3>.在主线程上更新UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            cell.iconView.image = image;
        }];
        
    }];
    //2.将操作添加到队列
    [_downloadQueue addOperation:op];
    return cell;
}

@end
