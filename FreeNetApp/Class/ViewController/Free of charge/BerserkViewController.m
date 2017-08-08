//
//  BerserkViewController.m
//  FreeNetApp
//
//  Created by 白华君 on 2016/12/5.
//  Copyright © 2016年 BHJ. All rights reserved.
//

#import "BerserkViewController.h"
#import "BerserkCell.h"
#import "BerserkCell_1.h"
#import "BerserkCell_2.h"
#import "BerserkHeadView.h"
#import "BerserkCell_3.h"
#import "BerserkCell_4.h"
#import "BHJCustomBottomView.h"
#import "BerserkHistoryViewController.h"
#import "JXButton.h"
#import "FlagshipViewController.h"
#import "FlagshipStoreHeadView.h"

#define DURATION 0.3f

#define HotDetail @"http://192.168.0.254:4004/free/details"
#define kParticipationUrl @"http://192.168.0.254:4004/free/click"
#define kPlanUrl @"http://192.168.0.254:4004/free/start/"
#define kStatusUrl @"http://192.168.0.254:4004/free/status/"

@interface BerserkViewController ()<UITableViewDelegate,UITableViewDataSource,BHJCustomBottomViewDelegate,BHJCustomViewDelegate>

@property (nonatomic,strong)HotRecommend *detailModel;
@property (nonatomic,strong)UITableView *BerserkView;
@property (nonatomic,strong)NSMutableArray *BerserkData;
@property (nonatomic,strong)NSMutableArray *imageArr;
@property (nonatomic,strong)BHJCustomBottomView *bottomView;
@property (nonatomic,strong)FlagshipStoreHeadView *headVew;
@property (nonatomic,assign)BOOL isShow;
@property (nonatomic,strong)BerserkHistoryViewController *historyVC;
@property (nonatomic,strong)NSMutableDictionary *parameter;


@end

@implementation BerserkViewController
#pragma mark - 懒加载
-(UITableView *)BerserkView{
    
    if (!_BerserkView) {
        _BerserkView = [[UITableView alloc]initWithFrame:CGRectMake(10, 64, kScreenWidth - 20, kScreenHeight - 108) style:UITableViewStyleGrouped];
        _BerserkView.delegate = self;
        _BerserkView.dataSource = self;
        self.view.backgroundColor = HWColor(239, 239, 239, 1.0);
    }
    return _BerserkView;
}

-(NSMutableArray *)BerserkData{
    
    if (!_BerserkData) {
        _BerserkData = [NSMutableArray new];
    }
    return _BerserkData;
}

-(NSMutableArray *)imageArr{
    
    if (!_imageArr) {
        _imageArr = [NSMutableArray new];
    }
    return _imageArr;
}

-(NSMutableDictionary *)parameter{
    
    if (!_parameter) {
        _parameter = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.model.id,@"lid", nil];
    }
    return _parameter;
}

-(BHJCustomBottomView *)bottomView{
    
    if (!_bottomView) {
        _bottomView = [[BHJCustomBottomView alloc]initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44) time:90];
        _bottomView.progressView.progressTotal = 90;
        _bottomView.delegate = self;
    }
    return _bottomView;
}
#pragma mark - 生命周期
-(void)viewWillAppear:(BOOL)animated{
    
    [self setUpView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countDown:) name:@"COUNTDOWN" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getTime:) name:@"TimeString" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [self.bottomView removeFromSuperview];
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CountDown" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"TimeString" object:nil];
}

#pragma mark - 自定义
-(void)setUpView{
    
    // 获取详情数据
    [self getFreeDetailDataWithUrl:HotDetail parameter:self.parameter];
    
    self.headVew = [[FlagshipStoreHeadView alloc]initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 40)];
    self.headVew.delegate = self;
    self.BerserkView.tableHeaderView = self.headVew;
    
    
    self.navigationItem.title = @"疯抢90秒";
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(share:)];
    UIBarButtonItem *right1 = [[UIBarButtonItem alloc]initWithTitle:@"游戏规则" style:UIBarButtonItemStylePlain target:self action:@selector(gameRule:)];
    [right1 setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[right,right1];
    
    [self.BerserkView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.BerserkView registerNib:[UINib nibWithNibName:@"BerserkCell" bundle:nil] forCellReuseIdentifier:@"BerserkCell"];
    [self.BerserkView registerNib:[UINib nibWithNibName:@"BerserkCell_1" bundle:nil] forCellReuseIdentifier:@"BerserkCell_1"];
    [self.BerserkView registerNib:[UINib nibWithNibName:@"BerserkCell_2" bundle:nil] forCellReuseIdentifier:@"BerserkCell_2"];
    [self.BerserkView registerNib:[UINib nibWithNibName:@"BerserkCell_3" bundle:nil] forCellReuseIdentifier:@"BerserkCell_3"];
    [self.BerserkView registerNib:[UINib nibWithNibName:@"BerserkCell_4" bundle:nil] forCellReuseIdentifier:@"BerserkCell_4"];
    
    [self.view addSubview:self.BerserkView];
    
    // 让底部视图显示在Window上
    [[UIApplication sharedApplication].keyWindow addSubview:self.bottomView];
}


