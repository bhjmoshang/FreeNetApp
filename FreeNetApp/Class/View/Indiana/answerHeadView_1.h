//
//  answerHeadView_1.h
//  FreeNetApp
//
//  Created by 白华君 on 2016/12/17.
//  Copyright © 2016年 BHJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface answerHeadView_1 : UIView

@property (weak, nonatomic) IBOutlet UIImageView *user_head;
@property (weak, nonatomic) IBOutlet UIImageView *markView;
@property (weak, nonatomic) IBOutlet UIImageView *user_level;
@property (weak, nonatomic) IBOutlet UILabel *user_name;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;


+(answerHeadView_1 *)shareAnswerHeadView_1;

@end
