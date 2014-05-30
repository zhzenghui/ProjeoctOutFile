//
//  ZHAppDelegate.m
//  ProjeoctOutFile
//
//  Created by bejoy on 14-5-15.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "ZHAppDelegate.h"
#import "NSDate+Helper.h"



#define APP_KEY     @"9hscq6j7gb1e4tw"
#define APP_SECRET  @"kuuv066na9ebq1m"

#define KCURRENT @"current"

@implementation ZHAppDelegate


#pragma mark dropbox


- (IBAction)didPressLink:(id)sender {
    
    DBAccount *linkedAccount = [[DBAccountManager sharedManager] linkedAccount];
    if (linkedAccount) {
        NSLog(@"App already linked");
    } else {
        [[DBAccountManager sharedManager] linkFromWindow:[self window]
                                     withCompletionBlock:^(DBAccount *account) {
                                         if (account) {
                                             NSLog(@"App linked successfully!");
                                             
                                             
                                         }
                                     }];
    }
}


- (IBAction)crateFolder:(id)sender {
    
    

    NSError *error = [[NSError alloc] init];
    
    
    DBPath *path = [[DBPath root] childPath:_projectTextField.stringValue];
    
    BOOL cb = [[DBFilesystem sharedFilesystem] createFolder:path error:&error];
    NSLog(@"创建项目：%hhd", cb);
    
    
}


- (IBAction)cleanCurrentFolder:(id)sender {
    
    NSError *error = [[NSError alloc] init];
    
    
    NSString *filePath3 = [NSString stringWithFormat:@"/%@/%@/100-iphone.plist", _projectTextField.stringValue, KCURRENT];
    NSString *filePath4 = [NSString stringWithFormat:@"/%@/%@/download.html", _projectTextField.stringValue, KCURRENT];
    
    
    NSArray *pathArray = @[filePath3, filePath4];
    
    
    
    
    for (NSString *p in pathArray) {
        
        DBPath *path = [[DBPath root] childPath:p];
        BOOL b = [[DBFilesystem sharedFilesystem] deletePath:path error:&error];
        NSLog(@"删除%@：%hhd", p, b);
    }
    
}

-(IBAction)cleanFolder:(id)sender
{

    NSError *error = [[NSError alloc] init];

    //  删除当前项目的问题
    NSString *filePath1 = [NSString stringWithFormat:@"/%@/%@/100-iphone.plist", _projectTextField.stringValue, _versionTextField.stringValue];
    NSString *filePath2 = [NSString stringWithFormat:@"/%@/%@/download.html", _projectTextField.stringValue, _versionTextField.stringValue];


    
    NSArray *pathArray = @[filePath1, filePath2];
    

    
    
    for (NSString *p in pathArray) {
        
        DBPath *path = [[DBPath root] childPath:p];
        BOOL b = [[DBFilesystem sharedFilesystem] deletePath:path error:&error];
        NSLog(@"删除%@：%hhd", p, b);        
    }
    
    
}

- (void)writeDropboxFile:(NSString *)string fileName:(NSString *)fileName type:(int)type
{


       __block NSError *error = [[NSError alloc] init];

        DBPath *newPath = [[DBPath root] childPath:fileName];
    dispatch_async(dispatch_get_main_queue(), ^{


        DBFile *file = [[DBFilesystem sharedFilesystem] createFile:newPath error:&error];
        [file writeString:string error:nil];
        
        
        if (file) {
            _textView.string = [NSString stringWithFormat: @"创建%@成功", fileName];
        }
        else {
            _textView.string = [NSString stringWithFormat: @"创建%@失败", fileName];
        }

    
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *fileStr = [filesystem fetchShareLinkForPath:newPath shorten:NO error:nil];
        if (fileStr) {

            NSString *string = [fileStr stringByReplacingOccurrencesOfString:@"www.dropbox.com" withString:@"dl.dropboxusercontent.com"];
            
            if (  type == 0   ) {
                _plistUrlTextField.stringValue = string;
            }
            else if ( type == 1 )
            {
                _downloadUrlTextField.stringValue = string;
            }
            self.textView.string = [self.textView.string stringByAppendingString:fileStr];

        }
    });

}