// 分享
-(void)share:(UIBarButtonItem *)sender{
    
    [[BHJTools sharedTools]showShareView];
}

// 游戏规则
-(void)gameRule:(UIBarButtonItem *)sender{
    
    NSLog(@"游戏规则");
}
/**
 展示疯抢记录
 */
-(void)showHistoryView{
    
    [UIView animateWithDuration:0 animations:^{
        [self transitionWithType:kCATransitionMoveIn WithSubtype:kCATransitionFromLeft ForView:self.historyVC.view];
        self.historyVC.view.hidden = NO;
    } completion:^(BOOL finished) {
        self.historyVC.view.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight);
        self.navigationItem.title = @"疯抢记录";
    }];
}

/**
 隐藏疯抢记录
 */
-(void)hiddenHistoryView{
    
    [UIView animateWithDuration:0 animations:^{
        [self transitionWithType:kCATransitionMoveIn WithSubtype:kCATransitionFromRight ForView:self.view];
        self.historyVC.view.hidden = YES;
    } completion:^(BOOL finished) {
        self.navigationItem.title = @"疯抢90秒";
    }];
}

#pragma mark - NSNotification
/**
 90秒倒计时通知回调
 
 @param info 通知内容
 */
-(void)countDown:(NSNotification *)info{
    
    NSInteger time = [info.userInfo[@"data"] integerValue];
    if (time > 0) {
        self.bottomView.progressView.progressTotal = 90;
        self.bottomView.progressView.progressCounter = 90 - time;
        self.bottomView.progressView.label.text = [NSString stringWithFormat:@"%ld",time];
        [self.bottomView.progressView.label setFont:[UIFont systemFontOfSize:15]];
        self.bottomView.progressView.label.textColor = [UIColor colorWithHexString:@"#e4504b"];
        self.bottomView.allowClick = YES;
    }else{
        [self.bottomView.progressView.label setFont:[UIFont systemFontOfSize:12]];
        self.bottomView.progressView.progressTotal = 90;
        self.bottomView.progressView.progressCounter = 0;
        self.bottomView.progressView.label.text = @"已结束";
        self.bottomView.progressView.label.textColor = [UIColor colorWithHexString:@"#bebebe"];
        self.bottomView.theme.completedColor = [UIColor colorWithHexString:@"#bebebe"];
        self.pageState = PageStatueWithWinning;
        self.bottomView.allowClick = NO;
        self.bottomView.progressView.userInteractionEnabled = NO;
    }
    [self.BerserkView reloadData];
}


/**
 活动倒计时回调
 
 @param info 时间
 */
-(void)getTime:(NSNotification *)info{
    
    int isStart = [info.userInfo[@"isStart"] intValue];
    int isEnd = [info.userInfo[@"isEnd"] intValue];
    if (isStart == 1 && isEnd != 1) {
        self.pageState = PageStatueWithLead;
        self.bottomView.allowClick = YES;
        
        NSNotification *notification = [[NSNotification alloc]initWithName:@"StartPlan" object:nil userInfo:@{@"isStart":@"1"}];
        [[NSNotificationCenter defaultCenter]postNotification:notification];
        
        NSString *planUrl = [kPlanUrl stringByAppendingFormat:@"%@",self.detailModel.id];
        NSString *statusUrl = [kStatusUrl stringByAppendingFormat:@"%@",self.detailModel.id];
        if (self.detailModel.status == 1) {
            [self getPlanStatus:statusUrl paramater:nil];
        }else{
            [self startPlan:planUrl paramater:nil];
        }
    }else{
        self.pageState = PageStatueWithNomal;
        self.bottomView.allowClick = NO;
        self.bottomView.theme.incompletedColor = [UIColor greenColor];
    }
    
    if (isEnd == 1) {
        [self.bottomView.progressView.label setFont:[UIFont systemFontOfSize:12]];
        self.bottomView.progressView.progressTotal = 90;
        self.bottomView.progressView.progressCounter = 0;
        self.bottomView.progressView.label.text = @"已结束";
        self.bottomView.progressView.label.textColor = [UIColor colorWithHexString:@"#bebebe"];
        self.bottomView.theme.completedColor = [UIColor colorWithHexString:@"#bebebe"];
        self.pageState = PageStatueWithWinning;
        self.bottomView.allowClick = NO;
        self.bottomView.progressView.userInteractionEnabled = NO;
    }
}

