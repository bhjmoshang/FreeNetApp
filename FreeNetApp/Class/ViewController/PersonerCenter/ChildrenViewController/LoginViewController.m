//
//  LoginViewController.m
//  FreeNetApp
//
//  Created by 白华君 on 2016/11/12.
//  Copyright © 2016年 BHJ. All rights reserved.
//

#import "LoginViewController.h"
#import "PersonerViewController.h"
#import "RegisterViewController.h"
#import "FindPWDViewController.h"

@interface LoginViewController ()<CAAnimationDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *regesiterBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *qqLoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *webChatLoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *sinaLoginBtn;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIButton *findPWDBtn;
@property (weak, nonatomic) IBOutlet UILabel *thirdLoginLabel;
@property (weak, nonatomic) IBOutlet UIImageView *user_image;
@property (weak, nonatomic) IBOutlet UITextField *user_nameTF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (weak, nonatomic) IBOutlet UIImageView *keyImage;


@end

@implementation LoginViewController
#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"登录";
    self.navigationItem.hidesBackButton = YES;
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.user_nameTF.delegate = self;
    
}

-(void)back:(UIBarButtonItem *)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 登录
- (IBAction)loginAction:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    if (!self.user_nameTF.text.length || self.user_nameTF.text.length != 11) {
        
        [ShowMessage showMessage:@"手机号码错误" duration:3];
        return;
    }
    if (!self.pwdTF.text.length) {
        
        [ShowMessage showMessage:@"密码不能为空" duration:3];
        return;
    }
    [self loginProjectWithURL:API_URL(@"/sso/users/signin")];
}



#pragma mark - 注册
- (IBAction)regesiterAction:(UIButton *)sender {
    
    RegisterViewController *registerVC = [[RegisterViewController alloc]init];
    [self.navigationController pushViewController:registerVC animated:YES];
}



#pragma mark - QQ
- (IBAction)QQLoginAction:(UIButton *)sender {
    
    [self getUserInfoForPlatform:UMSocialPlatformType_QQ];
}



#pragma mark - 微信
- (IBAction)WebChatLoginAction:(UIButton *)sender {
    
    [self getUserInfoForPlatform:UMSocialPlatformType_WechatSession];
}



#pragma mark - 微博
- (IBAction)SinaWeiboLoginAction:(UIButton *)sender {
    
    [self getUserInfoForPlatform:UMSocialPlatformType_Sina];
}



#pragma mark - 忘记密码
- (IBAction)findPwdAction:(UIButton *)sender {
    
    FindPWDViewController *findPwdVC = [[FindPWDViewController alloc]init];
    [self.navigationController pushViewController:findPwdVC animated:YES];
}



#pragma mark - 第三方登录
- (void)getUserInfoForPlatform:(UMSocialPlatformType)platformType
{
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformType currentViewController:nil completion:^(id result, NSError *error) {
        
        NSLog(@"%@",error);
        UMSocialUserInfoResponse *resp = result;
        
        // 第三方登录数据(为空表示平台未提供)
        // 授权数据
        NSLog(@" uid: %@", resp.uid);
        NSLog(@" openid: %@", resp.openid);
        NSLog(@" accessToken: %@", resp.accessToken);
        NSLog(@" refreshToken: %@", resp.refreshToken);
        NSLog(@" expiration: %@", resp.expiration);
        
        // 用户数据
        NSLog(@" name: %@", resp.name);
        NSLog(@" iconurl: %@", resp.iconurl);
        NSLog(@" gender: %@", resp.gender);
    }];
}



#pragma mark - 登录响应事件
-(void)loginProjectWithURL:(NSString *)url{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    [parameter setValue:self.user_nameTF.text forKey:@"mobile"];
    [parameter setValue:self.pwdTF.text forKey:@"pwd"];
    NSLog(@"%@",parameter);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingAllowFragments) error:nil];
        NSDictionary *dataDic = result[@"data"];
        
        NSLog(@"%@",result);
        
        if ([result[@"status"] intValue] == 200) {
            
            [[NSUserDefaults standardUserDefaults]setValue:dataDic[@"token"] forKey:@"user_token"];
            [[NSUserDefaults standardUserDefaults]setValue:dataDic[@"user"][@"id"] forKey:@"user_id"];
            [[NSUserDefaults standardUserDefaults]setValue:dataDic[@"user"][@"mobile"] forKey:@"user_mobile"];
            [[NSUserDefaults standardUserDefaults]setValue:dataDic[@"user"][@"avatar_url"] forKey:@"user_avatar_url"];
            [[NSUserDefaults standardUserDefaults]setValue:dataDic[@"user"][@"nickname"] forKey:@"user_nickname"];
            [[NSUserDefaults standardUserDefaults]setValue:dataDic[@"user"][@"sex"] forKey:@"user_sex"];
            [[NSUserDefaults standardUserDefaults]setValue:dataDic[@"user"][@"age"] forKey:@"user_age"];
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"user_login"];
            
            NSNotification *singOut = [[NSNotification alloc]initWithName:@"singOut" object:nil userInfo:@{@"isSuccess":@(0)}];
            [[NSNotificationCenter defaultCenter]postNotification:singOut];
            
            PersonerViewController *personalVC = [[PersonerViewController alloc]init];
            [self.navigationController pushViewController:personalVC animated:YES];
            
        }else{
            [ShowMessage showMessage:result[@"message"] duration:3];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [ShowMessage showMessage:@"网络异常" duration:3];
    }];
}

@end
