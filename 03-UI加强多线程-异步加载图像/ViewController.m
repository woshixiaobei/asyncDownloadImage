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
#import "CZAdditions.h"
#import "TPWebImageManager.h"

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
/**
 *  操作缓冲池
 */
@property (nonatomic, strong) NSMutableDictionary *operationCache;
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
    
    
    NSLog(@"%@",[TPWebImageManager shareManager]);
    //实例化队列
    _downloadQueue = [[NSOperationQueue alloc]init];
    
    //实例化图像缓冲池
    _imageCache = [NSMutableDictionary dictionary];
    
    //实例化操作缓冲池
    _operationCache = [NSMutableDictionary dictionary];
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
    //清空下载操作缓冲池
    [_operationCache removeAllObjects];
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
        NSLog(@"返回到内存缓存图像");
        cell.iconView.image = cacheImage;
        return cell;
    }
    
    
    //判断沙盒缓存是否存在
    cacheImage = [UIImage imageWithContentsOfFile:[self cachePathWithURLString:model.icon]];
    if (cacheImage != nil) {
        NSLog(@"返回到沙盒图像");
        //1.设置cell图像
        cell.iconView.image = cacheImage;
        //2.设置内存缓存
        [_imageCache setObject:cacheImage forKey:model.icon];
        return cell;
    }
    
    //加载网络图片
    NSURL *url = [NSURL URLWithString:model.icon];
    
    UIImage *placeHolder = [UIImage imageNamed:@"user_default"];
    cell.iconView.image = placeHolder;
    
    
    //异步加载图像
    //1.添加操作
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        
        NSLog(@"正在下载的图像%@,%zd",model.name,self.downloadQueue.operationCount);
        //0.模拟延迟
//        [NSThread sleepForTimeInterval:1.0];
        //0.假设第0张下载事件特别长,模拟延时
        if (indexPath.row == 0) {
            [NSThread sleepForTimeInterval:3.0];
        }
        
        //1>.将数据转换为二进制数据
        NSData *data = [NSData dataWithContentsOfURL:url];
        //2>.将二进制数据转为图像
        UIImage *image = [UIImage imageWithData:data];
    
        
        //将图像保存到缓冲池,判断图像是否正确从网络服务器下载完成
        if (image != nil) {
            [self.imageCache setObject:image forKey:model.icon];
            
            //将图像保存到沙盒
            [data writeToFile:[self cachePathWithURLString:model.icon] atomically:YES];
        }
        
        //?????下载完成之后,将url对应的操作从缓冲池中移除
        [self.operationCache removeObjectForKey:model.icon];
        
        //3>.在主线程上更新UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"队列中下载的操作数是%zd,%@",self.downloadQueue.operationCount,self.operationCache);
            
            cell.iconView.image = image;
        }];
        
    }];
    //2.将操作添加到队列
    [_downloadQueue addOperation:op];
    
    //将操作添加到下载缓冲池
    [_operationCache setObject:op forKey:model.icon];
    return cell;
}

/**
 *  根据url字符串生成缓存的全路径
 */


- (NSString *) cachePathWithURLString:(NSString *)urlString {

    //1.获取cache目录
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    
    //2.生成MD5的文件
    NSString *fileName = [urlString cz_md5String];
    
    //3.返回合成的全路径
    return [cacheDir stringByAppendingPathComponent:fileName];

}

@end
