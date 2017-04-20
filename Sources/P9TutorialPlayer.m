//
//  P9TutorialPlayer.h
//
//
//  Created by Tae Hyun Na on 2015. 8. 20.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

#import "P9TutorialPlayer.h"

#define     kKeyDictFileName            @"tutorialFlags"
#define     kDefaultAnimationDuration   0.3f

#define     kOperation                  @"operation"
#define     kAnimationObject            @"animationObject"
#define     kAnimationKey               @"animationKey"
#define     kRadius                     @"radius"
#define     kPosition                   @"position"
#define     kRectange                   @"rectangle"
#define     kImage                      @"image"
#define     kString                     @"string"
#define     kActionType                 @"actionType"
#define     kWaitUntilUserTouch         @"waitUntilUserTouch"

typedef NS_ENUM(NSInteger, P9TutorialPlayerOperationType) {
    P9TutorialPlayerOperationDummy,
    P9TutorialPlayerOperationMaskCircle,
    P9TutorialPlayerOperationMaskRectangle,
    P9TutorialPlayerOperationImage,
    P9TutorialPlayerOperationString,
    P9TutorialPlayerOperationClear
};

@interface P9TutorialPlayer ()

- (void)syncKeyDict;
- (UIViewController *)defaultViewController;
- (BOOL)prepareTutorialWithViewController:(UIViewController *)viewController;
- (BOOL)openTutorial;
- (BOOL)closeTutorial;
- (void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer;
- (NSDictionary *)previousMaskNode;
- (void)animateView:(UIView *)view withActionType:(P9TutorialPlayerActionType)actionType;
- (BOOL)animationQueuePumping;

@property (nonatomic, strong) UIViewController *playgroundViewController;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *guideBoardView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) NSMutableArray *animationQueue;
@property (nonatomic, strong) NSDictionary *currentPlayingNode;
@property (nonatomic, strong) NSDictionary *nextPlayNode;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) NSMutableDictionary *keyDict;
@property (nonatomic, strong) NSMutableDictionary *actionBlockDict;

@end

@implementation P9TutorialPlayer

- (id)init
{
    if( (self = [super init]) != nil ) {
        _playDuration = kDefaultAnimationDuration;
        if( (_animationQueue = [NSMutableArray new]) == nil ) {
            return nil;
        }
        if( (_keyDict = [NSMutableDictionary new]) == nil ) {
            return nil;
        }
        if( (_actionBlockDict = [NSMutableDictionary new]) == nil ) {
            return nil;
        }
    }
    
    return self;
}

