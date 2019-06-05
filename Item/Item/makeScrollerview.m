//
//  makeScrollerview.m
//  assemble
//
//  Created by qf on 15/8/22.
//  Copyright © 2015年 qf. All rights reserved.
//

#import "makeScrollerview.h"



@interface makeScrollerview()
@property(nonatomic,assign)CGRect ScrollerFrame;
@property(nonatomic,assign)CGRect PageFrame;
@property(nonatomic,strong)NSArray * photoArray;
@property(nonatomic,strong)UIImageView * myImageView;

@property(nonatomic,strong)UIScrollView * myScrollView;
@property(nonatomic,strong)UIPageControl * myPageControl;
@property(nonatomic,strong)NSTimer * timer;
@property(nonatomic,strong)NSTimer * delayTimer;
@property(nonatomic,strong)NSTimer * delayTimer2;
@property(nonatomic,assign)NSInteger n;



@end

@implementation makeScrollerview

-(instancetype)initWithScrollerViewFrame:(CGRect )ScrollerFrame withPageControlFrame:(CGRect )PageFrame withParentView:(UIImageView *)ImageView withPhotoArray:(NSArray *)photoArray
{
    if (self = [super init])
    {
        self.ScrollerFrame = ScrollerFrame;
        self.PageFrame = PageFrame;
        self.myImageView = ImageView;
        self.photoArray = photoArray;
    }
    return self;
}

-(void)CreatScrollerView
{
    [self setMyScrollView];
    [self setScrollTime];
    [self pageControl];
}

-(void)setMyScrollView
{
    self.n = self.photoArray.count;
    self.myScrollView = [[UIScrollView alloc]init];
//    self.myScrollView.frame = self.ScrollerFrame;
    //设置滚动画面尺寸时，注意其与要加载的父视图的相对尺寸问题。
    self.myScrollView.frame = CGRectMake(0, 0, self.ScrollerFrame.size.width, self.ScrollerFrame.size.height);
    self.myScrollView.delegate = self;
    self.myScrollView.backgroundColor = [UIColor grayColor];
    [self.myImageView addSubview:self.myScrollView];
    self.myImageView.userInteractionEnabled = YES;
    
    NSMutableArray * photoArray1 = [[NSMutableArray alloc]initWithArray:self.photoArray];
    //在第一章图片前插入最后一张图片
    [photoArray1 insertObject:self.photoArray[self.n - 1] atIndex:0];
    
    [photoArray1 addObject:self.photoArray[0] ];
    
    for (int i = 0; i < photoArray1.count; i ++) {
        UIImageView * imageView = [[UIImageView alloc]init];
        
        //注:做滑动画面的时候，这里的坐标设置一定要小心，x间距一定要有累加，同理上下滑动的时候y间距也一样
        imageView.frame = CGRectMake(i*self.ScrollerFrame.size.width, 0, self.ScrollerFrame.size.width, self.ScrollerFrame.size.height);
//        imageView.image = [UIImage imageNamed:photoArray1[i]];
        [imageView setImageWithURL:photoArray1[i]];
        [self.myScrollView addSubview:imageView];
        
    }
    
    [self.myScrollView setContentSize:CGSizeMake((self.ScrollerFrame.size.width * photoArray1.count), self.ScrollerFrame.size.height)];
    
    self.myScrollView.pagingEnabled = YES;
    
    self.myScrollView.bounces = NO;
    
    [self.myScrollView setContentOffset:CGPointMake(self.ScrollerFrame.size.width, 0)];
}

-(void)setScrollTime
{
    //每2秒滚动ScrollView
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(causeScroll) userInfo:nil repeats:YES];
}

-(void)pageControl
{
    self.myPageControl = [[UIPageControl alloc]initWithFrame:self.PageFrame];
    //    self.myPageControl.backgroundColor = [UIColor whiteColor];
    
    //把页面控制器加载到self.view上是为了和myScrollView区分开
    [self.myImageView addSubview:self.myPageControl];
    
    //设置页数
    self.myPageControl.numberOfPages = self.n;
    //设置当前页码
    self.myPageControl.currentPage = 0;
    
    //当myPageControl的值改变时调用这个方法（用户触发）
    [self.myPageControl addTarget:self action:@selector(myPageControlValueChange) forControlEvents:UIControlEventValueChanged];
}


