//
//  FQ_TextView.m
//  学习支付框
//
//  Created by 范奇 on 2017/5/16.
//  Copyright © 2017年 范奇. All rights reserved.
//

#import "FQ_TextView.h"

#define     textViewW  self.bounds.size.width
#define     textViewH  self.bounds.size.height
#define     lineW  1


@interface FQ_TextView ()

@property (nonatomic, strong) UIColor *textColor;

@property (strong, nonatomic) UIColor *lineColor;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) NSMutableString  * textTot ;

@property (nonatomic, assign) CGFloat sizeW;

@property (nonatomic, strong) CAShapeLayer * selectLayer;

@end


@implementation FQ_TextView


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.lineColor = [UIColor redColor];
        self.textColor = [UIColor blackColor];
        self.font = [UIFont systemFontOfSize:14];
        self.textTot = [NSMutableString stringWithFormat:@""];
        self.number = self.number ? self.number : 6;
        self.sizeW = self.bounds.size.width * 1.0f / self.number;
        self.mineSecureTextEntry = YES;//默认是黑球样式
        [self addTextLineView];
        self.isSelectStatus = YES; //默认是需要的
    }
    return self;
}


-(void)addTextLineView
{
    UIColor * lineColor = [UIColor grayColor];
    
    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointZero];
    [bezierPath addLineToPoint:CGPointMake(textViewW, 0)];
    [bezierPath addLineToPoint:CGPointMake(textViewW, textViewH)];
    [bezierPath addLineToPoint:CGPointMake(0, textViewH)];
    [bezierPath addLineToPoint:CGPointMake(0, 0)];
    
    for (int i = 1; i < self.number ; ++i) {
        UIBezierPath * bezierPath1 = [UIBezierPath bezierPath];
        [bezierPath1 moveToPoint:CGPointMake(i * self.sizeW, 0)];
        [bezierPath1 addLineToPoint:CGPointMake(i * self.sizeW, textViewH)];
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

-(void)addTextLineViewSelectLayer
{
    
    CAShapeLayer * layer = [[CAShapeLayer alloc]init];
    
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor redColor].CGColor;
    layer.lineJoin = kCALineJoinRound;
    layer.frame = self.bounds;
    
    self.selectLayer = layer;
    
    [self.layer addSublayer:self.selectLayer];
    
}


#pragma mark ----------------更新状态==================

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

-(BOOL)becomeFirstResponder
{
    if ([super becomeFirstResponder]) {
        if (self.textTot.length == self.number) {
            [self uploadTextLineViewWithInex:self.number - 1];
        }else{
            [self uploadTextLineViewWithInex:self.textTot.length];
        }
    }
    return  [super becomeFirstResponder];
}

-(BOOL)resignFirstResponder
{
    if ([super resignFirstResponder]) {
        [self uploadTextLineViewWithInex:1000];
    }
    return [super resignFirstResponder];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (![self isFirstResponder]) {
        [self becomeFirstResponder];
    }else{
        [self resignFirstResponder];
    }
}

#pragma mark ===============UIKeyInput协议方法=================

- (BOOL)hasText
{
    return self.textTot.length > 0;
}

//插入一个新的字符串时调用
- (void)insertText:(NSString *)text
{
    NSLog(@"============%zd,self.number%zd",self.textTot.length,self.number);
    
    if (self.textTot.length == self.number) { //已经是最长
        return;
    }
    
    [self.textTot appendString:text];
    [self uploadTextLineViewWithInex:self.textTot.length];
    [self setNeedsDisplay];
    
    if (self.textTot.length == self.number) {
        
        if (_completeBlock) {
            _completeBlock();
        }
        [self resignFirstResponder];
        return;
    }
    
}

- (void)deleteBackward
{
    if (self.textTot.length == 0) {
        return;
    }
    
    [self.textTot deleteCharactersInRange:NSMakeRange(self.textTot.length - 1, 1)];
    [self uploadTextLineViewWithInex:self.textTot.length];
    [self setNeedsDisplay];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark ============ 绘制 =====================


- (void)drawRect:(CGRect)rect {
    
    NSLog(@"======%@",self.textTot);
    //设置当前绘制颜色
    [[UIColor blackColor] set];
    
    if (self.mineSecureTextEntry) {
        
        for (int i = 0; i < self.textTot.length; ++i) {
            
            UIImage * img = [UIImage imageNamed:@"code_黑点"];
            CGSize size = img.size;
            CGRect rect = CGRectMake(i * self.sizeW + self.sizeW * 0.5 - img.size.width * 0.5 , textViewH * 0.5 -size.height * 0.5, img.size.width, img.size.height);
            [img drawInRect:rect];
        }
        
    }else{
        
        for (int i = 0; i < self.textTot.length; ++i) {
            NSString * string = [self.textTot substringWithRange:NSMakeRange(i, 1)];
            
            CGSize size = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]} context:nil].size;
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
            style.alignment = NSTextAlignmentCenter;
            
            CGRect rect = CGRectMake(i * self.sizeW, textViewH * 0.5 -size.height * 0.5, self.sizeW, textViewH);
            
            [string drawInRect:rect withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18],NSParagraphStyleAttributeName:style}];
        }
        
    }
}

#pragma mark ================UITextInputTraits协议==============

-(UIKeyboardType)keyboardType
{
    return UIKeyboardTypeNumberPad;
}


@end