- (void)syncKeyDict
{
    if( self.standby == NO ) {
        return;
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", _repositoryPath, kKeyDictFileName];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_keyDict];
    if( data != nil ) {
        [data writeToFile:filePath atomically:YES];
    }
}

- (UIViewController *)defaultViewController
{
    if( [[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)] == NO ) {
        return nil;
    }
    id windowObject = [[UIApplication sharedApplication].delegate window];
    if( [windowObject isKindOfClass:[UIWindow class]] == NO ) {
        return nil;
    }
    return [windowObject rootViewController];
}

- (BOOL)prepareTutorialWithViewController:(UIViewController *)viewController
{
    if( _isPlaying == YES ) {
        return NO;
    }
    if( viewController == nil ) {
        if( (viewController = [self defaultViewController]) == nil ) {
            return NO;
        }
    }
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    if( singleTapGestureRecognizer == nil ) {
        return NO;
    }
    if( (_guideBoardView = [[UIView alloc] init]) == nil ) {
        return NO;
    }
    _guideBoardView.backgroundColor = [UIColor clearColor];
    _guideBoardView.userInteractionEnabled = NO;
    
    CGRect frame = viewController.view.bounds;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    if( pathRef == NULL ) {
        return NO;
    }
    CGPathAddRect(pathRef, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
    
    if( (_maskLayer = [[CAShapeLayer alloc] init]) == nil ) {
        CGPathRelease(pathRef);
        return NO;
    }
    _maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    _maskLayer.path = pathRef;
    _maskLayer.fillRule = kCAFillRuleEvenOdd;
    
    CGPathRelease(pathRef);
    
    if( (_overlayView = [[UIView alloc] initWithFrame:frame]) == nil ) {
        _maskLayer = nil;
        return NO;
    }
    _overlayView.backgroundColor = [UIColor blackColor];
    _overlayView.alpha = 0.0f;
    _overlayView.clipsToBounds = YES;
    _overlayView.layer.mask = _maskLayer;
    [_overlayView addGestureRecognizer:singleTapGestureRecognizer];
    
    _playgroundViewController = viewController;
    [_playgroundViewController.view addSubview:_overlayView];
    [_playgroundViewController.view addSubview:_guideBoardView];
    
    return YES;
}

- (BOOL)openTutorial
{
    _isPlaying = YES;
    [UIView animateWithDuration:_playDuration animations:^{
        _overlayView.alpha = 0.8f;
    } completion:^(BOOL finished) {
        [self animationQueuePumping];
    }];
    
    return YES;
}

- (BOOL)closeTutorial
{
    [UIView animateWithDuration:_playDuration animations:^{
        _overlayView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [_overlayView removeFromSuperview];
        [_guideBoardView removeFromSuperview];
        _overlayView = nil;
        _guideBoardView = nil;
        _maskLayer = nil;
        _isPlaying = NO;
    }];
    
    return YES;
}

-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if( _animating == YES ) {
        return;
    }
    if( [_currentPlayingNode[kWaitUntilUserTouch] boolValue] == YES ) {
        [self animationQueuePumping];
        return;
    }
    
    [self closeTutorial];
}

- (NSDictionary *)previousMaskNode
{
    if( [_animationQueue count] == 0 ) {
        return nil;
    }
    NSInteger count = (NSInteger)[_animationQueue count];
    for( NSInteger i=count-1 ; i>=0 ; --i ) {
        NSDictionary *node = [_animationQueue objectAtIndex:i];
        switch( (P9TutorialPlayerOperationType)[node[kOperation] integerValue] ) {
            case P9TutorialPlayerOperationMaskCircle :
            case P9TutorialPlayerOperationMaskRectangle :
                return node;
            default :
                break;
        }
    }
    
    return nil;
}

- (void)animateView:(UIView *)view withActionType:(P9TutorialPlayerActionType)actionType
{
    switch( actionType ) {
        case P9TutorialPlayerActionFadeIn :
            {
                view.alpha = 0.0f;
                [self animationStarted];
                [UIView animateWithDuration:_playDuration animations:^{
                    view.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    [self animationEnded];
                }];
            }
            break;
        case P9TutorialPlayerActionFadeOut :
            {
                view.alpha = 1.0f;
                [self animationStarted];
                [UIView animateWithDuration:_playDuration animations:^{
                    view.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    [self animationEnded];
                }];
            }
            break;
        case P9TutorialPlayerActionSizeUp :
            {
                view.alpha = 0.9f;
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1f, 0.1f);
                [self animationStarted];
                [UIView animateWithDuration:_playDuration animations:^{
                    view.alpha = 1.0f;
                    view.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    [self animationEnded];
                }];
            }
            break;
        case P9TutorialPlayerActionSizeDown :
            {
                view.alpha = 1.0f;
                view.transform = CGAffineTransformIdentity;
                [self animationStarted];
                [UIView animateWithDuration:_playDuration animations:^{
                    view.alpha = 0.9f;
                    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1f, 0.1f);
                } completion:^(BOOL finished) {
                    [self animationEnded];
                }];
            }
            break;
        case P9TutorialPlayerActionFromTop :
            {
                view.alpha = 0.9f;
                CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0f, -view.frame.size.height/2.0f);
                transform = CGAffineTransformScale(transform, 1.0f, 0.1f);
                view.transform = transform;
                [self animationStarted];
                [UIView animateWithDuration:_playDuration animations:^{
                    view.alpha = 1.0f;
                    view.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    [self animationEnded];
                }];
            }
            break;
        case P9TutorialPlayerActionFromLeft :
            {
                view.alpha = 0.9f;
                CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -view.frame.size.width/2.0f, 0.0f);
                transform = CGAffineTransformScale(transform, 0.1f, 1.0f);
                view.transform = transform;
                [self animationStarted];
                [UIView animateWithDuration:_playDuration animations:^{
                    view.alpha = 1.0f;
                    view.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    [self animationEnded];
                }];
            }
            break;
        case P9TutorialPlayerActionFromBottom :
            {
                view.alpha = 0.9f;
                CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0f, view.frame.size.height/2.0f);
                transform = CGAffineTransformScale(transform, 1.0f, 0.1f);
                view.transform = transform;
                [self animationStarted];
                [UIView animateWithDuration:_playDuration animations:^{
                    view.alpha = 1.0f;
                    view.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    [self animationEnded];
                }];
            }
            break;
        case P9TutorialPlayerActionFromRight :
            {
                view.alpha = 0.9f;
                CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, view.frame.size.width/2.0f, 0.0f);
                transform = CGAffineTransformScale(transform, 0.1f, 1.0f);
                view.transform = transform;
                [self animationStarted];
                [UIView animateWithDuration:_playDuration animations:^{
                    view.alpha = 1.0f;
                    view.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    [self animationEnded];
                }];
            }
            break;
        default :
            {
                view.alpha = 0.0f;
                [self animationStarted];
                [UIView animateWithDuration:_playDuration animations:^{
                    view.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    [self animationEnded];
                }];
            }
            break;
    }
}

