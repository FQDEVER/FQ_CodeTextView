//
//  FQ_TextView.h
//  学习支付框
//
//  Created by 范奇 on 2017/5/16.
//  Copyright © 2017年 范奇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FQ_CodeTextView : UIView<UIKeyInput,UITextInputTraits> //前者自定义响应键盘的文本view.后者定义键盘样式

//几位验证码
@property (nonatomic, assign) NSInteger number;

//输入完成的block
@property (nonatomic, copy) void(^completeBlock)();

//输入完成又删除一个的回调
@property (nonatomic, copy) void(^deleteBlock)();

//当前是否显示黑色小球的样式
@property (nonatomic, assign) BOOL mineSecureTextEntry;
//是否需要选中效果
@property (nonatomic, assign) BOOL isSelectStatus;

@end
