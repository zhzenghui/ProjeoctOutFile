//
//  ZHAppDelegate.m
//  ProjeoctOutFile
//
//  Created by bejoy on 14-5-15.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "ZHAppDelegate.h"
#import "NSDate+Helper.h"
#import <Dropbox/Dropbox.h>

#define APP_KEY     @"9hscq6j7gb1e4tw"
#define APP_SECRET  @"kuuv066na9ebq1m"



@implementation ZHAppDelegate


#pragma mark dropbox
- (IBAction)createFile:(id)sender {
    DBPath *newPath = [[DBPath root] childPath:@"hello1.txt"];
    
    NSError *error = [[NSError alloc] init];

    DBFile *file = [[DBFilesystem sharedFilesystem] createFile:newPath error:&error];
    [file writeString:@"Hello World!" error:nil];
    
    
    if (file) {
        _textView.string = @"secuss";
    }
    else {
        _textView.string = @"f";
    }
}

- (IBAction)createProjectFoler:(id)sender {

    NSError *error = [[NSError alloc] init];
    DBPath *newPath = [[[DBPath root] childPath:@"app"] childPath:@"test"];
    bool b = [[DBFilesystem sharedFilesystem] createFolder:newPath error:&error];
    
    if (b) {
        _textView.string = @"secuss";
    }
    else {
        _textView.string = error.localizedDescription;
    }
}

- (IBAction)openFile:(id)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        
        DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
        
        if (!account || !account.linked) {
            return ;
        }

        DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
        if (!filesystem) {
            filesystem = [[DBFilesystem alloc] initWithAccount:account];
            [DBFilesystem setSharedFilesystem:filesystem];
        }
        
        
        DBPath *path = [[[[DBPath root] childPath:@"app"] childPath:@"sxc"] childPath:@"demo.txt"];
        
        DBFile *file = [filesystem openFile:path  error:nil];
        if (file) {
            _textView.string = [file readString:nil];
        }


    });

}
//   获取文件系统
- (IBAction)workingFiles:(id)sender {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
    
    
            DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
            
            if (!account || !account.linked) {


                return ;
            }
            
            // Check if shared filesystem already exists - can't create more than
            // one DBFilesystem on the same account.
            DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
            if (!filesystem) {
                filesystem = [[DBFilesystem alloc] initWithAccount:account];
                [DBFilesystem setSharedFilesystem:filesystem];
            }
        
        
            NSArray *contents = [filesystem listFolder:[DBPath root] error:nil];

            
            for (DBFileInfo *info in contents) {
                [self print:[NSString stringWithFormat:@"\t%@, %@", info.path, info.modifiedTime]
                  withColor:[NSColor colorWithDeviceRed:0 green:.75 blue:0 alpha:1]];
            }
        
    });
}

- (void)print:(NSString *)message withColor:(NSColor *)color {
    message = [NSString stringWithFormat:@"%@\n", message];
    NSDictionary *attributes = @{NSForegroundColorAttributeName : color};
    NSAttributedString *coloredMessage = [[NSAttributedString alloc] initWithString:message
                                                                         attributes:attributes];
    dispatch_async(dispatch_get_main_queue(), ^{
//        [[self.textView textStorage] appendAttributedString:coloredMessage];
//        [self.textView scrollRangeToVisible:NSMakeRange([[self.textView string] length], 0)];
        _textView.string = message;
    });
}


//   链接授权
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
- (IBAction)createDownloadFile:(id)sender {
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    
    if (!account || !account.linked) {
        return ;
    }
    
    DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
    if (!filesystem) {
        filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
    }
    
    
    DBPath *newPath = [[DBPath root] childPath:@"hello1.txt"];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        NSString *fileStr = [filesystem fetchShareLinkForPath:newPath shorten:NO error:nil];
        if (fileStr) {
            _textView.string = fileStr;
        }
    });

}
- (IBAction)createPlistFile:(id)sender {
    
}

- (IBAction)getDownloadFiles:(id)sender {
    
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    
    if (!account || !account.linked) {
        return ;
    }
    
    DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
    if (!filesystem) {
        filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
    }
    
    
    DBPath *newPath = [[DBPath root] childPath:@"hello1.txt"];
    
    DBFile *file = [filesystem openFile:newPath  error:nil];
    if (file) {
        _textView.string = [file readString:nil];
    }

}
- (IBAction)getPlistFile:(id)sender {
    
}

#pragma mark sh -

