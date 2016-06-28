/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
View controller for camera interface.
*/

@import UIKit;

@protocol AAPLCameraViewControllerDelegate;
@interface AAPLCameraViewController : UIViewController

@property (nonatomic, nullable, weak) id <AAPLCameraViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *userName;
@end


@protocol AAPLCameraViewControllerDelegate <NSObject>

@optional
-(NSString * _Nullable)receiveUserName;
-(void)sendUserName:(NSString * _Nullable)userName digitalQueue:(NSArray * _Nullable)digitalQueue;
@end