- (void)copyDropboxFile:(NSString *)string fileName:(NSString *)fileName type:(int)type
{

    NSError *error = [[NSError alloc] init];
    
    //  删除当前项目的问题
    NSString *filePath1 = [NSString stringWithFormat:@"/%@/%@/100-iphone.plist", _projectTextField.stringValue, _versionTextField.stringValue];
    NSString *filePath2 = [NSString stringWithFormat:@"/%@/%@/download.html", _projectTextField.stringValue, _versionTextField.stringValue];
    
    DBPath *path1 = [[DBPath root] childPath:filePath1];
    DBPath *path2 = [[DBPath root] childPath:filePath2];
    
    BOOL b1 = [[DBFilesystem sharedFilesystem] deletePath:path1 error:&error];
    BOOL b2 = [[DBFilesystem sharedFilesystem] deletePath:path2 error:&error];
    
    NSLog(@"删除plist：%hhd", b1);
    NSLog(@"删除download：%hhd", b2);
    
}



#pragma mark output =


-(void)outPlist:(BOOL)isPublish
{
    NSError *error = nil;
    
    NSString *path = [[NSBundle mainBundle]  pathForResource:@"100-iphone" ofType:@"plist"];
    
    NSString *s = [NSString stringWithContentsOfFile:path  encoding:NSUTF8StringEncoding error:&error];
    
    
    NSString *outString = [NSString stringWithFormat:s,
                           _ipaNameTextField.stringValue,
                           _bundleIDTextField.stringValue,
                           _versionTextField.stringValue,
                           _nameTextField.stringValue];
    
    
    
    NSString *filePath = [NSString stringWithFormat:@"/%@/%@/100-iphone.plist", _projectTextField.stringValue, _versionTextField.stringValue];
    if (isPublish) {
        filePath =  [NSString stringWithFormat:@"/%@/%@/100-iphone.plist", _projectTextField.stringValue, KCURRENT];
    }
    
    
    [self writeDropboxFile:outString fileName:filePath type:0];

}

- (IBAction)outputPlist:(id)sender
{

    [self outPlist:NO];
    
}


- (void)outDownload:(BOOL)isPublish
{
    NSError *error = nil;
    
    NSString *path = [[NSBundle mainBundle]  pathForResource:@"download" ofType:@"html"];
    
    NSString *s = [NSString stringWithContentsOfFile:path  encoding:NSUTF8StringEncoding error:&error];
    
    
    NSString *outString = [NSString stringWithFormat:s,
                           _nameTextField.stringValue,
                           _versionTextField.stringValue, _plistUrlTextField.stringValue, [NSDate stringFromDate:[NSDate date]]];
    
    
    
    NSString *filePath = [NSString stringWithFormat:@"/%@/%@/download.html", _projectTextField.stringValue, _versionTextField.stringValue];
    
    if (isPublish) {
        filePath = [NSString stringWithFormat:@"/%@/%@/download.html", _projectTextField.stringValue, KCURRENT];
    }
    
    
    [self writeDropboxFile:outString fileName:filePath type:1];
}

-(IBAction)outPutDownload:(id)sender
{
    [self outDownload:NO];
}



- (IBAction)pulishPlist:(id)sender {
    [self outPlist:YES];

}
- (IBAction)pulishDownload:(id)sender {
    [self outDownload:YES];

}

#pragma mark sh -

