//
//  ZHAppDelegate.h
//  ProjeoctOutFile
//
//  Created by bejoy on 14-5-15.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Dropbox/Dropbox.h>
#import "ZXingObjC.h"


@interface ZHAppDelegate : NSObject <NSApplicationDelegate>
{
    DBFilesystem *filesystem;
}
@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField *versionTextField;
@property (weak) IBOutlet NSTextField *projectTextField;
@property (weak) IBOutlet NSTextField *downloadUrlTextField;
@property (weak) IBOutlet NSTextField *plistUrlTextField;
@property (weak) IBOutlet NSTextField *ipaNameTextField;

@property (weak) IBOutlet NSTextField *bundleIDTextField;

@property (weak) IBOutlet NSTextField *pathTextField;
@property (weak) IBOutlet NSTextField *plistPath;
@property (weak) IBOutlet NSTextField *nameTextField;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSImageView *qrCode;

- (IBAction)qrCode:(id)sender;

/**
 * NSTask
 */
@property (nonatomic, strong) __block NSTask *buildTask;
@property (nonatomic) BOOL isRunning;
@property (nonatomic, strong) NSPipe *outputPipe;

@end