-(void)myPageControlValueChange
{
    //页面滚动到页面控制器的值所在的下一页
    [self.myScrollView scrollRectToVisible:CGRectMake((self.myPageControl.currentPage + 1)*self.ScrollerFrame.size.width, 0, self.ScrollerFrame.size.width, self.ScrollerFrame.size.height) animated:YES];
    
    //关掉时间
    [self.timer invalidate];
    
    
    if (self.delayTimer2) {
        [self.delayTimer2 invalidate];//delayTimer2这个指针对象销毁
        self.delayTimer2 = nil;//delayTimer2指向内存空间释放（严谨考虑）
    }
    
    //与setScrollTime方法之间相隔0.7秒，既相隔0.7秒重新滚动myScrollView
    self.delayTimer2 = [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(setScrollTime) userInfo:nil repeats:NO];
    
    
}

-(void)causeScroll
{
    float currentX = self.myScrollView.contentOffset.x + self.ScrollerFrame.size.width;
    //myScrollView滚动到指定位置
    [self.myScrollView scrollRectToVisible:CGRectMake(currentX, 0, self.ScrollerFrame.size.width, self.ScrollerFrame.size.height) animated:YES];
    
    //制作延时timer
    
    //在重新生成timer前，把之前的timer销毁掉
    if (self.delayTimer) {
        [self.delayTimer invalidate];
        self.delayTimer = nil;
    }
    
    
    self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(delayTimerValueChange) userInfo:nil repeats:NO];
    
    //如果滑动到第6张的位置，在动画开始前让myScrollView回到第1张的位置
    if (currentX >= self.ScrollerFrame.size.width * (self.n + 1))
    {
        [self.myScrollView setContentOffset:CGPointMake(0, 0)];
    }
}

-(void)delayTimerValueChange
{
    [self changePageValue];
}

#pragma --- scrollViewDelegate scrollView的代理方法来完成
//scrollView的代理方法之一，滚动动画即将拖拽
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{

    //在拖拽时销毁滚动视图的timer
    [self.timer invalidate];
}
//scrollView的代理方法之一，当滚动动画已经停止拖拽
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    

    if (scrollView.contentOffset.x >= self.ScrollerFrame.size.width * (self.n + 1))
    {
        //判断滑动是否减速
        if (decelerate == NO)
        {
            [scrollView setContentOffset:CGPointMake(self.ScrollerFrame.size.width, 0)];
        }
    }
    if (scrollView.contentOffset.x <=0)
    {
        if (decelerate == NO)
        {
            [scrollView setContentOffset:CGPointMake(self.ScrollerFrame.size.width * (self.n), 0)];
        }
    }
    
    [self changePageValue];
    
    //重新启动动画滚动
    [self setScrollTime];
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

    if (scrollView.contentOffset.x >= self.ScrollerFrame.size.width * (self.n + 1))
    {
        [scrollView setContentOffset:CGPointMake(self.ScrollerFrame.size.width, 0)];
    }
    if (scrollView.contentOffset.x <= 0) {
        [scrollView setContentOffset:CGPointMake(self.ScrollerFrame.size.width * (self.n), 0)];
    }
    
    [self changePageValue];
    

}

-(void)changePageValue
{
    //计算当前页码
    int page = self.myScrollView.contentOffset.x/self.ScrollerFrame.size.width;
    if (page == 0)//表示当前是最前面的一页，整个设置前后两张是原有的，因为最前面的一页就是第五张图片（序号为4），左移page为4
    {
        page = (int)self.n - 1 ;
    }
    if (page == (int)self.n + 1)
    {
        page = 0;
    }
    else{
        page --;
    }
    
    //currentPage的取值为0到4
    self.myPageControl.currentPage = page;
}


@end
