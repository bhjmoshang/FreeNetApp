//
//  FlagshipViewController.m
//  FreeNetApp
//
//  Created by 白华君 on 2016/12/19.
//  Copyright © 2016年 BHJ. All rights reserved.
//

#import "FlagshipViewController.h"
#import "flagShipHeadView.h"
#import "flagCell_1.h"
#import "flagCell_2.h"
#import "homeCell_2.h"
#import "specialDetailCell_2.h"
#import "flagCell_3.h"
#import "specialHeadView_1.h"
#import "flagCell_4.h"
#import "flagCell_5.h"
#import "flagShipHeadView_1.h"
#import "specialDetailCell_6.h"
#import "specialiDetailCell_7.h"
#import "RecommendCell.h"

#import "MoreCouponViewController.h"
#import "SearchRouteViewController.h"
#import "EvaluateViewController.h"
#import "StoreListViewController.h"

#import "FlagsSpecialViewController.h"
#import "FlagsCoupunViewController.h"
#import "FlagsFreeViewController.h"
#import "MemberViewController.h"
#import "SpecialDetailViewController.h"

#import "FlagStoreModel.h"

#define kFlagDetail @"http://192.168.0.254:4004/special/shops"
#define kFocuseUrl @"http://192.168.0.254:4004/special/shopfocuse"
#define kStoreListUrl @"http://192.168.0.254:4004/special/shopbranch"
#define kEvaluateUrl @"http://192.168.0.254:4004/special/productComments"
#define kOthers @"http://192.168.0.254:4004/special/others"

@interface FlagshipViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate,BHJReusableViewDelegate>

@property (nonatomic,strong)UICollectionView *flagshipView;
@property (nonatomic,strong)NSMutableArray *imageArr;
@property (nonatomic,strong)NSMutableArray *dataBase;
@property (nonatomic,strong)NSMutableArray *viewControllers;
@property (nonatomic,strong)FlagStoreModel *model;
@property (nonatomic,strong)NSMutableDictionary *paramater;
@property (nonatomic,strong)NSMutableArray *storeArray;
@property (nonatomic,strong)NSMutableArray *evaluateArr;
@property (nonatomic,strong)NSArray *otherSpecial;

@end

@implementation FlagshipViewController
#pragma mark - 懒加载
-(UICollectionView *)flagshipView{
    
    if (!_flagshipView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        _flagshipView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight + 64) collectionViewLayout:layout];
        _flagshipView.delegate = self;
        _flagshipView.dataSource = self;
        _flagshipView.backgroundColor = [UIColor clearColor];
    }
    return _flagshipView;
}

-(NSMutableArray *)imageArr{
    
    if (!_imageArr) {
        _imageArr = [NSMutableArray new];
    }
    return _imageArr;
}


-(NSMutableArray *)dataBase{
    
    if (!_dataBase) {
        _dataBase = [NSMutableArray arrayWithObjects:@"discount",@"flag_free",@"flag_cash",@"Membership_card", @"特价",@"免费",@"现金券",@"会员卡",nil];
    }
    return _dataBase;
}


-(NSMutableArray *)viewControllers{
    
    if (!_viewControllers) {
        FlagsSpecialViewController *specialVC = [[FlagsSpecialViewController alloc]init];
        specialVC.cid = self.cid;
        FlagsCoupunViewController *cashDetailVC = [[FlagsCoupunViewController alloc]init];
        cashDetailVC.cid = self.cid;
        FlagsFreeViewController *berserkVC = [[FlagsFreeViewController alloc]init];
        berserkVC.cid = self.cid;
        MemberViewController *memberVC = [[MemberViewController alloc]init];
        memberVC.cid = self.cid;
        _viewControllers = [NSMutableArray arrayWithObjects:specialVC, berserkVC,cashDetailVC,memberVC,nil];
    }
    return _viewControllers;
}

-(NSMutableDictionary *)paramater{
    
    if (!_paramater) {
        _paramater = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.cid,@"cid", nil];
    }
    return _paramater;
}

-(NSMutableArray *)storeArray{
    
    if (!_storeArray) {
        _storeArray = [NSMutableArray new];
    }
    return _storeArray;
}