- (void)takeFilePath:(NSString *)filePath currentPath:(NSString *)currentPath
{
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        self.textView.string =@"";
        
        self.isRunning = YES;
        
        @try {
 
            //    NSString *path  = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"BuildScript" ofType:@"command"]];
            
            self.buildTask            = [[NSTask alloc] init];
            self.buildTask.launchPath = filePath;
            //            self.buildTask.environment =  shpath;
            self.buildTask.currentDirectoryPath  =currentPath;
            
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
                    
                    [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
         
                    
                    NSString *lineStr = @"-------------------------------------------------------------------";
                    self.textView.string = [self.textView.string stringByAppendingString:[NSString stringWithFormat:@"\n%@", lineStr]];

                });
                //6
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
    
    
    __block NSString *path = [NSString stringWithFormat:@"%@/%@/%@", _pathTextField.stringValue,@"sh", @"copy_resourecs.sh"];
    __block NSString *shpath = [NSString stringWithFormat:@"%@/%@", _pathTextField.stringValue,@"sh"];
    
    
    [self takeFilePath:path currentPath:shpath];
    
}
- (IBAction)runBuild:(id)sender {
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", _pathTextField.stringValue,@"sh", @"build.sh"];
    NSString *shpath = [NSString stringWithFormat:@"%@/%@", _pathTextField.stringValue,@"sh"];
    
    
    [self takeFilePath:path currentPath:shpath];
    
}
- (IBAction)runPulish:(id)sender {
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", _pathTextField.stringValue,@"sh", @"publish.sh"];
    NSString *shpath = [NSString stringWithFormat:@"%@/%@", _pathTextField.stringValue,@"sh"];
    
    
    [self takeFilePath:path currentPath:shpath];
}

- (IBAction)runrelese:(id)sender {
    
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", _pathTextField.stringValue,@"sh", @"relese.sh"];
    NSString *shpath = [NSString stringWithFormat:@"%@/%@", _pathTextField.stringValue,@"sh"];
    
    
    [self takeFilePath:path currentPath:shpath];
}


#pragma mark -


- (void)readData
{
    
//    plist
    
    NSString *plist = [NSString stringWithFormat:@"%@/%@/%@-Info.plist", _pathTextField.stringValue,
                       _nameTextField.stringValue,_nameTextField.stringValue];
    
    
    _plistPath.stringValue = plist;
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plist];
    
    
    _nameTextField.stringValue = dict[@"CFBundleDisplayName"];
    _bundleIDTextField.stringValue = dict[@"CFBundleIdentifier"];
    _versionTextField.stringValue = dict[@"CFBundleVersion"];
    NSString *s  = dict[@"CFBundleIdentifier"];
    NSArray *a = [s componentsSeparatedByString:@"."];
    _projectTextField.stringValue = a.lastObject;
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DBAccountManager *accountManager =
    [[DBAccountManager alloc] initWithAppKey:APP_KEY secret:APP_SECRET];
    [DBAccountManager setSharedManager:accountManager];

    
    [self readData];
}



- (void)writeFile:(NSString *)strFile isDownload:(BOOL)isDownload
{
    NSError *error =  nil;
    NSString *directory = @"/Users/lifeng/Desktop";
    
    NSString *filename = @"download.html";
    
    if ( ! isDownload) {
        filename = @"100-iphone.plist";
    }
    
    NSString *fullPath = [directory stringByAppendingPathComponent:filename];

    
    
    BOOL written = [strFile writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (written) {
        NSLog(@"Successfully written to file.");
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

- (IBAction)outDownloadFile:(id)sender {
    NSError *error = nil;
    
    NSString *path = [[NSBundle mainBundle]  pathForResource:@"download" ofType:@"html"];
    
    NSString *s = [NSString stringWithContentsOfFile:path  encoding:NSUTF8StringEncoding error:&error];
    
    
    NSString *outString = [NSString stringWithFormat:s,
                           _projectTextField.stringValue,
                           _versionTextField.stringValue, [NSDate stringFromDate:[NSDate date]]];
    

    [self writeFile:outString isDownload:YES];
    
}

- (IBAction)outPlistFile:(id)sender {
    
    NSError *error = nil;
    
    NSString *path = [[NSBundle mainBundle]  pathForResource:@"100-iphone" ofType:@"plist"];
    
    NSString *s = [NSString stringWithContentsOfFile:path  encoding:NSUTF8StringEncoding error:&error];
    
    
    NSString *outString = [NSString stringWithFormat:s,
                           _ipaNameTextField.stringValue,
                           _bundleIDTextField.stringValue,
                           _versionTextField.stringValue,
                           _projectTextField.stringValue];
    
    
    [self writeFile:outString isDownload:NO];

}

- (IBAction)outAll:(id)sender {
    
    [self outPlistFile:nil];
    [self outDownloadFile:nil];
    
    
}
@end
