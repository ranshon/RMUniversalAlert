//
//  RMUniversalAlert.m
//  RMUniversalAlert
//
//  Created by Ryan Maxwell on 19/11/14.
//  Copyright (c) 2014 Ryan Maxwell. All rights reserved.
//

#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import <UIAlertController+Blocks/UIAlertController+Blocks.h>

#import "RMUniversalAlert.h"

static NSInteger const NoButtonExistsIndex = -1;

@interface RMUniversalAlert ()

@property (nonatomic) UIAlertController *alertController;
@property (nonatomic) UIAlertView *alertView;
@property (nonatomic) UIActionSheet *actionSheet;

@property (nonatomic, assign) BOOL hasCancelButton;
@property (nonatomic, assign) BOOL hasDestructiveButton;
@property (nonatomic, assign) BOOL hasOtherButtons;

@end

@implementation RMUniversalAlert

+ (instancetype)showAlertInViewController:(UIViewController *)viewController
                                withTitle:(NSString *)title
                                  message:(NSString *)message
                        cancelButtonTitle:(NSString *)cancelButtonTitle
                   destructiveButtonTitle:(NSString *)destructiveButtonTitle
                        otherButtonTitles:(NSArray *)otherButtonTitles
                                 tapBlock:(RMUniversalAlertCompletionBlock)tapBlock
{
    RMUniversalAlert *alert = [[RMUniversalAlert alloc] init];
    
    alert.hasCancelButton = cancelButtonTitle != nil;
    alert.hasDestructiveButton = destructiveButtonTitle != nil;
    alert.hasOtherButtons = otherButtonTitles.count > 0;
    
    if ([UIAlertController class]) {
        alert.alertController = [UIAlertController showAlertInViewController:viewController
                                                                   withTitle:title message:message
                                                           cancelButtonTitle:cancelButtonTitle
                                                      destructiveButtonTitle:destructiveButtonTitle
                                                           otherButtonTitles:otherButtonTitles
                                                                    tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                                                        if (tapBlock) {
                                                                            tapBlock(alert, buttonIndex);
                                                                        }
                                                                    }];
    } else {
        NSMutableArray *other = [NSMutableArray array];
        
        if (destructiveButtonTitle) {
            [other addObject:destructiveButtonTitle];
        }
        
        if (otherButtonTitles) {
            [other addObjectsFromArray:otherButtonTitles];
        }
        
        alert.alertView =  [UIAlertView showWithTitle:title
                                              message:message
                                    cancelButtonTitle:cancelButtonTitle
                                    otherButtonTitles:other
                                             tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex){
                                                 if (tapBlock) {
                                                     if (buttonIndex == alertView.cancelButtonIndex) {
                                                         tapBlock(alert, UIAlertControllerBlocksCancelButtonIndex);
                                                     } else if (destructiveButtonTitle) {
                                                         if (buttonIndex == alertView.firstOtherButtonIndex) {
                                                             tapBlock(alert, UIAlertControllerBlocksDestructiveButtonIndex);
                                                         } else if (otherButtonTitles.count) {
                                                             NSInteger otherOffset = buttonIndex - alertView.firstOtherButtonIndex;
                                                             tapBlock(alert, UIAlertControllerBlocksFirstOtherButtonIndex + otherOffset - 1);
                                                         }
                                                     } else if (otherButtonTitles.count) {
                                                         NSInteger otherOffset = buttonIndex - alertView.firstOtherButtonIndex;
                                                         tapBlock(alert, UIAlertControllerBlocksFirstOtherButtonIndex + otherOffset);
                                                     }
                                                 }
                                             }];
    }
    
    return alert;
}

+ (instancetype)showActionSheetInViewController:(UIViewController *)viewController
                                      withTitle:(NSString *)title
                                        message:(NSString *)message
                              cancelButtonTitle:(NSString *)cancelButtonTitle
                         destructiveButtonTitle:(NSString *)destructiveButtonTitle
                              otherButtonTitles:(NSArray *)otherButtonTitles
                                       tapBlock:(RMUniversalAlertCompletionBlock)tapBlock
{
    RMUniversalAlert *alert = [[RMUniversalAlert alloc] init];
    
    alert.hasCancelButton = cancelButtonTitle != nil;
    alert.hasDestructiveButton = destructiveButtonTitle != nil;
    alert.hasOtherButtons = otherButtonTitles.count > 0;
    
    if ([UIAlertController class]) {
        alert.alertController = [UIAlertController showActionSheetInViewController:viewController
                                                                         withTitle:title
                                                                           message:message
                                                                 cancelButtonTitle:cancelButtonTitle
                                                            destructiveButtonTitle:destructiveButtonTitle
                                                                 otherButtonTitles:otherButtonTitles
                                                                          tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                                                              if (tapBlock) {
                                                                                  tapBlock(alert, buttonIndex);
                                                                              }
                                                                          }];
    } else {
        alert.actionSheet =  [UIActionSheet showInView:viewController.view
                                             withTitle:title
                                     cancelButtonTitle:cancelButtonTitle
                                destructiveButtonTitle:destructiveButtonTitle
                                     otherButtonTitles:otherButtonTitles
                                              tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                                                  if (tapBlock) {
                                                      if (buttonIndex == actionSheet.cancelButtonIndex) {
                                                          tapBlock(alert, UIAlertControllerBlocksCancelButtonIndex);
                                                      } else if (buttonIndex == actionSheet.destructiveButtonIndex) {
                                                          tapBlock(alert, UIAlertControllerBlocksDestructiveButtonIndex);
                                                      } else if (otherButtonTitles.count) {
                                                          NSInteger otherOffset = buttonIndex - actionSheet.firstOtherButtonIndex;
                                                          tapBlock(alert, UIAlertControllerBlocksFirstOtherButtonIndex + otherOffset);
                                                      }
                                                  }
                                              }];
    }
    
    return alert;
}

#pragma mark -

- (BOOL)visible
{
    if (self.alertController) {
        return self.alertController.visible;
    } else if (self.alertView) {
        return self.alertView.visible;
    } else if (self.actionSheet) {
        return self.actionSheet.visible;
    }
    NSAssert(false, @"Unsupported alert.");
    return NO;
}

- (NSInteger)cancelButtonIndex
{
    if (!self.hasCancelButton) {
        return NoButtonExistsIndex;
    }
    
    if (self.alertController) {
        return self.alertController.cancelButtonIndex;
    } else if (self.alertView) {
        return self.alertView.cancelButtonIndex;
    } else if (self.actionSheet) {
        return self.actionSheet.cancelButtonIndex;
    }
    
    return NoButtonExistsIndex;
}

- (NSInteger)firstOtherButtonIndex
{
    if (!self.hasOtherButtons) {
        return NoButtonExistsIndex;
    }
    
    if (self.alertController) {
        return self.alertController.firstOtherButtonIndex;
    } else if (self.alertView) {
        return self.alertView.firstOtherButtonIndex;
    } else if (self.actionSheet) {
        return self.actionSheet.firstOtherButtonIndex;
    }
    
    return NoButtonExistsIndex;
}

- (NSInteger)destructiveButtonIndex
{
    if (!self.hasDestructiveButton) {
        return NoButtonExistsIndex;
    }
    
    if (self.alertController) {
        return self.alertController.destructiveButtonIndex;
    } else if (self.alertView) {
        return self.alertView.firstOtherButtonIndex;
    } else if (self.actionSheet) {
        return self.actionSheet.firstOtherButtonIndex;
    }
    
    return NoButtonExistsIndex;
}

@end
