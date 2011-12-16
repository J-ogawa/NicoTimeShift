//
//  AppDelegate.h
//  NicoTimeShift
//
//  Created by 小川 洸太郎 on 11/12/02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GetComment.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, GetCommentDelegate>{
    IBOutlet NSTextField *field;
    IBOutlet NSMatrix *matrix;
    IBOutlet NSButton *button;
    IBOutlet NSProgressIndicator *indicator;
    IBOutlet NSTextField *label;
    GetComment *gc;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)go:(id)sender;
-(void)startIndicator;



@end