- (void)animationStarted
{
    _animating = YES;
    _currentPlayingNode = _nextPlayNode;
    _nextPlayNode = nil;
}

- (void)animationEnded
{
    _animating = NO;
    if( [_currentPlayingNode[kWaitUntilUserTouch] boolValue] == YES ) {
        return;
    }
    [self animationQueuePumping];
}

- (BOOL)animationQueuePumping
{
    if( [_animationQueue count] == 0 ) {
        _currentPlayingNode = nil;
        return [self closeTutorial];
    }
    
    _nextPlayNode = [_animationQueue objectAtIndex:0];
    [_animationQueue removeObjectAtIndex:0];
    
    switch( (P9TutorialPlayerOperationType)[_nextPlayNode[kOperation] integerValue] ) {
        case P9TutorialPlayerOperationMaskCircle :
        case P9TutorialPlayerOperationMaskRectangle :
            {
                CABasicAnimation *animationObject = _nextPlayNode[kAnimationObject];
                NSString *animationKey = _nextPlayNode[kAnimationKey];
                [_maskLayer addAnimation:animationObject forKey:animationKey];
            }
            break;
        case P9TutorialPlayerOperationImage :
            {
                UIImage *image = _nextPlayNode[kImage];
                P9TutorialPlayerActionType actionType = (P9TutorialPlayerActionType)[_nextPlayNode[kActionType] integerValue];
                CGRect rect = [_nextPlayNode[kRectange] CGRectValue];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                if( imageView == nil ) {
                    return NO;
                }
                imageView.frame = rect;
                [_guideBoardView addSubview:imageView];
                [self animateView:imageView withActionType:actionType];
            }
            break;
        case P9TutorialPlayerOperationString :
            {
                CGRect rect = [_nextPlayNode[kRectange] CGRectValue];
                UILabel *label = [[UILabel alloc] initWithFrame:rect];
                if( label == nil ) {
                    return NO;
                }
                if( _nextPlayNode[kString] != nil ) {
                    NSAttributedString *string = _nextPlayNode[kString];
                    label.numberOfLines = 3;
                    label.backgroundColor = [UIColor clearColor];
                    label.attributedText = string;
                }
                P9TutorialPlayerActionType actionType = (P9TutorialPlayerActionType)[_nextPlayNode[kActionType] integerValue];
                [_guideBoardView addSubview:label];
                [self animateView:label withActionType:actionType];
            }
            break;
        case P9TutorialPlayerOperationClear :
            {
                [self animationStarted];
                [UIView animateWithDuration:_playDuration animations:^{
                    for( UIView *anView in _guideBoardView.subviews ) {
                        [anView setAlpha:0.0f];
                    }
                } completion:^(BOOL finished) {
                    for( UIView *anView in _guideBoardView.subviews ) {
                        [anView removeFromSuperview];
                    }
                    [self animationEnded];
                }];
            }
            break;
        default :
            break;
    }
    
    return YES;
}

+ (P9TutorialPlayer *)defaultManager
{
    static dispatch_once_t once;
    static P9TutorialPlayer *defaultInstance;
    dispatch_once(&once, ^{defaultInstance = [[self alloc] init];});
    return defaultInstance;
}

