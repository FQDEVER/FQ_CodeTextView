//
//  VerificationCodeView.m
//  学习支付框
//
//  Created by 范奇 on 2017/5/16.
//  Copyright © 2017年 范奇. All rights reserved.
//

#import "VerificationCodeView.h"
#define     textViewW  self.bounds.size.width
#define     textViewH  self.bounds.size.height
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height
#define DELETEBUTTONTAG 20000

@interface VerificationCodeView ()<UITextFieldDelegate>

//记录当前选中的tag值
@property (nonatomic, assign) NSInteger seletTag;

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) CAShapeLayer * selectLayer;

@property (nonatomic, assign) CGFloat sizeW;

@property (nonatomic, assign) NSInteger flogIndex;//记录是否跳转到其他的编辑文本上面

@end

@implementation VerificationCodeView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.seletTag = 1;
        [self creatTextField];
        [self addTextLineView];
        self.sizeW = self.bounds.size.width * 1.0f / self.codeNum;
        self.isSelectStatus = YES; //默认是需要的
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changTextFieldTextNotification) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}



        #pragma mark ==========自定义键盘.================

        -(void)keyboardWillShowOnDelay:(NSNotification *)notification {
            [self performSelector:@selector(keyboardWillShow:) withObject:nil afterDelay:0.1];
        }

        - (void)keyboardWillShow:(NSNotification *)notification {
            
            NSUInteger cnt = [UIApplication sharedApplication].windows.count;
            UIWindow *keyboardWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:cnt - 1];
            if (!self.deleteBtn.superview) {
                [keyboardWindow addSubview:self.deleteBtn];
                [keyboardWindow bringSubviewToFront:self.deleteBtn];
            }
        }

        - (void)removeXButtonFromKeyBoard
        {
            [self.deleteBtn removeFromSuperview];
            self.deleteBtn.hidden = YES;
            self.deleteBtn = nil;
        }



#pragma mark =========UITextField代理=================

//如果从本控件直接辞去第一响应.转到别的控件上时.无法获取.
//通过查找规律正常点击该控件辞去的响应会调两次
//通过点击其他控件辞去响应的方式调用一次
//所以在这里使用标记的方式
        - (BOOL)textFieldShouldEndEditing:(UITextField *)textField
        {
            self.flogIndex ++;
            return YES;
        }

        - (void)textFieldDidEndEditing:(UITextField *)textField
        {
            
            if (self.flogIndex == 2) {
                //那么是正常退出.不用理会
            }else if(self.flogIndex == 1)
            {
                //点击转到其他编辑文本的辞去第一响应.应该要删除删除按钮
                NSLog(@"===========self.selectTag %zd",self.seletTag);
                self.codeView_IsFirstResponder = NO;
                [self codeView_ResignFirstResponder];
            }
        }


#pragma mark ==================响应事件================

-(void)changTextFieldTextNotification
{
    NSLog(@"=增加=====12345555");
    UITextField *textField = [self viewWithTag:self.seletTag];
    
    if (textField.text.length == 1) {
        
        if (self.seletTag == self.codeNum) {
            
            [self codeView_ResignFirstResponder];
            if (_completeBlock) {
                _completeBlock(textField.text);
            }
            
        }else{
            [self codeViewResignFirstResponderWithTag:self.seletTag];
            self.seletTag += 1;
            [self codeViewBecomeFirstResponderWithTag:self.seletTag];
        }
    }else{
        
        if (self.seletTag != 1) {
            [self codeViewResignFirstResponderWithTag:self.seletTag];
            self.seletTag -= 1;
            [self codeViewBecomeFirstResponderWithTag:self.seletTag];
            
        }
    }
}


        -(void)DeleteButtonDidTouch:(UIButton *)btn
        {
            NSLog(@"=删除=====12345555");
            if (self.seletTag != 1) {
                UITextField *textField = [self viewWithTag:self.seletTag];
                [self codeViewResignFirstResponderWithTag:self.seletTag];
                textField.text = nil;
                self.seletTag -= 1;
                UITextField *selectTextField = [self viewWithTag:self.seletTag];
                selectTextField.text = nil;
                [self codeViewBecomeFirstResponderWithTag:self.seletTag];
            }
        }


        -(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
        {
            if (!self.codeView_IsFirstResponder) {
                UITextField *textField = [self viewWithTag:self.seletTag];
                if (self.codeNum == self.seletTag) {
                    UITextField *textField = [self viewWithTag:self.seletTag];
                    textField.text = nil;
                }
                [self codeView_BecomeFirstResponder];
                textField.enabled = YES;
                [textField becomeFirstResponder];
                
            }else{
                
                [self codeView_ResignFirstResponder];
            }
        }


        //单个控件成为第一响应者
        -(void)codeViewBecomeFirstResponderWithTag:(NSInteger)tag
        {
            self.seletTag = tag;
            [self uploadTextLineViewWithInex:self.seletTag - 1];
            UITextField *textField = [self viewWithTag:self.seletTag];
            textField.enabled = YES;
            [textField becomeFirstResponder];
            
            self.flogIndex = 0;
        }

        //单个控件辞去第一响应者
        -(void)codeViewResignFirstResponderWithTag:(NSInteger)tag
        {
            UITextField *textField = [self viewWithTag:tag];
            textField.enabled = NO;
            [textField resignFirstResponder];
            self.flogIndex = 0;
            
        }


        //整个控件成为第一响应
        -(void)codeView_BecomeFirstResponder
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOnDelay:) name:UIKeyboardWillShowNotification object:nil];
            [self codeViewBecomeFirstResponderWithTag:self.seletTag];
            self.codeView_IsFirstResponder = YES;
        }

        //整个控件辞去第一响应
        -(void)codeView_ResignFirstResponder
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
            //辞去第一响应者
            [self uploadTextLineViewWithInex:1000];
            [self removeXButtonFromKeyBoard];
            [self codeViewResignFirstResponderWithTag:self.seletTag];
            self.codeView_IsFirstResponder = NO;
        }




