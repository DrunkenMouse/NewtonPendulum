//
//  swingBallView.m
//  牛顿摆
//
//  Created by 王奥东 on 16/12/5.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "swingBallView.h"

static const NSUInteger ballCount = 7;
static const CGFloat ballSize = 14;
static const float ballPendulateRadiusFactor = 1.5;//摆动半径
static const float ballPendulateAngle = M_PI_2 / 1; //摆动角度

@implementation swingBallView {
    
    NSMutableArray *_balls;
    UIView *_leftBall;
    UIView *_rightBall;
    
    NSMutableArray *_reflectionBalls;
    UIView *_leftReflectionBall;
    UIView *_rightReflectionBall;
    UIColor *_ballColor;//球的颜色
    
    float _offset;
    BOOL _animating;
    BOOL _shouldAnimate;
}

-(instancetype)initWithFrame:(CGRect)frame {
    
    UIColor *defaultBallColor = [UIColor colorWithRed:0.47 green:0.60 blue:0.89 alpha:1];
    return [self initWithFrame:frame ballColor:defaultBallColor];
}

-(instancetype)initWithFrame:(CGRect)frame ballColor:(UIColor *)ballColor{
    
    if (self = [super initWithFrame:frame]) {
        
        _ballColor = ballColor;
        
        //三角函数计算出摆动时的偏移量
        _offset = sin(ballPendulateAngle) * (ballPendulateRadiusFactor + 0.5) * ballSize;
        
        [self createBalls];
        [self createReflection];
        
        _shouldAnimate = YES;
        
        [self startAnimating];
    }
    return self;
}

//创建球
-(void)createBalls {
    
    _balls = [NSMutableArray array];
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat xPos = width / 2 - (ballCount / 2 + 0.5) * ballSize;
    CGFloat yPos = CGRectGetHeight(self.frame) / 2 - ballSize / 2;
    
    for (int i = 0; i < ballCount; i++) {
    
        UIView *ball = [self ball];
        ball.frame = CGRectMake(xPos, yPos, ballSize, ballSize);
        [self addSubview:ball];
        [_balls addObject:ball];
        xPos += ballSize;
    }
    //左边球为第一个球，右边球为最后一个球
    _leftBall = _balls[0];
    _rightBall = _balls[ballCount - 1];
}

//创建球的反射效果
-(void)createReflection {
    
    _reflectionBalls = [NSMutableArray array];
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat xPos = width / 2 - (ballCount / 2 + 0.5) * ballSize;
    CGFloat yPos = CGRectGetHeight(self.frame) /2 + ballSize / 2 + 5;
    //反射的球
    //在球旋转180°的位置创建出同样数量的球，球的背景颜色是个色梯
    for (int i = 0; i < ballCount; i++) {
        //生成反射球
        UIView *reflectionBall = [self ball];
        reflectionBall.frame = CGRectMake(xPos, yPos, ballSize, ballSize);
        reflectionBall.transform = CGAffineTransformMakeRotation(M_PI);
        
        //渐变layer,梯度动画,用于反射球的背景色
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = reflectionBall.bounds;
        gradient.startPoint = CGPointMake(0.5, 1);
        gradient.endPoint = CGPointMake(0.5, 0);
        gradient.colors = @[(id)[UIColor colorWithWhite:1 alpha:0.2].CGColor,(id)[UIColor clearColor].CGColor,(id)[UIColor clearColor].CGColor];
        gradient.locations = @[@(0),@(0.35),@(1)];
        reflectionBall.layer.mask = gradient;
        [self addSubview:reflectionBall];
        [_reflectionBalls addObject:reflectionBall];
        xPos += ballSize;
    }
    //获取第一个旋转球与最后一个
    _leftReflectionBall = _reflectionBalls[0];
    _rightReflectionBall = _reflectionBalls[ballCount - 1];
}

//获取
-(UIView *)ball {
    UIView *ball = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ballSize, ballSize)];
    ball.backgroundColor = _ballColor;
    ball.layer.cornerRadius = ballSize / 2;
    ball.clipsToBounds = YES;
    return ball;
}


//左边球的摆动
-(void)leftBallPendulate {
    
    //给左边第一个球设置一个锚点并重新设置layer赋值，让其根据锚点摆动
    [self setAnchorPoint:CGPointMake(0.5, -ballPendulateRadiusFactor) forView:_leftBall];
    //开始摆动
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        //球旋转，背影移动
        _leftBall.transform = CGAffineTransformMakeRotation(ballPendulateAngle);
        
        _leftReflectionBall.frame = CGRectMake(_leftReflectionBall.frame.origin.x - _offset, _leftReflectionBall.frame.origin.y, _leftReflectionBall.frame.size.width, _leftReflectionBall.frame.size.height);

    } completion:^(BOOL finished) {
        //摆动还原
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            _leftBall.transform = CGAffineTransformMakeRotation(0);
            _leftReflectionBall.frame = CGRectMake(_leftReflectionBall.frame.origin.x + _offset, _leftReflectionBall.frame.origin.y, _leftReflectionBall.frame.size.width, _leftReflectionBall.frame.size.height);
        } completion:^(BOOL finished) {
            //继续动画，左边结束开始右边
            if (_shouldAnimate) {
                [self rightBallPendulate];
            }
        }];
    }];
    
}

//右边球的摆动,上同
-(void)rightBallPendulate {
    
    [self setAnchorPoint:CGPointMake(0.5, -ballPendulateRadiusFactor) forView:_rightBall];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        
        _rightBall.transform = CGAffineTransformMakeRotation(-ballPendulateAngle);
        _rightReflectionBall.frame = CGRectMake(_rightReflectionBall.frame.origin.x + _offset, _rightReflectionBall.frame.origin.y, _rightReflectionBall.frame.size.width, _rightReflectionBall.frame.size.height);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            _rightBall.transform = CGAffineTransformMakeRotation(0);
            _rightReflectionBall.frame = CGRectMake(_rightReflectionBall.frame.origin.x - _offset, _rightReflectionBall.frame.origin.y, _rightReflectionBall.frame.size.width, _rightReflectionBall.frame.size.height);
        } completion:^(BOOL finished) {
            
            if (_shouldAnimate) {
                [self leftBallPendulate];
            }
            
        }];
    }];
    
}

//设置传来的点为锚点，设置固定的点并重置layer的位置用于让其摆动
-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)anchorView {
    
    CGPoint newPoint = CGPointMake(anchorView.bounds.size.width * anchorPoint.x, anchorView.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(anchorView.bounds.size.width * anchorView.layer.anchorPoint.x, anchorView.bounds.size.height * anchorView.layer.anchorPoint.y);
    
    //把变化应用到一个点上
    newPoint = CGPointApplyAffineTransform(newPoint, anchorView.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, anchorView.transform);
    //重新设置View的layer位置
    CGPoint position = anchorView.layer.position;
   
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    anchorView.layer.position = position;
    anchorView.layer.anchorPoint = anchorPoint;
    
}


-(void)startAnimating {
    
    if (_animating) {
        
        return;
    }
    _animating = YES;
    _shouldAnimate = YES;
    [self leftBallPendulate];
}


-(void)stopAnimating {
    if (!_animating) {
        return;
    }
    _animating = NO;
    _shouldAnimate = NO;
}


-(BOOL)isAnimating {
    return _animating;
}

@end
