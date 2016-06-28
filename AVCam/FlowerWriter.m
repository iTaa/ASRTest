//
//  FlowerWriter.m
//  FlowerWriter
//
//  Created by scott.lin on 16/6/16.
//  Copyright © 2016年 scott.lin. All rights reserved.
//

#import "FlowerWriter.h"
#import <Photos/Photos.h>
#import "HUD.h"

#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif

@interface FlowerWriter(){
    AVCaptureVideoDataOutput *_videoOutput;
    AVCaptureAudioDataOutput *_audioOutput;
    CMTime                   _cmTime;
}
@property(nonatomic,strong)AVAssetWriter *videoWriter;
@property(nonatomic,strong)AVAssetWriter *audioWriter;
@property(nonatomic,strong)AVAssetWriter *audioSingleWriter;
@property(nonatomic,strong)AVAssetWriterInput *videoWriterInput;
@property(nonatomic,strong)AVAssetWriterInput *audioWriterInput;
@property(nonatomic,strong)AVAssetWriterInput *audioWriterInputOnly;
@property(nonatomic,strong)AVAssetWriterInput *audioWriterInputSingle;


@property(nonatomic,strong)NSString *videoPath;
@property(nonatomic,strong)NSString *audioPath;
@property(nonatomic,strong)NSString *audioSinglePath;
@property(nonatomic) NSString *audioName;
@property(nonatomic) NSString *audioSingleName;
@property(nonatomic) NSString *videoName;
@property(nonatomic) NSInteger index;

@end

@implementation FlowerWriter
#pragma mark -- init
-(id)initWithVideoOutput:(AVCaptureVideoDataOutput*)videoOutput audioOutput:(AVCaptureAudioDataOutput*)audioOutput userName:(NSString *)userName{
    if (self = [super init]) {
        _videoOutput = videoOutput;
        _audioOutput = audioOutput;
        _userName = userName;
        self.isRecording = NO;
        [self initVideoAudioWriter];
        [self initAudioSingleWriter];
    }
    return self;
}

-(void) initVideoAudioWriter
{
    /*1************初始化writer*************/
    //    NSString *betaCompressionDirectory = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/Movie.mp4"];
    NSString *videofileName = [self getUploadFileWithType:@"video" fileType:@"mp4" content:@""];
    self.videoName = videofileName;
    self.videoPath = [NSTemporaryDirectory()stringByAppendingPathComponent:videofileName];
    NSError *error = nil;
    NSString *audiofileName = [self getUploadFileWithType:@"audio" fileType:@"wav" content:@""];
    self.audioName = audiofileName;
    self.audioPath = [NSTemporaryDirectory()stringByAppendingPathComponent:audiofileName];
//    unlink([videoPath UTF8String]);
    
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:self.videoPath] fileType:AVFileTypeQuickTimeMovie error:&error];
    self.audioWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:self.audioPath] fileType:AVFileTypeWAVE error:&error];
    NSParameterAssert(self.videoWriter);
    NSParameterAssert(self.audioWriter);
    if(error)
        NSLog(@"error = %@", [error localizedDescription]);

    
    /*2***********初始化videoWriterInput*************/
    CGSize size = CGSizeMake(360, 640);
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:128.0*1024.0],AVVideoAverageBitRateKey,nil ];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height],AVVideoHeightKey,videoCompressionProps, AVVideoCompressionPropertiesKey, nil];
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    NSParameterAssert(self.videoWriterInput);
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    
//    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
//   AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoWriterInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    

    /*3***********初始化audioWriterInput、audioWriterInputOnly*************/
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    NSDictionary* audioOutputSettings = [ NSDictionary dictionaryWithObjectsAndKeys:
                           
                           [ NSNumber numberWithInt: kAudioFormatLinearPCM ], AVFormatIDKey,
                           [ NSNumber numberWithFloat: 16000.0 ], AVSampleRateKey,
                           [ NSNumber numberWithFloat: 16 ], AVLinearPCMBitDepthKey,
                           [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
                           [ NSNumber numberWithBool:NO ],AVLinearPCMIsBigEndianKey,
                           [ NSNumber numberWithBool:NO ],AVLinearPCMIsFloatKey,
                           [ NSNumber numberWithBool:NO ],AVLinearPCMIsNonInterleaved,
                           [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
                           nil ];
    
    self.audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType: AVMediaTypeAudio outputSettings: nil ];
    self.audioWriterInput.expectsMediaDataInRealTime = YES;
    self.audioWriterInputOnly = [AVAssetWriterInput assetWriterInputWithMediaType: AVMediaTypeAudio outputSettings: audioOutputSettings ];
    self.audioWriterInputOnly.expectsMediaDataInRealTime = YES;
    NSParameterAssert(self.audioWriterInput);
    NSParameterAssert(self.audioWriterInputOnly);
    
    /*4***********添加videoWriterInput、audioWriterInput、audioWriterInputOnly*************/
    if ([self.videoWriter canAddInput:self.videoWriterInput]){
        [self.videoWriter addInput:self.videoWriterInput];
    }
    if ([self.videoWriter canAddInput:self.audioWriterInput]) {
        [self.videoWriter addInput:self.audioWriterInput];
    }
    if ([self.audioWriter canAddInput:self.audioWriterInputOnly]) {
       [self.audioWriter addInput:self.audioWriterInputOnly];
    }

}


