//
//  VerificationCodeView.h
//  学习支付框
//
//  Created by 范奇 on 2017/5/16.
//  Copyright © 2017年 范奇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerificationCodeView : UIView

//多少位验证码
@property (nonatomic, assign) NSInteger codeNum;

@property (nonatomic, strong) UIColor *selectColor;

@property (nonatomic, strong) UIColor *normolColor;

@property (nonatomic, strong) UIColor *selectTextColor;

@property (nonatomic, strong) UIColor *tinColor;

@property (nonatomic, strong) UIFont *textFont;

//当前是否选中
@property (nonatomic, assign) BOOL codeView_IsFirstResponder;

//输入完成的block
@property (nonatomic, copy) void(^completeBlock)(NSString *completeStr);

//输入完成又删除一个的回调
@property (nonatomic, copy) void(^deleteBlock)();

//当前是否显示黑色小球的样式
@property (nonatomic, assign) BOOL mineSecureTextEntry;

//是否需要选中效果
@property (nonatomic, assign) BOOL isSelectStatus;

//是否需要验证码样式
@property (nonatomic, assign) BOOL isCodeViewStatus;

@end
