//
//  CashDetailViewController.h
//  FreeNetApp
//
//  Created by 白华君 on 2016/12/22.
//  Copyright © 2016年 BHJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CashCouponModel.h"

@interface CashDetailViewController : BHJViewController

@property (nonatomic,strong)NSNumber *searchId;
@property (nonatomic,strong)CashCouponModel *model;

@end
