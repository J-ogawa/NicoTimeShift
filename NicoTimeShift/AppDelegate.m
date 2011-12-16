//
//  AppDelegate.m
//  NicoTimeShift
//
//  Created by 小川 洸太郎 on 11/12/02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#define CHROME 0
#define SAFARI 1
#define FIREFOX 2

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    
}

- (IBAction)go:(id)sender{
    [label setStringValue:@""];
    //[self performSelectorInBackground:@selector(startAnimation:) withObject:nil];
      [indicator startAnimation:self];
    //Matrixから選択ブラウザ取得
    NSInteger browser = [matrix selectedRow];
    [gc release];
    //
    gc = [[GetComment alloc]init];
    [gc setDelegate:self]; 
    [gc getMovieComment:browser lvNumber:[field stringValue]];
    //Cookie取得(user_session)
       
    
}

-(void)startIndicator{
    [indicator startAnimation:self];
}

-(void)stopIndicator{
    [indicator stopAnimation:self]; 
    [label setStringValue:@"Complete"];
    //[gc release];
}

-(void)screenError{
     [indicator stopAnimation:self]; 
    NSAlert *alert = [ NSAlert alertWithMessageText : @"rtmpdumpをインストールしてね！\nmacports経由とかがいいのかな？"
                                      defaultButton : @"OK"
                                    alternateButton : @"Cancel"
                                        otherButton : @"Other"
                          informativeTextWithFormat : @"Message %@ %d",@"HogeHoge",1];
	
	
    [alert beginSheetModalForWindow:self.window 
                      modalDelegate:self 
                     didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
                        contextInfo:nil];
}

- (void) alertDidEnd:(NSAlert *)alert 
          returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if(returnCode == NSAlertDefaultReturn) {
        NSLog(@"NSAlertDefaultReturn");
    }
    else if(returnCode == NSAlertAlternateReturn) {
        NSLog(@"NSAlertAlternateReturn");
    }
    else if(returnCode == NSAlertOtherReturn) {
        NSLog(@"NSAlertOtherReturn");
    }
    else if(returnCode == NSAlertErrorReturn) {
        NSLog(@"NSAlertErrorReturn");
    }
      //  [gc release];
}



@end