//设置选中状态
-(void)setIsSelectStatus:(BOOL)isSelectStatus
{
    _isSelectStatus = isSelectStatus;
    if (self.isSelectStatus) {
        [self addTextLineViewSelectLayer];
    }else{
        [self.selectLayer removeFromSuperlayer];
        self.selectLayer = nil;
    }
}

//设置文本显示状态
-(void)setMineSecureTextEntry:(BOOL)mineSecureTextEntry
{
    _mineSecureTextEntry = mineSecureTextEntry;
    for (int i = 0; i < self.codeNum; ++i) {
        UITextField *textField = [self viewWithTag:i + 1];
        textField.secureTextEntry = self.mineSecureTextEntry;
    }
}


#pragma mark ================初始化控件==================

-(void)addTextLineViewSelectLayer
{
    
    CAShapeLayer * layer = [[CAShapeLayer alloc]init];
    
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor redColor].CGColor;
    layer.lineJoin = kCALineJoinRound;
    //    layer.path = bezierPath.CGPath;
    layer.frame = self.bounds;
    
    self.selectLayer = layer;
    
    [self.layer addSublayer:self.selectLayer];
    
    [self uploadTextLineViewWithInex:0];
}

-(void)uploadTextLineViewWithInex:(NSInteger)index
{
    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    
    if (index == 1000) {
    }else{
        [bezierPath moveToPoint:CGPointMake(index * self.sizeW, 0)];
        [bezierPath addLineToPoint:CGPointMake((index + 1) * self.sizeW, 0)];
        [bezierPath addLineToPoint:CGPointMake((index + 1) * self.sizeW, textViewH)];
        [bezierPath addLineToPoint:CGPointMake(index * self.sizeW, textViewH)];
        [bezierPath addLineToPoint:CGPointMake(index * self.sizeW, 0)];
    }
    self.selectLayer.path = bezierPath.CGPath;
}


-(void)addTextLineView
{
    
    CGFloat lineW = 1;
    UIColor * lineColor = [UIColor grayColor];
    CGFloat marginW = textViewW * 1.0f / self.codeNum;
    
    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointZero];
    [bezierPath addLineToPoint:CGPointMake(textViewW, 0)];
    [bezierPath addLineToPoint:CGPointMake(textViewW, textViewH)];
    [bezierPath addLineToPoint:CGPointMake(0, textViewH)];
    [bezierPath addLineToPoint:CGPointMake(0, 0)];
    
    for (int i = 1; i < self.codeNum ; ++i) {
        UIBezierPath * bezierPath1 = [UIBezierPath bezierPath];
        [bezierPath1 moveToPoint:CGPointMake(i * marginW, 0)];
        [bezierPath1 addLineToPoint:CGPointMake(i * marginW, textViewH)];
        [bezierPath appendPath:bezierPath1];
    }
    
    CAShapeLayer * layer = [[CAShapeLayer alloc]init];
    layer.borderColor = lineColor.CGColor;
    layer.borderWidth = lineW;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor grayColor].CGColor;
    layer.lineJoin = kCALineJoinRound;
    layer.path = bezierPath.CGPath;
    layer.frame = self.bounds;
    
    [self.layer addSublayer:layer];
}


-(void)creatTextField
{
    self.codeNum = self.codeNum ? self.codeNum : 6;
    
    CGFloat marginW = textViewW * 1.0 / self.codeNum;
    
    for (int i = 0; i < self.codeNum; ++i) {
        UITextField * textField = [self getTextFieldWithFrame:CGRectMake(i * marginW, 0, marginW, textViewH) andTag:i + 1];
        [self addSubview:textField];
    }
    
    [self codeView_BecomeFirstResponder];
}


-(UITextField *)getTextFieldWithFrame:(CGRect)frame andTag:(NSInteger)tag
{
    
    UITextField * textField = [[UITextField alloc]initWithFrame:frame];
    textField.clearButtonMode = UITextFieldViewModeNever;
    textField.backgroundColor = [UIColor whiteColor];
    textField.tintColor = [UIColor redColor];
    textField.borderStyle = UITextBorderStyleNone;
    textField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, textViewW / self.codeNum * 0.5, 0)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.delegate = self;
    textField.tag = tag;
    textField.enabled = NO;
    
    return textField;
}

-(UIButton *)deleteBtn
{
    if (!_deleteBtn) {
        // 删除按钮
        CGFloat keyboardH = 226;
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(ScreenW * 2 / 3.0, ScreenH - keyboardH * 0.25 , ScreenW / 3.0, keyboardH * 0.25);
        _deleteBtn.backgroundColor = [UIColor clearColor];
        _deleteBtn.tag = DELETEBUTTONTAG;
        [_deleteBtn addTarget:self action:@selector(DeleteButtonDidTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}



@end
