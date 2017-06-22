//
//  PersonerExchangeViewController.m
//  FreeNetApp
//
//  Created by 白华君 on 2016/11/22.
//  Copyright © 2016年 BHJ. All rights reserved.
//

#import "PersonerExchangeViewController.h"
#import "ExchangeRecordViewController.h"
@interface PersonerExchangeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *exchangeStyle;
@property (weak, nonatomic) IBOutlet UITextField *styleSelected;
@property (weak, nonatomic) IBOutlet UILabel *totalprice;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel; //余额
@property (weak, nonatomic) IBOutlet UITextField *numberSelected;
@property (weak, nonatomic) IBOutlet UILabel *exchangeNum;
@property (weak, nonatomic) IBOutlet UIView *firstView;
@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@end

@implementation PersonerExchangeViewController



#pragma mark - ViewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"充值记录" style:UIBarButtonItemStylePlain target:self action:@selector(exchangeRecord:)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} forState:UIControlStateNormal];
    self.navigationItem.title = @"兑换";
    
    
    [self setViewWithTextField:self.numberSelected imageName:nil anotherImage:nil];
    
    [self setViewFiled:self.styleSelected image:@"drop"];
    
    
    
    //账户余额
    [self accountBalanceWithURL:API_URL(@"/my/balance")];
    
}






#pragma mark - 确认支付
- (IBAction)sureAction:(UIButton *)sender {
    
    self.balanceLabel.text = @"余额不足:  9元";
    self.balanceLabel.textColor = [UIColor whiteColor];
    self.balanceLabel.backgroundColor = [UIColor redColor];
    NSLog(@"兑换");
}

-(void)exchangeRecord:(UIBarButtonItem *)sender{

    [self.navigationController pushViewController:[ExchangeRecordViewController new] animated:YES];
}



#pragma mark - 构造UI
-(void)setViewWithTextField:(UITextField *)textField imageName:(NSString *)imageName anotherImage:(NSString *)image{
    
    UIView *rightView = [[UIView alloc]init];
    rightView.size = CGSizeMake(20, 40);
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBtn setBackgroundImage:[[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]forState:UIControlStateNormal];
    [rightBtn setFrame:CGRectMake(0, 10, 20, 20)];
    [rightView addSubview:rightBtn];
    [rightBtn setTitle:@"+" forState:UIControlStateNormal];
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:22]];
    [rightBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    rightView.contentMode = UIViewContentModeRedraw;
    textField.rightView = rightView;
    textField.rightViewMode = UITextFieldViewModeAlways;
    
    UIView *leftView = [[UIView alloc]init];
    leftView.size = CGSizeMake(20, 40);
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftBtn setBackgroundImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]forState:UIControlStateNormal];
    [leftBtn.titleLabel setFont:[UIFont systemFontOfSize:22]];
    [leftBtn setFrame:CGRectMake(0, 10, 20, 20)];
    [leftView addSubview:leftBtn];
    [leftBtn setTitle:@"-" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(subtractionAction:) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.contentMode = UIViewContentModeRedraw;
    textField.leftView = leftView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

-(void)setViewFiled:(UITextField *)textField image:(NSString *)imageName{

    UIView *rightView = [[UIView alloc]init];
    rightView.size = CGSizeMake(20, 20);
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setBackgroundImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]forState:UIControlStateNormal];
    [rightBtn setFrame:CGRectMake(0, 5, 15, 8)];
    [rightView addSubview:rightBtn];
    [rightBtn addTarget:self action:@selector(dropDown:) forControlEvents:UIControlEventTouchUpInside];
    rightView.contentMode = UIViewContentModeRedraw;
    textField.rightView = rightView;
    textField.rightViewMode = UITextFieldViewModeAlways;
}

-(void)addAction:(UIButton *)sender{
    
    int num = 1000;
    int temp = 1000;
    num += temp;
    self.numberSelected.text = [NSString stringWithFormat:@"%d",num];
}

-(void)subtractionAction:(UIButton *)sender{
    
    int num = 1000;
    int temp = 1000;
    if (num > 1000) {
        num -= temp;
    }else{
        num = 1000;
    }
    self.numberSelected.text = [NSString stringWithFormat:@"%d",num];
}

-(void)dropDown:(UIButton *)sender{

    NSLog(@"下拉");
}



#pragma mark - 数据请求
    //兑换
-(void)exchangeWithURL:(NSString *)url{

    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    [parameter setValue:user_id forKey:@"userId"];
    [parameter setValue:@"" forKey:@"gold"];
    [parameter setValue:@"" forKey:@"coin"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:url parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingAllowFragments) error:nil];
        NSLog(@"%@",result);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [ShowMessage showMessage:@"网络异常" duration:3];
        
    }];
}


    //账户余额
-(void)accountBalanceWithURL:(NSString *)url{

    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    [parameter setValue:user_id forKey:@"userId"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:url parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingAllowFragments) error:nil];
        
        
        NSString *banlance = [NSString stringWithFormat:@"余额:  %@元",result[@"data"][@"gold"]];
//        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:banlance];
//        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5, 3)];
        self.balanceLabel.text = banlance;
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [ShowMessage showMessage:@"网络异常" duration:3];
    }];
}





@end