- (BOOL)standbyWithRepositoryPath:(NSString *)repositoryPath
{
    if( (self.standby == YES) || ([repositoryPath length] == 0) ) {
        return NO;
    }
    
    BOOL isDirectory;
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:repositoryPath isDirectory:&isDirectory] == NO ) {
        if( [[NSFileManager defaultManager] createDirectoryAtPath:repositoryPath withIntermediateDirectories:YES attributes:nil error:nil] == NO ) {
            return NO;
        }
    } else {
        if( isDirectory == NO ) {
            return NO;
        }
    }
    
    _repositoryPath = [repositoryPath copy];
    _standby = YES;
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", _repositoryPath, kKeyDictFileName];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if( data != nil ) {
        @synchronized (self) {
            [_keyDict setDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
        }
    }
    
    return YES;
}

- (BOOL)setAction:(P9TutorialPlayerActionBlock)actionBlock forKey:(NSString *)key
{
    if( self.standby == NO ) {
        return NO;
    }
    if( self.deactive == YES ) {
        return NO;
    }
    if( (actionBlock == nil) || ([key length] == 0) ) {
        return NO;
    }
    [_actionBlockDict setObject:actionBlock forKey:key];
    
    return NO;
}

- (void)removeActionForKey:(NSString *)key
{
    if( self.standby == NO ) {
        return;
    }
    if( self.deactive == YES ) {
        return;
    }
    if( [key length] == 0 ) {
        return;
    }
    [_actionBlockDict removeObjectForKey:key];
}

- (void)removeAllActions
{
    if( self.standby == NO ) {
        return;
    }
    if( self.deactive == YES ) {
        return;
    }
    [_actionBlockDict removeAllObjects];
}

- (BOOL)playAction:(NSArray *)keys parameterDict:(NSDictionary *)parameterDict onViewController:(UIViewController *)viewController
{
    if( self.standby == NO ) {
        return NO;
    }
    if( self.deactive == YES ) {
        return YES;
    }
    if( [keys count] == 0 ) {
        return NO;
    }
    if( [self prepareTutorialWithViewController:viewController] == NO ) {
        return NO;
    }
    
    [_animationQueue removeAllObjects];
    _currentPlayingNode = nil;
    _nextPlayNode = nil;
    
    for( NSString *key in keys ) {
        P9TutorialPlayerActionBlock actionBlock = [_actionBlockDict objectForKey:key];
        if( actionBlock == nil ) {
            continue;
        }
        actionBlock(parameterDict);
        [self increasePlayedCountForKey:key];
    }
    
    [self openTutorial];
    
    return YES;
}

- (NSUInteger)playedCountForKey:(NSString *)key
{
    if( self.standby == NO ) {
        return 0;
    }
    if( self.deactive == YES ) {
        return 0;
    }
    if( [key length] == 0 ) {
        return 0;
    }
    NSInteger playedCount = 0;
    @synchronized (self) {
        playedCount = [[_keyDict objectForKey:key] integerValue];
    }
    return playedCount;
}

- (NSInteger)increasePlayedCountForKey:(NSString *)key
{
    if( self.standby == NO ) {
        return 0;
    }
    if( self.deactive == YES ) {
        return 0;
    }
    if( [key length] == 0 ) {
        return 0;
    }
    NSInteger playedCount = 0;
    @synchronized (self) {
        playedCount = [[_keyDict objectForKey:key] integerValue] + 1;
        [_keyDict setObject:@(playedCount) forKey:key];
        [self syncKeyDict];
    }
    
    return playedCount;
}

- (void)resetPlayedCountForKey:(NSString *)key
{
    if( self.standby == NO ) {
        return;
    }
    if( self.deactive == YES ) {
        return;
    }
    if( [key length] == 0 ) {
        return;
    }
    @synchronized (self) {
        [_keyDict removeObjectForKey:key];
        [self syncKeyDict];
    }
}

- (void)resetAllPlayedCount
{
    if( self.standby == NO ) {
        return;
    }
    if( self.deactive == YES ) {
        return;
    }
    @synchronized (self) {
        [_keyDict removeAllObjects];
        [self syncKeyDict];
    }
}

