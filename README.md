# FQ_CodeTextView

#### .前言
**最简单的方式实现:支付宝的密码输入框.以及常规的验证码输入框**

**先上效果图**
![验证码输入框.gif](http://upload-images.jianshu.io/upload_images/2100495-df400870a5f8ba33.gif?imageMogr2/auto-orient/strip)

**提供的demo有两套思路:**
1.使用UIKeyInput协议做的文本控件开发
2.使用多个UITextField协同操作

#### .思路1.
##### 1.首先声明一个类继承自UiView.
`@interface FQ_TextView : UIView<UIKeyInput,UITextInputTraits> //前者自定义响应键盘的文本view.后者定义键盘样式 `

##### .并且声明几个常用类型
`//验证码个数
@property (nonatomic, assign) NSInteger number;
//输入完成的block
@property (nonatomic, copy) void(^completeBlock)();
//当前是否显示黑色小球的样式
@property (nonatomic, assign) BOOL mineSecureTextEntry;
//是否需要选中效果
@property (nonatomic, assign) BOOL isSelectStatus;`

##### 3.UIBezierPath曲线画外框的线

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
**获得外部的框:**

![Pasted Graphic 1.tiff.jpg](http://upload-images.jianshu.io/upload_images/2100495-80ee87f8cea59c2a.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### 4.实现UIKeyInput协议方法
    - (BOOL)hasText
    {
    return self.textTot.length > 0;
    }


**键盘上每输入一个字符就会调用.主要是获取键盘输入的字符.在这里做处理**
    - (void)insertText:(NSString *)text
    {

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

**键盘上删除按钮的回调**
    - (void)deleteBackward
    {
    if (self.textTot.length == 0) {
        return;
    }
    [self.textTot deleteCharactersInRange:NSMakeRange(self.textTot.length - 1, 1)];
    [self uploadTextLineViewWithInex:self.textTot.length];
    [self setNeedsDisplay];
    }


**当然还需要注意:默认不会成为第一响应者.需要重写canBecomeFirstResponder方法获取资格**

    -(BOOL)canBecomeFirstResponder
     {
      return YES;
      }


#####5.绘制出用户输入的文本

     - (void)drawRect:(CGRect)rect {
    
    //设置当前绘制颜色
    [[UIColor blackColor] set];
    //加密样式.
    if (self.mineSecureTextEntry) {
        
        for (int i = 0; i < self.textTot.length; ++i) {
            
            UIImage * img = [UIImage imageNamed:@"code_黑点"];
            CGSize size = img.size;
            CGRect rect = CGRectMake(i * self.sizeW + self.sizeW * 0.5 - img.size.width * 0.5 , textViewH * 0.5 -size.height * 0.5, img.size.width, img.size.height);
            [img drawInRect:rect];
        }
        
    }else{//非加密样式
        
        for (int i = 0; i < self.textTot.length; ++i) {
            NSString * string = [self.textTot substringWithRange:NSMakeRange(i, 1)];
            
            CGSize size = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]} context:nil].size;
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
            style.alignment = NSTextAlignmentCenter;
            
            CGRect rect = CGRectMake(i * self.sizeW, textViewH * 0.5 -size.height * 0.5, self.sizeW, textViewH);
            //这里需要强调一下.文本只能水平居中.所以竖直居中需要自己计算
            [string drawInRect:rect withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18],NSParagraphStyleAttributeName:style}];
        }
        
    }
    }
##### 6.添加选中效果

**添加一个CAShapeLayer属性.**

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
**更新其路径值即可.这样就会覆盖显示出来**

    -(void)uploadTextLineViewWithInex: (NSInteger)index
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


**到这里一个支付宝密码的输入框大致已经完成.是不是超级简单.只需要处理一点细节即可.我在demo中已经添加了选中样式.其他的边框颜色文字颜色等大家自定义即可**

#### .思路2.
###### **来源**:看到某个App使用的是有光标的验证码输入框.所以想通过以上方式来添加光标.但是没有找到相应的资料.所以采用的最直男的方式:

**创建多个UITextField,这个看似没有什么好讲的.确实是一个体力活.但里面还是有一些坑**

##### 1.首先声明一个类继承自UiView

##### 23.同上

##### 4.整体---局部---整体
###### **整体:**因为是多个控件组合而成.为了外部方便调用.所以准备了两个方法.整体的成为或辞去第一响应者

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

###### 局部:UITextField之间的切换.我们使用单个控件成为第一响应或辞去第一响应.

       //单个控件成为第一响应者
        - (void)codeViewBecomeFirstResponderWithTag:(NSInteger)tag
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

###### 整体:都是UITextField.所以订阅一个文本更改的通知
`[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changTextFieldTextNotification) name:UITextFieldTextDidChangeNotification object:nil];`

**可以统一使用这个通知做"无文本->有文本"的事情.
为什么说是增加的事情.因为UIKeyboardTypeNumberPad类型的键盘.如果文本框没有文本.我们点击删除按钮.不会收到该通知.**

**既然这样?**
**那么删除文本框怎么操作呢?**

**看到一个伙伴的实现方式:每个UITextField选中的时候添加一个@“ “空字符.这样删除的时候.就能监听到通知.这样也能实现**

**我采取的方式是粗暴的:直接在键盘的删除按钮上添加一个删除按钮.取代它.**

![Pasted Graphic 2.tiff.jpg](http://upload-images.jianshu.io/upload_images/2100495-4dd4b835e35d73db.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
######监听键盘即将出现的通知.
`      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOnDelay:) name:UIKeyboardWillShowNotification object:nil];`

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

**有创建.就需要删除.否则当前界面其他输入控件唤起键盘时.也会触发通知.就会有问题**
        - (void)removeXButtonFromKeyBoard
        {
            [self.deleteBtn removeFromSuperview];
            self.deleteBtn.hidden = YES;
            self.deleteBtn = nil;
        }

**所以在整体成为第一响应者的时候注册通知.辞去第一响应的时候注销通知**

##### 点击删除按钮的响应事件.

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

##### 5.本控件与外部的整体交互:

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

**如果是本控件的点击.那么可以很轻松的自己设定为成为或辞去第一响应.**
**但有一种情况.当我点击了别的输入文本时.本控件会辞去第一响应.这个只能使用UITextField的代理.即UITextField结束时调用.**
**但是局部的UITextField也会有辞去第一响应的时候.
所以此处我使用一个比较low的方法.即找规律.**

***如果是本控件自己辞去第一响应.那么`textFieldShouldEndEditing`会调用2次-> 再调`textFieldDidEndEditing`1次.
如果是点击其他输入框辞去的第一响应.那么`textFieldShouldEndEditing`会调用1次-> 再调`textFieldDidEndEditing`1次.***

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

##### 6.添加选中效果同上.

**至此第二种思路也已经完成.能获取到光标.实现的方式真的很多.如果有时间自己实现和把人家的代码照搬过来.自己会理解的更透彻**

###### 谢谢:[iOS 简易文本控件开发（UIKeyInput协议学习）](http://www.cnblogs.com/mzdbskipop/p/3203556.html)

###### 谢谢:[iOS开发：自定义数字键盘（两种方式）](http://blog.csdn.net/u012234115/article/details/51644322)

###### .希望对你有帮助:https://github.com/FQDEVER/FQ_CodeTextView



