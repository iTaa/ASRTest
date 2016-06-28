//
//  FlowerWriter.h
//  FlowerWriter
//
//  Created by scott.lin on 16/6/16.
//  Copyright © 2016年 scott.lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface FlowerWriter : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property(nonatomic,assign)BOOL isRecording;
@property(nonatomic,assign)BOOL isAudioSingleRecording;
@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSArray *digitalQueue;
-(id)initWithVideoOutput:(AVCaptureVideoDataOutput*)videoOutput audioOutput:(AVCaptureAudioDataOutput*)audioOutput userName:(NSString*)userName;
-(void)startWriting;
-(void)stopWriting;

-(void)startAudioSingleWriting;
-(void)stopAudioSingleWriting:(BOOL)isAutoStart;
@end
