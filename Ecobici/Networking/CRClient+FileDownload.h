//
//  CRClient+FileDownload.h
//  Ecobici
//
//  Created by Christian Roman on 31/01/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import "CRClient.h"
#import "CRCompletionBlocks.h"

@interface CRClient (FileDownload)

- (NSURLSessionDownloadTask *)downloadFileFromURL:(NSURL *)URL completion:(CRDownloadCompletionBlock)completion;

@end
