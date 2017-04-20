//
//  P9TutorialPlayer.h
//
//
//  Created by Tae Hyun Na on 2015. 8. 20.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

@import UIKit;
@import QuartzCore;

/*!
 Action type when object entrance or exit on playing view.
 */
typedef NS_ENUM(NSInteger, P9TutorialPlayerActionType) {
    P9TutorialPlayerActionFadeIn,
    P9TutorialPlayerActionFadeOut,
    P9TutorialPlayerActionSizeUp,
    P9TutorialPlayerActionSizeDown,
    P9TutorialPlayerActionFromTop,
    P9TutorialPlayerActionFromLeft,
    P9TutorialPlayerActionFromBottom,
    P9TutorialPlayerActionFromRight
};

/*!
 Block code definition to handling to play tutorial.
 Parameter NSDictionary have passed parameters when calling playAction.
 */
typedef void(^P9TutorialPlayerActionBlock)(NSDictionary *);

/*!
 P9TutorialPlayer
 
 Helper module to play tutorial.
 */
@interface P9TutorialPlayer : NSObject <CAAnimationDelegate>

/*!
 Get shared default singleton module.
 @returns Return singleton P9TutorialPlayer object
 */
+ (P9TutorialPlayer *)defaultManager;

/*!
 Prepare P9TutorialPlayer.
 @param repositoryPath repository path for P9TutorialPlayer's own data handling.
 @returns Return the result of register succeed or not.
 */
- (BOOL)standbyWithRepositoryPath:(NSString *)repositoryPath;

/*!
 Set action block code for key.
 @param actionBlock you can write play script code in this block.
 @param key key string to identify tutorials each other.
 @returns Return the result of register succeed or not.
 */
- (BOOL)setAction:(P9TutorialPlayerActionBlock)actionBlock forKey:(NSString *)key;

/*!
 Remove action block code for key.
 @param key key string to identify tutorials each other.
 */
- (void)removeActionForKey:(NSString *)key;

/*!
 Remove all action block code.
 */
- (void)removeAllActions;

/*!
 Play tutorial actions for each given keys.
 @param keys array that contain keys to play action.
 @param parameterDict parameterDict will pass actionBlock of turorial action for key and your block code can referenece it.
 @param viewController play animation will activate given viewContrller.
 @returns Return the result of register succeed or not.
 */
- (BOOL)playAction:(NSArray *)keys parameterDict:(NSDictionary *)parameterDict onViewController:(UIViewController *)viewController;

/*!
 Get played count for given key.
 @param key key string to check.
 @returns Return played count.
 */
- (NSUInteger)playedCountForKey:(NSString *)key;

/*!
 Increase played count for given key. if you call playAction method and play successful then this method called automatically.
 @param key key string to increase.
 */
- (NSInteger)increasePlayedCountForKey:(NSString *)key;

/*!
 Reset played count for given key.
 @param key key string to reset.
 */
- (void)resetPlayedCountForKey:(NSString *)key;

/*!
 Reset played count for all managed key.
 */
- (void)resetAllPlayedCount;

/*!
 add script for mask circle entrance play.
 @param radius radius of mask circle.
 @param position position of mask circle.
 @param waitUntilUserTouch if you want to hold to next animation until user touch event then give it to YES. If not, give to it NO, then animation will go to next automatically.
 */
- (void)addScriptForMaskCircleEntranceWithRadius:(CGFloat)radius position:(CGPoint)position waitUntilUserTouch:(BOOL)waitUntilUserTouch;

/*!
 add script for mask circle move play.
 @param radius radius of mask circle.
 @param position position of mask circle.
 @param waitUntilUserTouch if you want to hold to next animation until user touch event then give it to YES. If not, give to it NO, then animation will go to next automatically.
 */
- (void)addScriptForMaskCircleMoveWithRadius:(CGFloat)radius position:(CGPoint)position waitUntilUserTouch:(BOOL)waitUntilUserTouch;

/*!
 add script for mask circle exit play.
 @param radius radius of mask circle.
 @param position position of mask circle.
 @param waitUntilUserTouch if you want to hold to next animation until user touch event then give it to YES. If not, give to it NO, then animation will go to next automatically.
 */
- (void)addScriptForMaskCircleExitWithRadius:(CGFloat)radius position:(CGPoint)position waitUntilUserTouch:(BOOL)waitUntilUserTouch;

/*!
 add script for mask rectangle entrance play.
 @param rect frame of mask rectangle.
 @param waitUntilUserTouch if you want to hold to next animation until user touch event then give it to YES. If not, give to it NO, then animation will go to next automatically.
 */
- (void)addScriptForMaskRectangleEntranceWithRect:(CGRect)rect waitUntilUserTouch:(BOOL)waitUntilUserTouch;

/*!
 add script for mask rectangle move play.
 @param rect frame of mask rectangle.
 @param waitUntilUserTouch if you want to hold to next animation until user touch event then give it to YES. If not, give to it NO, then animation will go to next automatically.
 */
- (void)addScriptForMaskRectangleMoveWithRect:(CGRect)rect waitUntilUserTouch:(BOOL)waitUntilUserTouch;

/*!
 add script for mask rectangle exit play.
 @param rect frame of mask rectangle.
 @param waitUntilUserTouch if you want to hold to next animation until user touch event then give it to YES. If not, give to it NO, then animation will go to next automatically.
 */
- (void)addScriptForMaskRectangleExitWithRect:(CGRect)rect waitUntilUserTouch:(BOOL)waitUntilUserTouch;

/*!
 add script for image entrance play.
 @param image image to entrance.
 @param rect frame of mask rectangle.
 @param actionType action type when entrance image.
 @param waitUntilUserTouch if you want to hold to next animation until user touch event then give it to YES. If not, give to it NO, then animation will go to next automatically.
 */
- (void)addScriptForImageEntranceWithImageBoard:(UIImage *)image rect:(CGRect)rect actionType:(P9TutorialPlayerActionType)actionType waitUntilUserTouch:(BOOL)waitUntilUserTouch;

/*!
 add script for image entrance play.
 @param string string to entrance.
 @param rect frame of mask rectangle.
 @param actionType action type when entrance image.
 @param waitUntilUserTouch if you want to hold to next animation until user touch event then give it to YES. If not, give to it NO, then animation will go to next automatically.
 */
- (void)addScriptForStringEntranceWithStringBoard:(NSAttributedString *)string rect:(CGRect)rect actionType:(P9TutorialPlayerActionType)actionType waitUntilUserTouch:(BOOL)waitUntilUserTouch;

/*!
 add script for clear all exit on board play.
 @param actionType action type when entrance image.
 @param waitUntilUserTouch if you want to hold to next animation until user touch event then give it to YES. If not, give to it NO, then animation will go to next automatically.
 */
- (void)addScriptForClearBoardWithActionType:(P9TutorialPlayerActionType)actionType waitUntilUserTouch:(BOOL)waitUntilUserTouch;

/*!
 Status value of standby value of P9TutorialPlayer.
 */
@property (nonatomic, readonly) BOOL standby;

/*!
 Repository path of P9TutorialPlayer.
 */
@property (nonatomic, readonly) NSString *repositoryPath;

/*!
 Deactive value of P9TutorialPlayer. If this value is YES then, all tutorial action will not activate globally.
 */
@property (nonatomic, assign) BOOL deactive;

/*!
 Play duration for each animation step.
 */
@property (nonatomic, assign) NSTimeInterval playDuration;

/*!
 Status value of animation. It will return YES, if any other tutorial animation played.
 */
@property (nonatomic, readonly) BOOL isPlaying;

@end
