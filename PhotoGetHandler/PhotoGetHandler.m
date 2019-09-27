//
//  PhotoGetHandler.m
//  Test
//
//  Created by iMac on 2019/9/27.
//  Copyright © 2019 hotcoin. All rights reserved.
//

#import "PhotoGetHandler.h"

@interface PhotoGetHandler()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIViewController *con;
}

@end

@implementation PhotoGetHandler

-(instancetype)initWithController:(UIViewController *)controller{
    con = controller;
    
    return [self init];
}

-(void)chooseImage{
    [self showAlertView:@"选择图片" takePhotoMessage:@"拍一张" selectPhoteMessage:@"相册选择" isSelectVedio:NO];
}
-(void)chooseVedio{
    [self showAlertView:@"选择视频" takePhotoMessage:@"去录制" selectPhoteMessage:@"相册选择" isSelectVedio:YES];
}

-(void)showAlertView:(NSString *)title takePhotoMessage:(NSString *)takePhotoMessage selectPhoteMessage:(NSString *)selectPhoteMessage isSelectVedio:(BOOL)isSelectVedio{
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:takePhotoMessage style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (isSelectVedio) {
            [weakSelf takeVideo];
        }else{
            [weakSelf showWithType:UIImagePickerControllerSourceTypeCamera isVideo:NO];
        }
    }];
    UIAlertAction *selectPhotoAction = [UIAlertAction actionWithTitle:selectPhoteMessage style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (isSelectVedio) {
            [weakSelf showWithType:UIImagePickerControllerSourceTypeSavedPhotosAlbum isVideo:YES];
        }else{
            [weakSelf showWithType:UIImagePickerControllerSourceTypePhotoLibrary isVideo:NO];
        }
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertCon addAction:takePhotoAction];
    [alertCon addAction:selectPhotoAction];
    [alertCon addAction:cancleAction];
    
    [con presentViewController:alertCon animated:YES completion:nil];
}

- (void)showWithType:(UIImagePickerControllerSourceType)type isVideo:(BOOL)video{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = type;
    if (video) {
        picker.mediaTypes = [NSArray arrayWithObjects:@"public.movie",  nil];
    }
    [con presentViewController:picker animated:YES completion:nil];
}
-(void)takeVideo{
    UIImagePickerController *pickVc = [[UIImagePickerController alloc] init];
    pickVc.delegate = self;
    pickVc.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickVc.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    pickVc.videoQuality = UIImagePickerControllerQualityTypeMedium; //录像质量
    pickVc.videoMaximumDuration = 180.0f; //录像最长时间
    pickVc.mediaTypes = [NSArray arrayWithObjects:@"public.movie", nil];
    [con presentViewController: pickVc animated:YES completion:nil];
}

#pragma mark - UIImagePickerController的代理方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]){
        // 视频
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        // 获取本地视频url地址
        NSURL *mp4 = [VedioHandler convertToMp4WithUrl:videoURL];
//        NSData *data = [NSData dataWithContentsOfURL:mp4];
        if (self.selectedDone) {
            self.selectedDone(nil, mp4);
        }
    }else if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.image"]){
        UIImage *img = info[UIImagePickerControllerOriginalImage];
//        NSData *data = UIImageJPEGRepresentation(img, 1.0);
        if (self.selectedDone) {
            self.selectedDone(img, nil);
        }
    }
}
-(UIImage *)getShotImageFormVideoURL:(NSURL *)url{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *shotImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    return shotImage;
}
@end


@implementation VedioHandler

+(NSString *)fileName:(NSString *)name{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat   = @"YYYY-MM-dd-hh:mm:ss:SSS";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@-%@", str, name];
    
    return fileName;
}


+(NSURL *)convertToMp4WithAsset:(AVAsset *)asset{
    NSURL *mp4Url = nil;
    //    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:asset
                                                                          presetName:AVAssetExportPreset640x480];
    NSString *mp4Path = [NSString stringWithFormat:@"%@/%d%d.mp4", [self dataPath], (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
    mp4Url = [NSURL fileURLWithPath:mp4Path];
    exportSession.outputURL = mp4Url;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed: {
                NSLog(@"failed, error:%@.", exportSession.error);
            } break;
            case AVAssetExportSessionStatusCancelled: {
                NSLog(@"cancelled.");
            } break;
            case AVAssetExportSessionStatusCompleted: {
                NSLog(@"completed.");
                
                CGFloat size = [self getFileSize:mp4Url.path];
                NSString *sizeString;
                CGFloat sizemb= size/1024;
                if(size<=1024){
                    sizeString = [NSString stringWithFormat:@"%.2fKB",size];
                }else{
                    sizeString = [NSString stringWithFormat:@"%.2fMB",sizemb];
                }
                NSLog(@"视频大小---------%@", sizeString);
                NSLog(@"视频时长---------%lf", [self getVideoLength:mp4Url]);
            } break;
            default: {
                NSLog(@"others.");
            } break;
        }
        dispatch_semaphore_signal(wait);
    }];
    long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
    if (timeout) {
        NSLog(@"timeout.");
    }
    if (wait) {
        //dispatch_release(wait);
        wait = nil;
    }
    
    return mp4Url;
}
+ (NSURL *)convertToMp4WithUrl:(NSURL *)url{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    return [self convertToMp4WithAsset:avAsset];
}

+ (void) thumbnailImageForVideo:(NSURL *)videoURL image:(void(^)(UIImage *))resImg{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *thumbImage = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (resImg) {
                resImg(thumbImage);
            }
        }];
    });
}

+ (NSString*)dataPath{
    NSString *dataPath = [NSString stringWithFormat:@"%@/Library/appdata/chatbuffer", NSHomeDirectory()];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:dataPath]){
        [fm createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dataPath;
}

+ (CGFloat) getFileSize:(NSString *)fileUrl{
    NSLog(@"%@",fileUrl);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:fileUrl]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:fileUrl error:nil];//获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024;
    }else{
        NSLog(@"找不到文件");
    }
    return filesize;
}

//此方法可以获取视频文件的时长。
+ (CGFloat) getVideoLength:(NSURL *)URL{
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:URL];
    CMTime time = [avUrl duration];
    int second = ceil(time.value/time.timescale);
    return second;
}


@end
