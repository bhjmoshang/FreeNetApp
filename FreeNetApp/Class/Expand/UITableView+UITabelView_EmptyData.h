//
//  UITableView+UITabelView_EmptyData.h
//  BHJSliderDemo
//
//  Created by xalo on 16/4/22.
//  Copyright © 2016年 baihuajun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (UITabelView_EmptyData)

// 根据数据源的个数来判断tableView的显示内容
-(NSInteger)showMessage:(NSString *)title byDataSourceCount:(NSInteger)count;


/*
 界面无数据时的布局
 image  无数据时显示的图片
 title  提示语
 str    按钮标题
 content 提示更多信息
 selector 按钮的回调方法
 frame 图片frame ,其他控件根据图片的frame布局
 按钮和subTitle标题为空时隐藏
 @param count 数据源所包含数据个数
 @return 返回数据源所包含数据个数
 */
-(NSInteger)showViewWithImage:(NSString *)imageName alerttitle:(NSString *)title buttonTitle:(NSString *)btnStr subContent:(NSString *)subContent selectore:(SEL)selector
                   imageFrame:(CGRect)frame byDataSourceCount:(NSInteger)count;


@end