- (void)addScriptForMaskCircleEntranceWithRadius:(CGFloat)radius position:(CGPoint)position waitUntilUserTouch:(BOOL)waitUntilUserTouch
{
    if( self.playgroundViewController == nil ) {
        return;
    }
    
    CGRect frame = self.playgroundViewController.view.bounds;
    CGFloat startRadius = 0.1f;
    CGPoint startPosition = position;
    
    CGMutablePathRef pathRef1 = CGPathCreateMutable();
    CGPathAddArc(pathRef1, nil, startPosition.x, startPosition.y, startRadius, 0.0f, 2.0f*M_PI, false);
    CGPathAddRect(pathRef1, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
    
    CGMutablePathRef pathRef2 = CGPathCreateMutable();
    CGPathAddArc(pathRef2, nil, position.x, position.y, radius, 0.0, 2.0f*M_PI, false);
    CGPathAddRect(pathRef2, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
    
    CABasicAnimation *morph = [CABasicAnimation animationWithKeyPath:@"path"];
    morph.duration  = _playDuration;
    morph.fromValue = (__bridge id)pathRef1;
    morph.toValue   = (__bridge id)pathRef2;
    morph.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    morph.fillMode = kCAFillModeBoth;
    morph.removedOnCompletion = NO;
    morph.delegate = self;
    
    CGPathRelease(pathRef1);
    CGPathRelease(pathRef2);
    
    [_animationQueue addObject:@{kOperation:@(P9TutorialPlayerOperationMaskCircle),kAnimationObject:morph,kAnimationKey:@"morph",kRadius:@(radius),kPosition:[NSValue valueWithCGPoint:position],kWaitUntilUserTouch:@(waitUntilUserTouch)}];
}

- (void)addScriptForMaskCircleMoveWithRadius:(CGFloat)radius position:(CGPoint)position waitUntilUserTouch:(BOOL)waitUntilUserTouch
{
    if( self.playgroundViewController == nil ) {
        return;
    }
    
    CGRect frame = self.playgroundViewController.view.bounds;
    CGFloat startRadius;
    CGPoint startPosition;
    CGRect startRect;
    CGMutablePathRef pathRef1 = CGPathCreateMutable();
    
    if( [_animationQueue count] == 0 ) {
        startRadius = radius;
        startPosition = position;
        CGPathAddArc(pathRef1, nil, startPosition.x, startPosition.y, startRadius, 0.0f, 2.0f*M_PI, false);
        CGPathAddRect(pathRef1, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
    } else {
        NSDictionary *previousMaskNode = [self previousMaskNode];
        if( [previousMaskNode[kOperation] integerValue] == P9TutorialPlayerOperationMaskCircle ) {
            startRadius = [previousMaskNode[kRadius] floatValue];
            startPosition = [previousMaskNode[kPosition] CGPointValue];
            CGPathAddArc(pathRef1, nil, startPosition.x, startPosition.y, startRadius, 0.0f, 2.0f*M_PI, false);
            CGPathAddRect(pathRef1, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
        } else {
            startRect = [previousMaskNode[kRectange] CGRectValue];
            CGPathAddRect(pathRef1, nil, startRect);
            CGPathAddRect(pathRef1, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
        }
    }
    
    CGMutablePathRef pathRef2 = CGPathCreateMutable();
    CGPathAddArc(pathRef2, nil, position.x, position.y, radius, 0.0, 2.0f*M_PI, false);
    CGPathAddRect(pathRef2, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
    
    CABasicAnimation *morph = [CABasicAnimation animationWithKeyPath:@"path"];
    morph.duration  = _playDuration;
    morph.fromValue = (__bridge id)pathRef1;
    morph.toValue   = (__bridge id)pathRef2;
    morph.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    morph.fillMode = kCAFillModeBoth;
    morph.removedOnCompletion = NO;
    morph.delegate = self;
    
    CGPathRelease(pathRef1);
    CGPathRelease(pathRef2);
    
    [_animationQueue addObject:@{kOperation:@(P9TutorialPlayerOperationMaskCircle),kAnimationObject:morph,kAnimationKey:@"morph",kRadius:@(radius),kPosition:[NSValue valueWithCGPoint:position],kWaitUntilUserTouch:@(waitUntilUserTouch)}];
}

- (void)addScriptForMaskCircleExitWithRadius:(CGFloat)radius position:(CGPoint)position waitUntilUserTouch:(BOOL)waitUntilUserTouch
{
    if( self.playgroundViewController == nil ) {
        return;
    }
    
    CGRect frame = self.playgroundViewController.view.bounds;
    CGFloat endRadius = 0.1f;
    CGPoint endPosition = position;
    
    CGMutablePathRef pathRef1 = CGPathCreateMutable();
    CGPathAddArc(pathRef1, nil, position.x, position.y, radius, 0.0f, 2.0f*M_PI, false);
    CGPathAddRect(pathRef1, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
    
    CGMutablePathRef pathRef2 = CGPathCreateMutable();
    CGPathAddArc(pathRef2, nil, endPosition.x, endPosition.y, endRadius, 0.0, 2.0f*M_PI, false);
    CGPathAddRect(pathRef2, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
    
    CABasicAnimation *morph = [CABasicAnimation animationWithKeyPath:@"path"];
    morph.duration  = _playDuration;
    morph.fromValue = (__bridge id)pathRef1;
    morph.toValue   = (__bridge id)pathRef2;
    morph.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    morph.fillMode = kCAFillModeBoth;
    morph.removedOnCompletion = NO;
    morph.delegate = self;
    
    CGPathRelease(pathRef1);
    CGPathRelease(pathRef2);
    
    [_animationQueue addObject:@{kOperation:@(P9TutorialPlayerOperationMaskCircle),kAnimationObject:morph,kAnimationKey:@"morph",kRadius:@(radius),kPosition:[NSValue valueWithCGPoint:position],kWaitUntilUserTouch:@(waitUntilUserTouch)}];
}

- (void)addScriptForMaskRectangleEntranceWithRect:(CGRect)rect waitUntilUserTouch:(BOOL)waitUntilUserTouch
{
    if( self.playgroundViewController == nil ) {
        return;
    }
    
    CGRect frame = self.playgroundViewController.view.bounds;
    CGRect startRect;
    startRect.origin.x = rect.origin.x + (rect.size.width/2.0f);
    startRect.origin.y = rect.origin.y + (rect.size.height/2.0f);
    startRect.size.width = 0.1f;
    startRect.size.height = 0.1f;
    
    CGMutablePathRef pathRef1 = CGPathCreateMutable();
    CGPathAddRect(pathRef1, nil, startRect);
    CGPathAddRect(pathRef1, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
    
    CGMutablePathRef pathRef2 = CGPathCreateMutable();
    CGPathAddRect(pathRef2, nil, rect);
    CGPathAddRect(pathRef2, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
    
    CABasicAnimation *morph = [CABasicAnimation animationWithKeyPath:@"path"];
    morph.duration  = _playDuration;
    morph.fromValue = (__bridge id)pathRef1;
    morph.toValue   = (__bridge id)pathRef2;
    morph.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    morph.fillMode = kCAFillModeBoth;
    morph.removedOnCompletion = NO;
    morph.delegate = self;
    
    CGPathRelease(pathRef1);
    CGPathRelease(pathRef2);
    
    [_animationQueue addObject:@{kOperation:@(P9TutorialPlayerOperationMaskRectangle),kAnimationObject:morph,kAnimationKey:@"morph",kRectange:[NSValue valueWithCGRect:rect],kWaitUntilUserTouch:@(waitUntilUserTouch)}];
}

- (void)addScriptForMaskRectangleMoveWithRect:(CGRect)rect waitUntilUserTouch:(BOOL)waitUntilUserTouch
{
    if( self.playgroundViewController == nil ) {
        return;
    }
    
    CGRect frame = self.playgroundViewController.view.bounds;
    CGFloat startRadius;
    CGPoint startPosition;
    CGRect startRect;
    CGMutablePathRef pathRef1 = CGPathCreateMutable();
    
    if( [_animationQueue count] == 0 ) {
        startRect = rect;
        CGPathAddRect(pathRef1, nil, startRect);
        CGPathAddRect(pathRef1, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
    } else {
        NSDictionary *previousMaskNode = [self previousMaskNode];
        if( [previousMaskNode[kOperation] integerValue] == P9TutorialPlayerOperationMaskRectangle ) {
            startRect = [previousMaskNode[kRectange] CGRectValue];
            CGPathAddRect(pathRef1, nil, startRect);
            CGPathAddRect(pathRef1, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
        } else {
            startRadius = [previousMaskNode[kRadius] floatValue];
            startPosition = [previousMaskNode[kPosition] CGPointValue];
            CGPathAddArc(pathRef1, nil, startPosition.x, startPosition.y, startRadius, 0.0f, 2.0f*M_PI, false);
            CGPathAddRect(pathRef1, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
        }
    }
    
    CGMutablePathRef pathRef2 = CGPathCreateMutable();
    CGPathAddRect(pathRef2, nil, rect);
    CGPathAddRect(pathRef2, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
    
    CABasicAnimation *morph = [CABasicAnimation animationWithKeyPath:@"path"];
    morph.duration  = _playDuration;
    morph.fromValue = (__bridge id)pathRef1;
    morph.toValue   = (__bridge id)pathRef2;
    morph.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    morph.fillMode = kCAFillModeBoth;
    morph.removedOnCompletion = NO;
    morph.delegate = self;
    
    CGPathRelease(pathRef1);
    CGPathRelease(pathRef2);
    
    [_animationQueue addObject:@{kOperation:@(P9TutorialPlayerOperationMaskRectangle),kAnimationObject:morph,kAnimationKey:@"morph",kRectange:[NSValue valueWithCGRect:rect],kWaitUntilUserTouch:@(waitUntilUserTouch)}];
}

- (void)addScriptForMaskRectangleExitWithRect:(CGRect)rect waitUntilUserTouch:(BOOL)waitUntilUserTouch;
{
    if( self.playgroundViewController == nil ) {
        return;
    }
    
    CGRect frame = self.playgroundViewController.view.bounds;
    CGRect endRect;
    endRect.origin.x = rect.origin.x + (rect.size.width/2.0f);
    endRect.origin.y = rect.origin.y + (rect.size.height/2.0f);
    endRect.size.width = 0.1f;
    endRect.size.height = 0.1f;
    
    CGMutablePathRef pathRef1 = CGPathCreateMutable();
    CGPathAddRect(pathRef1, nil, rect);
    CGPathAddRect(pathRef1, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
    
    CGMutablePathRef pathRef2 = CGPathCreateMutable();
    CGPathAddRect(pathRef2, nil, endRect);
    CGPathAddRect(pathRef2, nil, CGRectMake(0, 0, frame.size.width, frame.size.height));
    
    CABasicAnimation *morph = [CABasicAnimation animationWithKeyPath:@"path"];
    morph.duration  = _playDuration;
    morph.fromValue = (__bridge id)pathRef1;
    morph.toValue   = (__bridge id)pathRef2;
    morph.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    morph.fillMode = kCAFillModeBoth;
    morph.removedOnCompletion = NO;
    morph.delegate = self;
    
    CGPathRelease(pathRef1);
    CGPathRelease(pathRef2);
    
    [_animationQueue addObject:@{kOperation:@(P9TutorialPlayerOperationMaskRectangle),kAnimationObject:morph,kAnimationKey:@"morph",kRectange:[NSValue valueWithCGRect:rect],kWaitUntilUserTouch:@(waitUntilUserTouch)}];
}

- (void)addScriptForImageEntranceWithImageBoard:(UIImage *)image rect:(CGRect)rect actionType:(P9TutorialPlayerActionType)actionType waitUntilUserTouch:(BOOL)waitUntilUserTouch
{
    [_animationQueue addObject:@{kOperation:@(P9TutorialPlayerOperationImage),kImage:image,kRectange:[NSValue valueWithCGRect:rect],kActionType:@(actionType),kWaitUntilUserTouch:@(waitUntilUserTouch)}];
}

- (void)addScriptForStringEntranceWithStringBoard:(NSAttributedString *)string rect:(CGRect)rect actionType:(P9TutorialPlayerActionType)actionType waitUntilUserTouch:(BOOL)waitUntilUserTouch
{
    [_animationQueue addObject:@{kOperation:@(P9TutorialPlayerOperationString),kString:string,kRectange:[NSValue valueWithCGRect:rect],kActionType:@(actionType),kWaitUntilUserTouch:@(waitUntilUserTouch)}];
}

- (void)addScriptForClearBoardWithActionType:(P9TutorialPlayerActionType)actionType waitUntilUserTouch:(BOOL)waitUntilUserTouch
{
    [_animationQueue addObject:@{kOperation:@(P9TutorialPlayerOperationClear),kActionType:@(actionType),kWaitUntilUserTouch:@(waitUntilUserTouch)}];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation * _Nonnull)theAnimation
{
    [self animationStarted];
}

- (void)animationDidStop:(CAAnimation * _Nonnull)theAnimation finished:(BOOL)flag
{
    [self animationEnded];
}

@end
