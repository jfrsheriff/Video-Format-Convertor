//
//  ViewController.m
//  Video format Conversion
//
//  Created by Jaffer Sheriff U on 1/5/16.
//  Copyright © 2016 Jaffer Sheriff U. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#define OUTPUT_FILE_NAME @"ConvetedVideoFile"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *inputVideoPath = [[NSBundle mainBundle] pathForResource:@"SampleVideo" ofType:@"mov"];
    NSURL *inputUrl = [NSURL fileURLWithPath:inputVideoPath];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* outputVideoPath = [NSString stringWithFormat:@"%@/%@.mp4", [paths objectAtIndex:0],OUTPUT_FILE_NAME];
    NSURL *outputURL = [NSURL fileURLWithPath:outputVideoPath];

    [self convertVideoToMP4WithInputURL:inputUrl outputURL:outputURL handler:^(AVAssetExportSession * exportSession) {
        if (exportSession.status == AVAssetExportSessionStatusCompleted)
        {
            NSLog(@"Conversion Success");
            NSData *data = [NSData dataWithContentsOfURL:outputURL];
            [self saveVideoData:data];
        }
        else
        {
            NSLog(@"Conversion Failed , Reason = %@", exportSession.error);
        }
    }];
}

#pragma Video Format Conversion
- (void)convertVideoToMP4WithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        handler(exportSession);
    }];
}

#pragma Save Video Data
-(void)saveVideoData:(NSData *) data
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",OUTPUT_FILE_NAME]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        BOOL isDeleted = [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:path] error:nil];
        NSLog(@"Deletion = %s", isDeleted ? "YES" : "NO");
    }
    [data writeToFile:path atomically:YES];
    NSLog(@"\n Saved the converted file in path %@",path);
}

#pragma Remove Video File
-(void)removeSavedVideoFileAtPath:filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        if ([[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:filePath] error:nil])
        {
            NSLog(@"Item Removed");
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