#pragma mark - 请求网络数据
/**
 获取疯抢商品信息
 
 @param url 商品信息URL
 @param parameter 参数
 */
-(void)getFreeDetailDataWithUrl:(NSString *)url parameter:(NSDictionary *)parameter{
    
    WeakSelf(weak);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if ([dic[@"status"] intValue] == 200) {
            NSDictionary *data = dic[@"data"];
            weak.detailModel = [HotRecommend mj_objectWithKeyValues:data];
            NSArray *images = data[@"shop_free"][@"shop_free_images"];
            for (NSDictionary *imageDic in images) {
                [weak.imageArr addObject:imageDic[@"image_url"]];
            }
            weak.historyVC = [[BerserkHistoryViewController alloc]initWithID:weak.detailModel.id];
            weak.historyVC.historyState = HistoryViewStatusWithBerserk;
            [weak addChildViewController:weak.historyVC];
            weak.historyVC.view.hidden = YES;
            [weak.view addSubview:self.historyVC.view];
            
            weak.headVew.storeName.text = weak.detailModel.shop_free[@"shop"][@"title"];
            
            [weak.BerserkView reloadData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

/**
 参与立免活动
 
 @param url 立免活动URL
 @param paramater 参数（计划ID）
 */
-(void)takePartInPlan:(NSString *)url paramater:(NSDictionary *)paramater{
    
    WeakSelf(weak);
    NSLog(@"%@",paramater);
    AFHTTPSessionManager *mannager = [AFHTTPSessionManager manager];
    mannager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [mannager POST:url parameters:paramater progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSInteger status = [dic[@"status"] integerValue];
        NSLog(@"%@",dic);
        if (status == 200) {
            NSString *statusUrl = [kStatusUrl stringByAppendingFormat:@"%@",self.detailModel.id];
            [weak getPlanStatus:statusUrl paramater:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

/**
 开启立免计划
 
 @param url 开启里面计划URL
 @param paramater 参数（计划ID）
 */
-(void)startPlan:(NSString *)url paramater:(NSDictionary *)paramater{
    
    AFHTTPSessionManager *mannager = [AFHTTPSessionManager manager];
    mannager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [mannager GET:url parameters:paramater progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSInteger status = [dic[@"status"] integerValue];
        if (status == 200) {
            NSString *statusUrl = [kStatusUrl stringByAppendingFormat:@"%@",self.detailModel.id];
            [self getPlanStatus:statusUrl paramater:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

/**
 获取立免计划状态
 
 @param url 立免计划状态URL
 @param paramater 参数（计划ID）
 */
-(void)getPlanStatus:(NSString *)url paramater:(NSDictionary *)paramater{
    
    AFHTTPSessionManager *mannager = [AFHTTPSessionManager manager];
    mannager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [mannager GET:url parameters:paramater progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSInteger status = [dic[@"status"] integerValue];
        NSLog(@"status=%@",dic);
        if (status == 200) {
            NSNotification *message = [[NSNotification alloc]initWithName:@"COUNTDOWN" object:nil userInfo:dic];
            [[NSNotificationCenter defaultCenter]postNotification:message];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

#pragma CATransition动画实现
- (void) transitionWithType:(NSString *) type WithSubtype:(NSString *) subtype ForView : (UIView *) view
{
    //创建CATransition对象
    CATransition *animation = [CATransition animation];
    
    //设置运动时间
    animation.duration = DURATION;
    
    //设置运动type
    animation.type = type;
    if (subtype != nil) {
        //设置子类
        animation.subtype = subtype;
    }
    //设置运动速度
    animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
    [view.layer addAnimation:animation forKey:@"animation"];
}


#pragma UIView实现动画
- (void) animationWithView : (UIView *)view WithAnimationTransition : (UIViewAnimationTransition) transition
{
    [UIView animateWithDuration:DURATION animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:transition forView:view cache:YES];
    }];
}

#pragma mark - 协议
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0 || section == 1) {
        return 1;
    }else{
        if (self.pageState == PageStatueWithLead) {
            return 2;
        }else{
            return 1;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        UITableViewCell *baseCell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        SDCycleScrollView *scrollView = [[SDCycleScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 284)];
        scrollView.imageURLStringsGroup = self.imageArr;
        [baseCell addSubview:scrollView];
        baseCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return baseCell;
    }else if (indexPath.section == 1){
        BerserkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BerserkCell" forIndexPath:indexPath];
        cell.goodsName.text = self.detailModel.shop_free[@"title"];
        cell.priceLabel.text = self.detailModel.shop_free[@"price"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else {
        if (self.pageState == PageStatueWithLead) {
            if (indexPath.row == 0) {
                BerserkCell_1 *cell_1 = [tableView dequeueReusableCellWithIdentifier:@"BerserkCell_1" forIndexPath:indexPath];
                cell_1.selectionStyle = UITableViewCellSelectionStyleNone;
                cell_1.model = (HotRecommend *)self.model;
                return cell_1;
            }else{
                BerserkCell_3 *cell_3 = [tableView dequeueReusableCellWithIdentifier:@"BerserkCell_3" forIndexPath:indexPath];
                cell_3.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell_3;
            }
        }else if (self.pageState == PageStatueWithNomal){
            BerserkCell_1 *cell_1 = [tableView dequeueReusableCellWithIdentifier:@"BerserkCell_1" forIndexPath:indexPath];
            cell_1.selectionStyle = UITableViewCellSelectionStyleNone;
            cell_1.model = (HotRecommend *)self.model;
            return cell_1;
        }else{
            BerserkCell_4 *cell_4 = [tableView dequeueReusableCellWithIdentifier:@"BerserkCell_4" forIndexPath:indexPath];
            cell_4.delegate = self;
            cell_4.awardBtn.tag = 2000;
            cell_4.fabulousBtn.tag = 3000;
            cell_4.replyBtn.tag = 4000;
            cell_4.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell_4;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        return 284;
    }else if (indexPath.section == 1){
        return 57;
    }else {
        if (self.pageState == PageStatueWithNomal) {
            return 48;
        }else if (self.pageState == PageStatueWithLead){
            if (indexPath.row == 0) {
                return 48;
            }else{
                return 142;
            }
        }else{
            return 405;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (section == 0) {
        return 1;
    }
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 1) {
        return 0.01;
    }
    return 5;
}
#pragma mark - BaseTableViewcellDelegate
-(void)MethodWithButton:(UIButton *)button index:(NSIndexPath *)cellRow{
    
    switch (button.tag) {
            
        case 2000:{
            
            NSLog(@"开奖规则");
        }
            break;
        case 3000:{
            
            NSLog(@"赞👍");
        }
            break;
        case 4000:{
            MHActionSheet *sheet = [[MHActionSheet alloc]initSheetWithTitle:@"评论" style:MHSheetStyleDefault itemTitles:nil distance:150];
            [sheet show];
            NSLog(@"评论");
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - BHJCustomBottomViewDelegate
-(void)customBottomViewClick:(UIButton *)sender{
    
    switch (sender.tag) {
        case 500:{
            self.isShow = !self.isShow;
            if (self.isShow) {
                [self showHistoryView];
            }else{
                [self hiddenHistoryView];
            }
        }
            break;
        case 501:{
            if (self.isShow) {
                // [self hiddenHistoryView];
                self.isShow = NO;
            }
            NSLog(@"增加机会");
        }
            break;
        case 503:{
            // [self hiddenHistoryView];
            self.isShow = NO;
            self.bottomView.progressView.progressTotal = 90;
            self.bottomView.progressView.progressCounter = 60;
            self.bottomView.totalTime = 30;
            NSLog(@"直达30秒");
        }
            break;
        case 502:{
            // [self hiddenHistoryView];
            self.isShow = NO;
            self.bottomView.progressView.progressTotal = 90;
            self.bottomView.progressView.progressCounter = 40;
            self.bottomView.totalTime = 50;
            NSLog(@"直达50秒");
        }
            break;
            
        default:
            break;
    }
}

-(void)customBottomCenterViewClick{
    
    [self.parameter setValue:@"1" forKey:@"user_id"];
    [self.parameter setValue:self.detailModel.id forKey:@"plan_id"];
    [self takePartInPlan:kParticipationUrl paramater:self.parameter];
}

#pragma mark - BHJCustomViewDelegate
-(void)BHJCustomViewMethodWithButton:(UIButton *)sender{
    
    FlagshipViewController *flagsVC = [[FlagshipViewController alloc]init];
    flagsVC.cid = self.detailModel.shop_free[@"shop"][@"id"];
    [self.navigationController pushViewController:flagsVC animated:YES];
}
@end