- (void)take:(NSString *)filePath currentPath:(NSString *)currentPath
{
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        self.textView.string =@"";
        
        self.isRunning = YES;
        
        @try {
            NSString *path = filePath; // [NSString stringWithFormat:@"%@/%@/%@", _pathTextField.stringValue,@"sh", @"copy_resourecs.sh"];
            NSString *shpath = currentPath;// [NSString stringWithFormat:@"%@/%@", _pathTextField.stringValue,@"sh"];
            
            
            //    NSString *path  = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"BuildScript" ofType:@"command"]];
            
            self.buildTask            = [[NSTask alloc] init];
            self.buildTask.launchPath = path;
            //            self.buildTask.environment =  shpath;
            self.buildTask.currentDirectoryPath  =shpath;
            
            // Output Handling
            //1
            self.outputPipe               = [[NSPipe alloc] init];
            self.buildTask.standardOutput = self.outputPipe;
            
            //2
            [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            
            //3
            [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[self.outputPipe fileHandleForReading] queue:nil usingBlock:^(NSNotification *notification){
                //4
                NSData *output = [[self.outputPipe fileHandleForReading] availableData];
                NSString *outStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
                //5
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.textView.string = [self.textView.string stringByAppendingString:[NSString stringWithFormat:@"\n%@", outStr]];
                    // Scroll to end of outputText field
                    NSRange range;
                    range = NSMakeRange([self.textView.string length], 0);
                    [self.textView scrollRangeToVisible:range];
                });
                //6
                [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            }];
            [self.buildTask launch];
            
            [self.buildTask waitUntilExit];
            
            
        }
        @catch (NSException *exception) {
            NSLog(@"Problem Running Task: %@", [exception description]);
        }
        @finally {
            //            [self.buildButton setEnabled:YES];
            //            [self.spinner stopAnimation:self];
            self.isRunning = NO;
        }
    });

}




- (IBAction)runCopyResources:(id)sender {
    

    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", _pathTextField.stringValue,@"sh", @"copy_resourecs.sh"];
    NSString *shpath = [NSString stringWithFormat:@"%@/%@", _pathTextField.stringValue,@"sh"];

    [self take:path currentPath:shpath];
    
}

- (IBAction)runBuild:(id)sender {
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", _pathTextField.stringValue,@"sh", @"build.sh"];
    NSString *shpath = [NSString stringWithFormat:@"%@/%@", _pathTextField.stringValue,@"sh"];
    
    
    [self take:path currentPath:shpath];
    
}
- (IBAction)runPulish:(id)sender {
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", _pathTextField.stringValue,@"sh", @"publish.sh"];
    NSString *shpath = [NSString stringWithFormat:@"%@/%@", _pathTextField.stringValue,@"sh"];
    
    
    [self take:path currentPath:shpath];
}

- (IBAction)runUploadIpa:(id)sender {
    
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", _pathTextField.stringValue,@"sh", @"uploadipa.sh"];
    NSString *shpath = [NSString stringWithFormat:@"%@/%@", _pathTextField.stringValue,@"sh"];
    
    
    [self take:path currentPath:shpath];
}


- (IBAction)runrelese:(id)sender {
    
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", _pathTextField.stringValue,@"sh", @"relese.sh"];
    NSString *shpath = [NSString stringWithFormat:@"%@/%@", _pathTextField.stringValue,@"sh"];
    
    
    [self take:path currentPath:shpath];
}



#pragma mark -


- (void)readData
{
    
//    plist
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSString *currentPath = [fm currentDirectoryPath];
    

    
    NSString *path =      [currentPath stringByAppendingString:@"/Info.plist"];
    NSDictionary *plistDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    
    
    
    
    
    
    
    _plistPath.stringValue =  plistDict[@"plist_path"];
    _pathTextField.stringValue =  plistDict[@"path"];
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: plistDict[@"plist_path"]];
    
    
    _nameTextField.stringValue = dict[@"CFBundleDisplayName"];
    _bundleIDTextField.stringValue = dict[@"CFBundleIdentifier"];
    _versionTextField.stringValue = dict[@"CFBundleVersion"];
    NSString *s  = dict[@"CFBundleIdentifier"];
    NSArray *a = [s componentsSeparatedByString:@"."];
    _projectTextField.stringValue = a.lastObject;
    
    
    _ipaNameTextField.stringValue  = [NSString stringWithFormat:@"%@%@%@.ipa",
                                      plistDict[@"ipa_url_path"], _projectTextField.stringValue,
                                      _versionTextField.stringValue];
    _qrCode.image = [NSImage imageNamed:@"Front.500.jpg"];

    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DBAccountManager *accountManager =
    [[DBAccountManager alloc] initWithAppKey:APP_KEY secret:APP_SECRET];
    [DBAccountManager setSharedManager:accountManager];

    
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    
    if (!account || !account.linked) {
        return ;
    }
    filesystem = [DBFilesystem sharedFilesystem];
    if (!filesystem) {
        filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
    }
    [self readData];
    
    

}


