//
//  PhotoGetHandler.h
//  Test
//
//  Created by iMac on 2019/9/27.
//  Copyright © 2019 hotcoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>


@class VedioHandler;
NS_ASSUME_NONNULL_BEGIN


typedef void(^SelectedDone)(UIImage *image, NSURL *mp4URL);
@interface PhotoGetHandler : NSObject
@property (nonatomic, copy)  SelectedDone  selectedDone;
-(instancetype)initWithController:(UIViewController *)controller;
-(void)chooseImage;
-(void)chooseVedio;
@end

NS_ASSUME_NONNULL_END



@interface VedioHandler : NSObject
//根据文件名，生成一个不重复的文件名
+ (NSString *)fileName:(NSString *)name;

/**
 获取压缩后的视频地址
 
 @param asset 传入AVAsset
 @return 返回压缩后的视频地址
 */
+ (NSURL *)convertToMp4WithAsset:(AVAsset *)asset;


/**
 获取压缩后的视频地址
 
 @param url 传入原始视频地址
 @return 返回压缩后的视频地址
 */
+ (NSURL *)convertToMp4WithUrl:(NSURL *)url;


/**
 根据视频地址获取缩略图
 
 @param videoURL 视频地址
 @param resImg 返回图片
 */
+ (void) thumbnailImageForVideo:(NSURL *)videoURL image:(void(^)(UIImage *))resImg;

//获取视频大小单位KB
+ (CGFloat) getFileSize:(NSString *)fileUrl;

//获取视频时长单位s
+ (CGFloat) getVideoLength:(NSURL *)URL;
@end
