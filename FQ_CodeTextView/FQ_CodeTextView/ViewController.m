//
//  ViewController.m
//  FQ_CodeTextView
//
//  Created by 范奇 on 2017/5/18.
//  Copyright © 2017年 范奇. All rights reserved.
//


#import "ViewController.h"

#import "FQ_CodeTextView.h"
#import "VerificationCodeView.h"

@interface ViewController ()
@property (nonatomic, strong) FQ_CodeTextView *textView;
@property (nonatomic, strong) VerificationCodeView *codeView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.textView = [[FQ_CodeTextView alloc]initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 50)];
    self.textView.isSelectStatus = YES;
    
    
    self.codeView = [[VerificationCodeView alloc]initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 50)];
    self.codeView.isCodeViewStatus = NO;
    self.codeView.mineSecureTextEntry = NO;
    self.codeView.isSelectStatus = YES;
    [self.view addSubview:self.textView];
    [self.view addSubview:self.codeView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