-(void) initAudioSingleWriter
{
    /*1************初始化writer*************/
    NSString *audiofileName = [self getUploadFileWithType:@"audioSingle" fileType:@"wav" content:@""];
    self.audioSingleName = audiofileName;
    self.audioSinglePath = [NSTemporaryDirectory()stringByAppendingPathComponent:audiofileName];
    NSError *error;
    self.audioSingleWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:self.audioSinglePath] fileType:AVFileTypeWAVE error:&error];
    NSParameterAssert(self.audioSingleWriter);
    
    /*2***********初始化audioWriterInput、audioWriterInputOnly*************/
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    NSDictionary* audioOutputSettings = [ NSDictionary dictionaryWithObjectsAndKeys:
                                         
                                         [ NSNumber numberWithInt: kAudioFormatLinearPCM ], AVFormatIDKey,
                                         [ NSNumber numberWithFloat: 16000.0 ], AVSampleRateKey,
                                         [ NSNumber numberWithFloat: 16 ], AVLinearPCMBitDepthKey,
                                         [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
                                         [ NSNumber numberWithBool:NO ],AVLinearPCMIsBigEndianKey,
                                         [ NSNumber numberWithBool:NO ],AVLinearPCMIsFloatKey,
                                         [ NSNumber numberWithBool:NO ],AVLinearPCMIsNonInterleaved,
                                         [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
                                         nil ];
    
   
    self.audioWriterInputSingle = [AVAssetWriterInput assetWriterInputWithMediaType: AVMediaTypeAudio outputSettings: audioOutputSettings ];
    self.audioWriterInputSingle.expectsMediaDataInRealTime = YES;
    NSParameterAssert(self.audioWriterInputSingle);
    
    /*3***********添加audioWriterInputOnlySingle*************/
    if ([self.audioSingleWriter canAddInput:self.audioWriterInputSingle]) {
        [self.audioSingleWriter addInput:self.audioWriterInputSingle];
    }
    
    
}


#pragma mark -- delegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    @autoreleasepool {
        static int frame = 0;
        _cmTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        if( self.isRecording &&( self.videoWriter.status != AVAssetWriterStatusWriting ||  self.audioWriter.status != AVAssetWriterStatusWriting ))
        {
            [self.videoWriter startWriting];
            [self.videoWriter startSessionAtSourceTime:_cmTime];
            
            [self.audioWriter startWriting];
            [self.audioWriter startSessionAtSourceTime:_cmTime];
        }
        if (self.isAudioSingleRecording && self.audioSingleWriter.status != AVAssetWriterStatusWriting) {
            [self.audioSingleWriter startWriting];
            [self.audioSingleWriter startSessionAtSourceTime:_cmTime];
        }
        
        if (!CMSampleBufferDataIsReady(sampleBuffer))
            return;
        // 增加sampleBuffer的引用计时,这样我们可以释放这个或修改这个数据，防止在修改时被释放
        CFRetain(sampleBuffer);
        if (captureOutput == _videoOutput)
        {
            if( self.videoWriter.status > AVAssetWriterStatusWriting )
            {
                NSLog(@"Warning: writer status is %ld", (long)self.videoWriter.status);
                if( self.videoWriter.status == AVAssetWriterStatusFailed ){
                    NSLog(@"Error: %@", self.videoWriter.error);
                }
                return;
                
            }
            if ([self.videoWriterInput isReadyForMoreMediaData]){
                
                if( ![self.videoWriterInput appendSampleBuffer:sampleBuffer] ){
                    NSLog(@"Unable to write to video input");
                }
                else{
                    
                    NSLog(@"already write vidio");
                }
            }
        }
        if (captureOutput == _audioOutput)
        {
            
            if( self.videoWriter.status > AVAssetWriterStatusWriting || self.audioWriter.status > AVAssetWriterStatusWriting)
            {
                NSLog(@"Warning: writer status is %ld", (long)self.videoWriter.status);
                if( self.videoWriter.status == AVAssetWriterStatusFailed )
                    NSLog(@"Error: %@", self.videoWriter.error);
                if (self.audioWriter.status == AVAssetWriterStatusFailed) {
                     NSLog(@"Error: %@", self.audioWriter.error);
                }
                return;
            }
            
            if ([self.audioWriterInput isReadyForMoreMediaData]){
                if( ![self.audioWriterInput appendSampleBuffer:sampleBuffer] ){
                    NSLog(@"Unable to write to audio input");
                }
                else{
                    NSLog(@"already write audio");
                }
            }
            if ([self.audioWriterInputOnly isReadyForMoreMediaData]){
                
                if( ![self.audioWriterInputOnly appendSampleBuffer:sampleBuffer] ){
                    NSLog(@"Unable to write to audioOnly input");
                }
                else{
                    NSLog(@"already write audioOnly");
                }
            }
            
            if ([self.audioWriterInputSingle isReadyForMoreMediaData]){
                
                if( ![self.audioWriterInputSingle appendSampleBuffer:sampleBuffer] ){
                    NSLog(@"Unable to write to audioSingle input");
                }
                else{
                    NSLog(@"already write audioSingle");
                }
            }
        }
        frame ++;
        CFRelease(sampleBuffer);
        
    }
}