-(NSMutableArray *)evaluateArr{
    
    if (!_evaluateArr) {
        _evaluateArr = [NSMutableArray new];
    }
    return _evaluateArr;
}
#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // 旗舰店数据
    [self getFlagStoreDetailWithUrl:kFlagDetail paramater:self.paramater];
    // 分店数据
    [self requrestStoreListWithUrl:kStoreListUrl paramater:self.paramater];
    // 评论数据
    // [self.paramater setValue:@(self.cid) forKey:@"cid"];
    // [self requrestEvaluateDataWithUrl:kEvaluateUrl paramater:self.paramater];
    // 本店其他特价
    [self requestOtherSpecialDataWith:kOthers paramater:self.paramater];
    
    [self setUpViews];
    
}


#pragma mark - 自定义
-(void)setUpViews{
    
    self.navigationItem.title = @"旗舰店";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(share:)];
    [self.view addSubview:self.flagshipView];
    [self.flagshipView registerNib:[UINib nibWithNibName:@"flagShipHeadView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"flagShipHeadView"];
    [self.flagshipView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView"];
    [self.flagshipView registerNib:[UINib nibWithNibName:@"flagCell_1" bundle:nil] forCellWithReuseIdentifier:@"flagCell_1"];
    [self.flagshipView registerNib:[UINib nibWithNibName:@"flagCell_2" bundle:nil] forCellWithReuseIdentifier:@"flagCell_2"];
    [self.flagshipView registerNib:[UINib nibWithNibName:@"homeCell_2" bundle:nil] forCellWithReuseIdentifier:@"homeCell_2"];
    [self.flagshipView registerNib:[UINib nibWithNibName:@"specialDetailCell_2" bundle:nil] forCellWithReuseIdentifier:@"specialDetailCell_2"];
    [self.flagshipView registerNib:[UINib nibWithNibName:@"flagCell_3" bundle:nil] forCellWithReuseIdentifier:@"flagCell_3"];
    [self.flagshipView registerNib:[UINib nibWithNibName:@"specialHeadView_1" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"specialHeadView_1"];
    [self.flagshipView registerNib:[UINib nibWithNibName:@"flagCell_4" bundle:nil] forCellWithReuseIdentifier:@"flagCell_4"];
    [self.flagshipView registerNib:[UINib nibWithNibName:@"flagCell_5" bundle:nil] forCellWithReuseIdentifier:@"flagCell_5"];
    [self.flagshipView registerNib:[UINib nibWithNibName:@"flagShipHeadView_1" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"flagShipHeadView_1"];
    [self.flagshipView registerNib:[UINib nibWithNibName:@"specialiDetailCell_7" bundle:nil] forCellWithReuseIdentifier:@"specialiDetailCell_7"];
    [self.flagshipView registerNib:[UINib nibWithNibName:@"specialDetailCell_6" bundle:nil] forCellWithReuseIdentifier:@"specialDetailCell_6"];
    [self.flagshipView registerNib:[UINib nibWithNibName:@"RecommendCell" bundle:nil] forCellWithReuseIdentifier:@"RecommendCell"];
    
    
}

-(void)share:(UIBarButtonItem *)sender{
    
    [[BHJTools sharedTools]showShareView];
}

//旗舰店详情
-(void)getFlagStoreDetailWithUrl:(NSString *)url paramater:(NSDictionary *)paramater{
    
    [[BHJNetWorkTools sharedNetworkTool]loadDataInfoPost:url parameters:paramater success:^(id  _Nullable responseObject) {
        
        self.model = [FlagStoreModel mj_objectWithKeyValues:responseObject];
        if (self.model.shop_images.count > 0) {
            for (NSDictionary *imageDic in self.model.shop_images) {
                [self.imageArr addObject:imageDic[@"image_url"]];
            }
        }
        [self.flagshipView reloadData];
    } failure:^(NSError * _Nullable error) {
        
    }];
}

//关注旗舰店
-(void)focuseStoreWithUrl:(NSString *)url paramater:(NSDictionary *)paramater{
    
    AFHTTPSessionManager *mannager = [AFHTTPSessionManager manager];
    mannager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [mannager POST:url parameters:paramater progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if ([dic[@"status"] integerValue] == 200) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = dic[@"message"];
            UIButton *button = [self.view viewWithTag:1000];
            [button setTitle:@"已关注" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithHexString:@"#bebebe"] forState:UIControlStateNormal];
            [button setImage:nil forState:UIControlStateNormal];
            button.borderColor = [UIColor colorWithHexString:@"#bebebe"];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [self.flagshipView reloadData];
            [hud hideAnimated:YES afterDelay:1.5];
        }
        NSLog(@"请求成功");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
    }];
}

//旗舰店分店列表
-(void)requrestStoreListWithUrl:(NSString *)url paramater:(NSDictionary *)paramater{
    
    [[BHJNetWorkTools sharedNetworkTool]loadDataInfoPost:url parameters:paramater success:^(id  _Nullable responseObject) {
        self.storeArray = [FlagStoreModel mj_objectArrayWithKeyValuesArray:responseObject];
        [self.flagshipView reloadData];
    } failure:^(NSError * _Nullable error) {
        
    }];
}

//旗舰店评价列表
-(void)requrestEvaluateDataWithUrl:(NSString *)url paramater:(NSDictionary *)paramater{
    
    [[BHJNetWorkTools sharedNetworkTool]loadDataInfoPost:url parameters:paramater success:^(id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        
    } failure:^(NSError * _Nullable error) {
        
    }];
}
//本店其他特价
-(void)requestOtherSpecialDataWith:(NSString *)url paramater:(NSDictionary *)paramater{
    
    WeakSelf(weakself);
    [[BHJNetWorkTools sharedNetworkTool]loadDataInfoPost:url parameters:paramater success:^(id  _Nullable responseObject) {
        
        weakself.otherSpecial = [SpecialModel mj_objectArrayWithKeyValuesArray:responseObject];
        [weakself.flagshipView reloadData];
    } failure:^(NSError * _Nullable error) {
        
    }];
}
#pragma mark - UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 4;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 0;
    }else if (section == 2){
        return 4;
    }else if (section == 3){
        return self.otherSpecial.count;
    }
    return 3;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            flagCell_1 *cell_1 = [collectionView dequeueReusableCellWithReuseIdentifier:@"flagCell_1" forIndexPath:indexPath];
            cell_1.address.text = self.model.address;
            return cell_1;
        }else {
            flagCell_2 *cell_2 = [collectionView dequeueReusableCellWithReuseIdentifier:@"flagCell_2" forIndexPath:indexPath];
            cell_2.phoneNum.text = self.model.tel;
            cell_2.lineLabel.hidden = NO;
            if (indexPath.row == 2) {
                cell_2.phoneNum.text = [NSString stringWithFormat:@"查看全部%ld家分店",self.storeArray.count];
                cell_2.ringhtView.image = [UIImage imageNamed:@"right_arrow"];
                cell_2.height.constant = 10;
                cell_2.lineLabel.hidden = YES;
            }
            return cell_2;
        }
    }else if (indexPath.section == 2){
        flagCell_3 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"flagCell_3" forIndexPath:indexPath];
        cell.image.image = [[UIImage imageNamed:self.dataBase[indexPath.row]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        cell.themeLabel.text = self.dataBase[indexPath.row + 4];
        return cell;
    }else if (indexPath.section == 3){
        RecommendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RecommendCell" forIndexPath:indexPath];
        cell.markLabel.text = @"已售 1022";
        cell.model = self.otherSpecial[indexPath.row];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, kScreenHeight / 15, 38)];
        if (indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 0) {
            imageView.image = [[UIImage imageNamed:@"taocan"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }else{
            imageView.image = [[UIImage imageNamed:@"yuyue"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        [cell addSubview:imageView];
        return cell;
    }else {
        flagCell_5 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"flagCell_5" forIndexPath:indexPath];
        return cell;
    }
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    if (section == 2) {
        return 5.5;
    }
    return 0;
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 1;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        return CGSizeMake(kScreenWidth, 38);
    }else if (indexPath.section == 2){
        return CGSizeMake((kScreenWidth - 36.5) / 4, 90);
    }else if (indexPath.section == 3){
        return CGSizeMake(kScreenWidth, 95);
    }
    return CGSizeMake(kScreenWidth, 38);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    if (section == 1 || section == 3) {
        return UIEdgeInsetsMake(1, 0, 10, 0);
    }else if (section == 2){
        return UIEdgeInsetsMake(0, 10, 10, 10);
    }
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    if (section == 2) {
        return CGSizeMake(0, 0);
    }else if (section == 0){
        return CGSizeMake(kScreenWidth, 150);
    }else if (section == 1){
        return CGSizeMake(kScreenWidth, 120);
    }
    return CGSizeMake(kScreenWidth, 38);
}


-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        UICollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView" forIndexPath:indexPath];
        for (UIView *view in headView.subviews) {
            [view removeFromSuperview];
        }
        SDCycleScrollView *scrollView = [[SDCycleScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 150)];
        scrollView.imageURLStringsGroup = self.imageArr;
        [headView addSubview:scrollView];
        return headView;
    }else if (indexPath.section == 1){
        flagShipHeadView *headView_1 = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"flagShipHeadView" forIndexPath:indexPath];
        headView_1.delegate = self;
        headView_1.viewController = self;
        headView_1.indexPath = indexPath;
        headView_1.followBtn.tag = 1000;
        headView_1.model = self.model;
        return headView_1;
    }else if (indexPath.section == 3){
        flagShipHeadView_1 *headView_1 = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"flagShipHeadView_1" forIndexPath:indexPath];
        headView_1.delegate = self;
        headView_1.viewController = self;
        headView_1.indexPath = indexPath;
        headView_1.rightBtn.tag = 1005;
        headView_1.rightBtn.hidden = YES;
        headView_1.themeLabel.text = @"本店其他特价";
        return headView_1;
    }else{
        specialHeadView_1 *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"specialHeadView_1" forIndexPath:indexPath];
        headView.delegate = self;
        headView.viewController = self;
        headView.rightBtn.tag = 1001;
        headView.indexPath = indexPath;
        headView.rightBtn.hidden = NO;
        headView.themeLabel.textColor = [UIColor colorWithHexString:@"#000000"];
        [headView.rightBtn setImage:[[UIImage imageNamed:@"right_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [headView.themeLabel setFont:[UIFont systemFontOfSize:18]];
        return headView;
    }
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            SearchRouteViewController *searchRouteVC = [[SearchRouteViewController alloc]init];
            [self.navigationController pushViewController:searchRouteVC animated:YES];
        }else if (indexPath.row == 1){
            MHActionSheet *actionSheet = [[MHActionSheet alloc] initSheetWithTitle:nil style:MHSheetStyleDefault itemTitles:@[self.model.tel] distance:kScreenHeight / 5];
            [actionSheet didFinishSelectIndex:^(NSInteger index, NSString *title) {
                NSString *text = [NSString stringWithFormat:@"第%ld行,%@",(long)index, title];
                NSLog(@"%@",text);
            }];
        }else{
            StoreListViewController *storeListVC = [[StoreListViewController alloc]init];
            storeListVC.storeList = self.storeArray;
            [self.navigationController pushViewController:storeListVC animated:YES];
        }
    }else if (indexPath.section == 2){
        [self.navigationController pushViewController:self.viewControllers[indexPath.row] animated:YES];
    }else if (indexPath.section == 3){
        SpecialDetailViewController *detailVC = [[SpecialDetailViewController alloc]init];
        SpecialModel *model = self.otherSpecial[indexPath.row];
        detailVC.lid = model.id;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

#pragma mark - BHJReusableViewDelegate
-(void)BHJReusableViewDelegateMethodWithIndexPath:(NSIndexPath *)indexPath button:(UIButton *)button{
    
    switch (button.tag) {
        case 1000:{
            [self.paramater setValue:user_id forKey:@"userId"];
            [self focuseStoreWithUrl:kFocuseUrl paramater:self.paramater];
        }
            break;
        case 1001:{
            NSLog(@"%@",button.titleLabel.text);
        }
            break;
            
        case 1003:{
            NSLog(@"%@",button.titleLabel.text);
        }
            break;
        case 1004:{
            MoreCouponViewController *moreVC = [[MoreCouponViewController alloc]init];
            [self.navigationController pushViewController:moreVC animated:YES];
        }
            break;
        case 1005:{
            
        }
            break;
            
        default:
            break;
    }
}





@end
