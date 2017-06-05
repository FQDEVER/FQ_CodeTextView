//
//  CodeViewTextField.m
//  FQ_CodeTextView
//
//  Created by 范奇 on 2017/5/19.
//  Copyright © 2017年 范奇. All rights reserved.
//

#import "CodeViewTextField.h"

@interface CodeViewTextField ()

@property (nonatomic, strong) UIImageView *backImgView;

@end

@implementation CodeViewTextField


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setupView];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self setupView];
    }
    return self;
}

-(void)setupView
{
    CGFloat minWH = MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    CGFloat maxWH = MAX(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    CGFloat imgX = (maxWH - minWH)*0.5;
    self.backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(imgX, 0,minWH, minWH)];
    self.backImgView.image = [UIImage imageNamed:@"input_Number_nor"];
    [self addSubview:self.backImgView];
    [self sendSubviewToBack:self.backImgView];
}

-(void)setIsCodeView:(BOOL)isCodeView
{
    _isCodeView = isCodeView;
    self.backImgView.hidden = !isCodeView;
}

-(BOOL)resignFirstResponder
{
    self.backImgView.image = [UIImage imageNamed:@"input_Number_nor"];
    
    return [super resignFirstResponder];
}


-(BOOL)becomeFirstResponder
{
    self.backImgView.image = [UIImage imageNamed:@"input_Number_sel"];
    
    return [super becomeFirstResponder];
}




@end