- (NSImage*) imageFromCGImageRef:(CGImageRef)image
{
    
    
    image = CGImageCreateCopy(image);
    
    
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    CGContextRef imageContext = nil;
    NSImage* newImage = nil; // Get the image dimensions.
    imageRect.size.height = CGImageGetHeight(image);
    imageRect.size.width = CGImageGetWidth(image);
    
    
    // Create a new image to receive the Quartz image data.
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    [newImage lockFocus];

    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image); [newImage unlockFocus];

    return newImage;
}


- (IBAction)qrCode:(id)sender {
    
    

    if ( ! [_downloadUrlTextField.stringValue isEqualToString: @""]) {
        
        ZXMultiFormatWriter *w = [[ZXMultiFormatWriter alloc] init];
        
        ZXBitMatrix * bm = [w encode:_downloadUrlTextField.stringValue format:kBarcodeFormatQRCode width:500 height:500 error:nil];
        
        ZXImage *zximg = [ZXImage imageWithMatrix:bm];
        
        NSImage *img = [[NSImage alloc] initWithCGImage:zximg.cgimage size:NSMakeSize(500, 500)];
        
        
        _qrCode.image = img;
        
    }
    

}


- (void)printData
{
    NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:_qrCode.image];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    [attachment setAttachmentCell: attachmentCell ];
    
    
    NSString *string = [NSString stringWithFormat:@"\n%@", _downloadUrlTextField.stringValue];
    NSAttributedString *drawingString = [[NSAttributedString alloc]  initWithString:string attributes:nil];
    
    NSMutableAttributedString *prettyName;
    prettyName = (id)[NSMutableAttributedString attributedStringWithAttachment:
                      attachment];
    [prettyName appendAttributedString: drawingString];

    
    [[_textView textStorage] appendAttributedString:prettyName];

}

- (IBAction)copyData:(id)sender {
    
    NSPasteboard* pb=[NSPasteboard generalPasteboard];
    [pb clearContents];
    
    NSData *data = [_qrCode.image TIFFRepresentation];
    [pb setData:data forType:NSPasteboardTypePNG];
    
    NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:_qrCode.image];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    [attachment setAttachmentCell: attachmentCell ];

    
    NSString *string = [NSString stringWithFormat:@"\n%@", _downloadUrlTextField.stringValue];
    NSAttributedString *drawingString = [[NSAttributedString alloc]  initWithString:string attributes:nil];

    NSMutableAttributedString *prettyName;
    prettyName = (id)[NSMutableAttributedString attributedStringWithAttachment:
                      attachment];
    [prettyName appendAttributedString: drawingString];

    
    
    
    
//      print
    [[_textView textStorage] appendAttributedString:prettyName];
//
//    
////    copy
//    NSData *rtfData = [prettyName RTFFromRange:NSMakeRange(0, [prettyName length])
//                 documentAttributes:nil];
//    [pb setData:rtfData forType:NSRTFPboardType];
    
    //    [pb setData:rtf forType:NSPasteboardTypeRTF];
//    if (rtf) {
//        [pb declareTypes:[NSArray arrayWithObjects:NSPasteboardTypeRTF, NSPasteboardTypeString, NSPasteboardTypePNG, nil] owner:self];
//        [pb setData:rtf forType:NSRTFPboardType];
//    } 

}



@end