#pragma mark -- event method
- (NSString *)getUploadFileWithType:(NSString *)type fileType:(NSString *)fileType content:(NSString*)content{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate * NowDate = [NSDate dateWithTimeIntervalSince1970:now];
    ;
    NSString * timeStr = [formatter stringFromDate:NowDate];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@-%@.%@",type,content,timeStr,fileType];
    return fileName;
}

#pragma mark -- public method
-(void)startWriting{
    self.isRecording = YES;
}

-(void)stopWriting{
    self.isRecording = NO;
    NSURL *audioURL = [NSURL URLWithString:self.audioPath];
    NSURL *videoURL = [NSURL URLWithString:self.videoPath];
    NSString *audioName = self.audioName;
    NSString *videoName = self.videoName;
    
    NSString *content = @"";
    for (int i = 0; i < 8; i++) {
        if (i == 0) {
            content = _digitalQueue[i];
        } else {
            content = [NSString stringWithFormat:@"%@-%@",content,_digitalQueue[i]];
        }
    }
    audioName = [self getUploadFileWithType:self.userName fileType:@"wav" content:content];
    videoName = [self getUploadFileWithType:self.userName fileType:@"mp4" content:content];
    [self.videoWriter finishWritingWithCompletionHandler:^{
        NSLog(@"videowriter finished");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
                if ( status == PHAuthorizationStatusAuthorized ) {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        
                        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
                    } completionHandler:^( BOOL success, NSError *error ) {
                        if ( ! success ) {
                            NSLog( @"Could not save movie to photo library: %@", error );
                        }else{
                            NSLog(@"视频保存成功");
                            //                            //[self uploadVideoWithName:videoName urlStr:videoURL.absoluteString];
                        }
                    }];
                }
            }];
        });
       
    }];

    
    [self.audioWriter finishWritingWithCompletionHandler:^{
//        popWaitingWithHint(@"等待上传完成...");
        [self uploadVideoWithName:audioName urlStr:audioURL.absoluteString];
    }];
    
    self.videoWriter  = nil;
    self.audioWriter = nil;
   [self initVideoAudioWriter];  
}

-(void)startAudioSingleWriting{
    self.isAudioSingleRecording = YES;
}

-(void)stopAudioSingleWriting:(BOOL)isAutoStart{
    self.isAudioSingleRecording = NO;
    NSString *audioName = self.audioSingleName;
    NSString *content = _digitalQueue[_index];
    _index++;
    audioName = [self getUploadFileWithType:self.userName fileType:@"wav" content:content];
    NSString *audioUrlStr = self.audioSinglePath;
        [self.audioSingleWriter finishWritingWithCompletionHandler:^{
            [self uploadVideoWithName:audioName urlStr:audioUrlStr];
        }];
    
    self.audioWriterInputSingle  = nil;
    [self initAudioSingleWriter];
    
    if (isAutoStart) {
        [self startAudioSingleWriting];
    } else {
        _index = 0;
    }
}


-(void) uploadVideoWithName:(NSString*)videoName urlStr:(NSString *)urlStr
{
    NSData *videoData = [NSData dataWithContentsOfFile:urlStr];
    //    videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:videoName]];
    
    NSMutableDictionary* requestObject = [NSMutableDictionary new];
    [requestObject setObject:videoName forKey:@"file_name"];
    [requestObject setObject:[[NSString alloc] initWithData:[videoData base64EncodedDataWithOptions:0] encoding:NSUTF8StringEncoding]  forKey:@"file_content"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.3.88:8890/upload"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestObject options:0 error:nil];
    NSString* requestJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSData* httpBody = [requestJSON dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:httpBody];
    [request setValue:[NSString stringWithFormat:@"%u", (unsigned)[httpBody length]]
   forHTTPHeaderField:@"Content-Length"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSLog(@"----%@----",response);
        NSLog(@"----%@----",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if ([videoName rangeOfString:@"mp4"].length > 0) {
//            dismissWaiting();
        }
        if (connectionError) {
//            popError(@"网络异常！请确保使用的是WIFI！");
            NSLog(@"----%@----",connectionError);
            
        }
        
    }];
    
    //    popWaitingWithHint(@"正在上传...");
}


@end
