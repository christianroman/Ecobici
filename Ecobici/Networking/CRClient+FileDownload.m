//
//  CRClient+FileDownload.m
//  Ecobici
//
//  Created by Christian Roman on 31/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "CRClient+FileDownload.h"
#import "CRClient+Requests.h"

@implementation CRClient (FileDownload)

/*
- (NSURLSessionDownloadTask *)downloadFileFromURL:(NSURL *)URL
                                   withResumeData:(NSData *)resumeData
                                          success:(void(^)(NSURL *fileURL))success
                                          failure:(void(^)(NSError *error, NSData *resumeData))failure
 */
- (NSURLSessionDownloadTask *)downloadFileFromURL:(NSURL *)URL
                                       completion:(CRDownloadCompletionBlock)completion
{
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithRequest:request
                                                                  progress:nil
                                                               destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                                   
                                                                   NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
                                                                   return [documentsDirectoryPath URLByAppendingPathComponent:[targetPath lastPathComponent]];
                                                                   
                                                                   
                                                               } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                                                   
                                                                   if (!completion) {
                                                                       return;
                                                                   }
                                                                   if (response) {
                                                                       completion(filePath, nil);
                                                                   } else {
                                                                       completion(nil, nil);
                                                                   }
                                                                   
                                                               }];
    [downloadTask resume];
    return downloadTask;
}


/*
- (NSURLSessionDownloadTask *)downloadAssetWithURL:(NSURL *)URL
                                        completion:(fetchCompletionBlock)completion
                                         failBlock:(fetchFailBlock)failBlock
{
    
}
 */

@end
