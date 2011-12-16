//
//  Comment.m
//  NicoTimeShift
//
//  Created by 小川 洸太郎 on 11/12/02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GetComment.h"
#import "sqlite3.h"
#import "RegexKitLite.h"
//#import "RKLMatchEnumerator.h"

#define CHROME 0
#define SAFARI 1
#define FIREFOX 2
@implementation GetComment


@synthesize sessionId;
@synthesize delegate;
@synthesize keepString;
@synthesize dataStream;
@synthesize rtmpdumpPath;
@synthesize threadId;
@synthesize TICKET;

-(NSString *)getMovieComment:(NSInteger)browser lvNumber:(NSString *)lvNum{
    // BOOL isRtmpdumpOk = [self checkRtmpdump];
    
    
        lv = [[NSString alloc]initWithString: lvNum];
        isOpen = NO;
        self.keepString = @"";
        [self getUserSession:browser];
        
        [self getXml];//,@"didn't get xml.");
        [self getComment];//,@"didn't get comment.");
        [self getMovie];//,@"didn't get movie.");
        //
        //[delegate stopIndicator]; 
   
       
    return @"ok";
}
/*
- (BOOL)checkRtmpdump{
    
    NSString *a_home_dir = NSHomeDirectory();
    taskWhich = [[NSTask alloc]init];
    pipeWhich = [[NSPipe alloc]init];
    NSPipe *pipeError = [[NSPipe alloc]init];
    [taskWhich setStandardOutput:pipeWhich];
    [taskWhich setStandardError:pipeError];
    [taskWhich setLaunchPath: @"/usr/bin/which"];
    
    [taskWhich setCurrentDirectoryPath:a_home_dir];
    
    
    [taskWhich setEnvironment:[NSDictionary dictionaryWithObject:@"/opt/local/bin:/opt/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/git/bin:/usr/X11/bin" forKey:@"PATH"]];
    //[taskWhich setArguments: [NSArray arrayWithObjects: @"-c", @"/bin/ls", nil]];
    [taskWhich setArguments: [NSArray arrayWithObjects: @"rtmpdump", nil]];
    
    [taskWhich launch];
    
    // [taskWhich waitUntilExit];
    
    NSData *dataOutput = [[pipeWhich fileHandleForReading] readDataToEndOfFile];
    
    //fh   = [pipe fileHandleForReading];
    //result_data = [fh availableData];
    NSString *result_str  = [[[NSString alloc]initWithData:dataOutput encoding:NSUTF8StringEncoding]autorelease];
    NSLog(@"result_str : %@",result_str);
    
    NSData*   dataErr = [[pipeError fileHandleForReading ] readDataToEndOfFile];
    NSString* strErr  = [[NSString alloc] initWithData:dataErr encoding:NSUTF8StringEncoding];
    NSLog(@"std err --\n%@",strErr);
    [strErr release];
    [pipeError release];
    
    
    //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readDataWhich:) name:NSFileHandleReadCompletionNotification object:nil];
    // [[pipeWhich fileHandleForReading] readInBackgroundAndNotify];
    
    if(![result_str isEqualToString:@""]){
        self.rtmpdumpPath = result_str;
        self.rtmpdumpPath = [self.rtmpdumpPath stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSLog(@"rtmpDumpPath : %@", self.rtmpdumpPath);
        return YES;
    }else{
        return NO;
    }
    
    
}
*/
- (void)readDataWhich:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] valueForKey:NSFileHandleNotificationDataItem];
    
	NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    NSLog(@"%@",string);
    
    
    
    
    if ( [taskWhich isRunning] ) {
        [[pipeWhich fileHandleForReading] readInBackgroundAndNotify];
        NSLog(@"task inRunning");
        return;
    } else {
        //      NSLog(@"doTask end taskIndex : %d", taskIndex);
        [taskWhich release];
        //pipe = nil;
        [pipeWhich release];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        taskIndex++;
        if(taskIndex == [URL count]){
            
        }else{
            //[self doTask];
        }
        
        
        
    }
    
    
    
}

-(BOOL)getXml{
    NSString *urlString = [NSString stringWithFormat:@"http://watch.live.nicovideo.jp/api/getplayerstatus?v=%@", lv];

    NSURL *urlLogin = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequestLogin = [[NSMutableURLRequest alloc]initWithURL:urlLogin];
    
    [urlRequestLogin setHTTPMethod:@"POST"];
    [urlRequestLogin setValue:sessionId forHTTPHeaderField:@"Cookie"];//:[sessionId dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse* responseLogin;
    NSError* errorLogin = nil;
    NSData* resultLogin = [NSURLConnection sendSynchronousRequest:urlRequestLogin returningResponse:&responseLogin error:&errorLogin];
    
    xml= [[NSString alloc]initWithData:resultLogin encoding:NSUTF8StringEncoding];
    // xml = [NSString stringWithFormat:@"<xml>%@</xml>", xml];
    NSLog(@"xml : %@", xml);
    [urlRequestLogin release];
    return YES;
}

- (BOOL)getComment{
    //get addr, port, threadId
    [self getAPT];
    [self socketOpen:addr port:port];
    
    
    return YES;
}

- (BOOL)getAPT{
    //get addr, port, threadId
    NSError *error;
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc]initWithXMLString:xml options:NSXMLNodeOptionsNone error:&error];
    
    //  NSString *dockString = [NSString stringWithFormat:@"<xml>%@</xml>", xml];
    
    NSArray *temp = [xmlDoc nodesForXPath:@"/getplayerstatus/ms/addr/text()" error:&error];
    
    for (NSXMLNode *node in temp) {
        addr = [node stringValue];
        NSLog(@"addr : %@", addr);
    }
    
    temp = [xmlDoc nodesForXPath:@"/getplayerstatus/ms/port/text()" error:&error];
    
    for (NSXMLNode *node in temp) {
        port = [[node stringValue]integerValue];
        NSLog(@"port : %ld", port);
    }
    temp = [xmlDoc nodesForXPath:@"/getplayerstatus/ms/thread/text()" error:&error];
    
    for (NSXMLNode *node in temp) {
        self.threadId = [node stringValue];
        NSLog(@"threadId : %@", self.threadId);
    }
    
    temp = [xmlDoc nodesForXPath:@"/getplayerstatus/stream/base_time/text()" error:&error];
    NSAssert([temp count] == 1, @"base_time is not one.");
    NSInteger baseTime = [[[temp objectAtIndex:0] stringValue]integerValue];
    NSLog(@"baseTime : %ld", baseTime);
    temp = [xmlDoc nodesForXPath:@"/getplayerstatus/stream/open_time/text()" error:&error];
    NSAssert([temp count] == 1, @"open_time is not one.");
    NSInteger openTime = [[[temp objectAtIndex:0] stringValue]integerValue];
    NSAssert(baseTime == openTime, @"base_time is not equal open_time."); 
    temp = [xmlDoc nodesForXPath:@"/getplayerstatus/stream/start_time/text()" error:&error];
    NSAssert([temp count] == 1, @"start_time is not one.");
    NSInteger startTime = [[[temp objectAtIndex:0] stringValue]integerValue];
    [xmlDoc release];
    testTime = startTime - baseTime;
    NSLog(@"baseTime : %ld", baseTime);
    NSLog(@"startTime : %ld", startTime);
    NSLog(@"testTime : %ld", testTime);
    return YES;
}

- (void)socketOpen:(NSString *)ipAddress port:(NSInteger)portNo
{
    //   data = [NSMutableData data];
	if (isOpen == NO) {
        
		NSHost *host = [NSHost hostWithName:ipAddress];
		
		[NSStream getStreamsToHost:host port:portNo inputStream:&inputStream outputStream:&outputStream];		
		
		[inputStream retain];
		[outputStream retain];
        
		
        [inputStream setDelegate:self];
        [outputStream setDelegate:self];
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [inputStream open];
		[outputStream open];
        /*
         NSString *empty = @"<xml>";
         NSString *path = @"/Users/ogawakotaro/tempComment.xml";
         NSError *error;
         [empty writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
         */
        keepString = @"";
        commentArray = [[NSMutableArray alloc]init];
        vposArray = [[NSMutableArray alloc]init];
        userIdArray = [[NSMutableArray alloc]init];
		isOpen = YES;
	}
}

- (void)socketClose
{
	if (isOpen == YES) {
		[inputStream close];
		//[outputStream close];
		[inputStream release];
		[outputStream release];
		isOpen = NO;		
	}
}

- (BOOL)getMovie{
    // taskIndex = 0;
    URL = [[NSMutableArray alloc]init];
    tasks = [[NSMutableArray alloc]init];
    pipes = [[NSMutableArray alloc]init];
    
    NSString *URLRegex = @"(rtmp://.*?)</que>";
    NSString *TICKETRegex = @"<ticket>(.*)</ticket>";
    
    NSArray *matchURL = [xml componentsMatchedByRegex:URLRegex capture:1L];
    NSLog(@"matchURL : %@", matchURL);
    
    for (int i = 0; i < [matchURL count]; i++) {
        [URL addObject:(NSMutableString *)[[matchURL objectAtIndex:i] stringByReplacingOccurrencesOfString:@",/" withString:@"/mp4:"] ];
    }
    NSLog(@"URL : %@", URL);  
   
    //TICKET = [NSString stringWithFormat:@"S:%@",[xml stringByMatching:TICKETRegex capture:1L]];//S:を含む
    self.TICKET = [xml stringByMatching:TICKETRegex capture:1L];
     NSLog(@"TICKET : %@", self.TICKET); 
    //NSPipe       *pipe = [NSPipe pipe];
	//NSTask       *task = [[NSTask alloc] init];
	/*
     pipe = [NSPipe pipe];
     task = [[NSTask alloc] init];
     //タスクの準備
     [task setStandardOutput: pipe];
     [task setStandardError : pipe];
     [task setLaunchPath: @"/bin/sh"];
     */
    NSString *a_home_dir = NSHomeDirectory();
    NSLog(@"a_home_dir : %@", a_home_dir);
    NSLog(@"[URL count] : %ld", [URL count]);
    //
    [self doTask];
    
    return YES;
}

- (void)readData:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] valueForKey:NSFileHandleNotificationDataItem];
    
	NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    NSLog(@"string : %@",string);
    for (int i = 0; i < [URL count]; i++) {
        
        
        if ( [[tasks objectAtIndex:i] isRunning] ) {
            [[[pipes objectAtIndex:i] fileHandleForReading] readInBackgroundAndNotify];
            NSLog(@"task inRunning");
            return;
        } else {
            NSLog(@"doTask end taskIndex : %d", taskIndex);
            //[task release];
            //pipe = nil;
            //[pipe release];
            //[[NSNotificationCenter defaultCenter] removeObserver:self];
            
            
        }
        
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [delegate stopIndicator]; 
    
}

-(void)doTask{
    NSLog(@"doTask start taskIndex : %d", taskIndex);
    
    NSString *a_home_dir = NSHomeDirectory();
    //NSMutableArray *tasks = [NSMutableArray array];
    //NSMutableArray *pipes = [NSMutableArray array];
    NSString *argument;
    NSString *rtmpdumpPath = [[NSBundle mainBundle] pathForResource:@"_rtmpdump" ofType:nil];
    for (int i = 0; i < [URL count]; i++) {
        NSTask *task = [[[NSTask alloc]init]autorelease];
        NSPipe *pipe = [[[NSPipe alloc]init]autorelease];
        [task setStandardOutput:pipe];
        
        [task setLaunchPath:@"/bin/sh"];
        if (i != 0) {
            [task setStandardInput:[pipes objectAtIndex:i - 1]];
        }
        /*
        if (i == 0) {
            argument = [NSString stringWithFormat:@"%@ -r \"%@\" -C S:\"%@\" -f \"MAC 10,0,32,18\" -s \"http://live.nicovideo.jp/liveplayer.swf?20100531\" -o %@/%@.flv", self.rtmpdumpPath, [URL objectAtIndex:i], self.TICKET, a_home_dir, lv];
        }else{
            argument = [NSString stringWithFormat:@"%@ -r \"%@\" -C S:\"%@\" -f \"MAC 10,0,32,18\" -s \"http://live.nicovideo.jp/liveplayer.swf?20100531\" -o %@/%@_%d.flv", self.rtmpdumpPath,[URL objectAtIndex:i], self.TICKET, a_home_dir, lv, i + 1];
        }
         */
        
        if (i == 0) {
            argument = [NSString stringWithFormat:@"%@ -r \"%@\" -C S:\"%@\" -f \"MAC 10,0,32,18\" -s \"http://live.nicovideo.jp/liveplayer.swf?20100531\" -o %@/%@.flv", rtmpdumpPath, [URL objectAtIndex:i], self.TICKET, a_home_dir, lv];
        }else{
            argument = [NSString stringWithFormat:@"%@ -r \"%@\" -C S:\"%@\" -f \"MAC 10,0,32,18\" -s \"http://live.nicovideo.jp/liveplayer.swf?20100531\" -o %@/%@_%d.flv", rtmpdumpPath, [URL objectAtIndex:i], self.TICKET, a_home_dir, lv, i + 1];
        }

        
        NSLog(@"argument : %@", argument);
        [task setArguments: [NSArray arrayWithObjects: @"-c", argument, nil]];
        [tasks addObject:task];
        [pipes addObject:pipe];
        
    }
    for (int i = 0; i < [URL count]; i++) {
        [[tasks objectAtIndex:i] launch];
    }
    
    //[task waitUntilExit];
    //[delegate addObNotifi];
    //NSData *dataOutput = [[[pipes objectAtIndex:[URL count] - 1] fileHandleForReading]readDataToEndOfFile];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readData:) name:NSFileHandleReadCompletionNotification object:nil];
    
    //    for (int i = 0; i < [URL count]; i++) {
    //      [[[pipes objectAtIndex:i] fileHandleForReading] readInBackgroundAndNotify];
    
    //  }
    
    [[[pipes objectAtIndex:[URL count] - 1 ]fileHandleForReading] readInBackgroundAndNotify];
    
}

-(BOOL)getUserSession:(NSInteger)browser{
    NSString *a_home_dir = NSHomeDirectory();
    NSString *cookiePath;
    
    
    if (browser == SAFARI) { //Safari
        
        cookiePath = [a_home_dir stringByAppendingPathComponent:@"Library/Cookies/Cookies.plist"];
        NSArray *cookieArray = [NSArray arrayWithContentsOfFile:cookiePath];
        
        for (NSDictionary *dic in cookieArray) {
            NSString *domain = [dic objectForKey:@"Domain"];
            NSString *name = [dic objectForKey:@"Name"];
            NSLog(@"domain : %@", domain);
            NSLog(@"name : %@", name);
            if ([domain isEqualToString:@".nicovideo.jp"] && [name isEqualToString:@"user_session"]) {
                self.sessionId = [NSString stringWithFormat:@"user_session=%@", [dic objectForKey:@"Value"]];
                NSLog(@"if ok");
            }
        }
        
        NSLog(@"cookieArray : %@", cookieArray);
        NSLog(@"sessionId : %@", self.sessionId);
    }
    else { //Chrome, Firefox
        sqlite3 *db_;
        
        
        if (browser == CHROME) {
            
            cookiePath = [a_home_dir stringByAppendingPathComponent:@"Library/Application Support/Google/Chrome/Default/Cookies"];
            NSLog(@"cookiePath : %@", cookiePath);
        }else{
            
            //Objcでファイル取得　検索＋取得
            NSFileManager *defaultFileManager = [NSFileManager defaultManager];
            NSString* dirPath = [a_home_dir stringByAppendingPathComponent:@"Library/Application Support/Firefox/Profiles"];
            
            NSError *error;
            NSArray *contents = [defaultFileManager contentsOfDirectoryAtPath:dirPath error:&error];
            
            NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:0];
            
            for (int i = 0; i < [contents count]; i++) {
                NSString *name = [contents objectAtIndex: i];
                NSString *cookiePathTmp = [NSString stringWithFormat:@"%@/%@/cookies.sqlite", dirPath, name];
                NSLog(@"cookiePathTmp : %@", cookiePathTmp);
                if([defaultFileManager fileExistsAtPath:cookiePathTmp]){
                    NSDictionary *fileAttribs = [defaultFileManager attributesOfItemAtPath:cookiePathTmp error:&error];
                    NSDate *date = [fileAttribs valueForKey:NSFileModificationDate];
                    if([newDate compare:date] == NSOrderedAscending){
                        newDate = date;  
                        cookiePath = cookiePathTmp;
                    }
                }
            }
        }
        if(sqlite3_open_v2([cookiePath UTF8String], &db_, SQLITE_OPEN_READONLY, nil) == SQLITE_OK){
            NSLog(@"cookiePath : %@", cookiePath);
            NSLog(@"succeed_open_databasefile");
        }else {
            // エラー処理
            NSLog(@"Error!");
            exit(-1);
        }
        NSString *sqlString;
        if(browser == CHROME){
            sqlString = [NSString stringWithString:@"select value from cookies where host_key = '.nicovideo.jp' and name = 'user_session' limit 1;"];
        }else {
            sqlString = [NSString stringWithString:@"select value from moz_cookies where host = '.nicovideo.jp' and name = 'user_session';"];
        }
        
        const char *sql_c = [sqlString cStringUsingEncoding:NSUTF8StringEncoding];
        
        sqlite3_stmt *statement;
        int a0 = sqlite3_prepare_v2(db_, sql_c, -1, &statement, NULL);
        if(a0 != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db_));
        //int a = sqlite3_step(statement);
        
        while (SQLITE_DONE != sqlite3_step(statement)) {
            
            
            const char *ch = (char*)sqlite3_column_text(statement, 0);
            self.sessionId = [NSString stringWithFormat:@"user_session=%@", [NSString stringWithCString:ch encoding:NSUTF8StringEncoding]];   
            NSLog(@"sessionId : %@", self.sessionId);
        }
        /*
         if(a != SQLITE_DONE)
         NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db_));
         */
        
        sqlite3_finalize(statement);
        
        sqlite3_close(db_);
        
    }
    return YES;
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    //NSMutableData *data = [[NSMutableData alloc]init];
    NSLog(@"stream: handleEvent: ok");
    NSLog(@"%u", eventCode);
    switch(eventCode) {
        case NSStreamEventOpenCompleted:{
            NSLog(@"NSStreamEventOpenCompleted");
            
            break;
        }
        case NSStreamEventHasBytesAvailable:
        {
            NSLog(@"NSStreamEventHasBytesAvailable");
            NSLog(@"----------\n\n\n\n\n\n");
            if (dataStream == nil) {
                dataStream = [[NSMutableData alloc] init];
            }
            uint8_t buf[1024];
            NSInteger len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:1024];
            //            NSLog()
            if(len) {    
                [dataStream appendBytes:(const void *)buf length:len];
                int bytesRead;
                bytesRead += len;
            } else {
                NSLog(@"No data.");
            }
            
            NSString *str = [[NSString alloc] initWithData:dataStream
                                                  encoding:NSUTF8StringEncoding];
            NSLog(@"str : %@", str);
            NSString *strReplace = [str stringByReplacingOccurrencesOfString:@"\0" withString:@"\n"];
            NSLog(@"strReplace : %@",strReplace);
            
            //XMLDocumentsにする
            
            //最後の改行で２つに分ける
            
            // 文字列strの中に@"\n"というパターンが存在するかどうか
            NSRange searchResult = [strReplace rangeOfString:@"\n"];
            if(searchResult.location == NSNotFound){
                // みつからない場
                self.keepString = [NSString stringWithFormat:@"%@%@", self.keepString, strReplace];
            }else{
                // みつかった場合の処
                NSRange range = [strReplace rangeOfString:@"\n" options:NSBackwardsSearch];
                NSLog(@"range.location : %ld\n", range.location);
                
                
                NSString *front = [strReplace substringToIndex:range.location];
                NSString *rear = [strReplace substringFromIndex:range.location + 1];
                NSLog(@"front : %@\n", front);
                NSLog(@"rear : %@\n", rear);
                
                // NSString *dockString = [NSString stringWithFormat:@"<xml>%@</xml>", strReplace];
                
                NSString *dockString = [NSString stringWithFormat:@"<xml>%@%@</xml>", self.keepString, front];
                
                //   [self.keepString release];
                self.keepString = [NSString stringWithString:rear];
                
                NSError *error;
                NSXMLDocument *xmlDoc = [[NSXMLDocument alloc]initWithXMLString:dockString options:NSXMLNodeOptionsNone error:&error];
                
                NSArray *temp = [xmlDoc nodesForXPath:@"/xml/chat/text()" error:&error];
                
                for (NSXMLNode *node in temp) {
                    [commentArray addObject:[node stringValue]];
                    NSLog(@"comment : %@", [node stringValue]);
                }
                
                temp = [xmlDoc nodesForXPath:@"/xml/chat/@vpos" error:&error];
                for (NSXMLNode *node in temp) {
                    [vposArray addObject:[node stringValue]];
                    NSLog(@"vpos : %@", [node stringValue]);
                }
                
                temp = [xmlDoc nodesForXPath:@"/xml/chat/@user_id" error:&error];
                for (NSXMLNode *node in temp) {
                    [userIdArray addObject:[node stringValue]];
                    NSLog(@"userId : %@", [node stringValue]);
                }
                
                temp = [xmlDoc nodesForXPath:@"/xml/chat[@premium=\"2\" and text()=\"/disconnect\"]" error:&error];
                [xmlDoc release];
                
                if([temp count] != 0){
                    [self socketClose];
                    
                    NSLog(@"commentArray count : %lu",[commentArray count]);
                    NSLog(@"OK");
                    
                    
                    //NSString → NSNumber →　
                    NSString *a_home_dir = NSHomeDirectory();
                    NSString *path = [NSString stringWithFormat:@"%@/comment_%@.txt", a_home_dir, lv];
                    NSString *empty = @"";
                    [empty writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
                    
                    NSFileHandle *aFileHandle;
                    //  NSString *aFile;
                    for (int i = 0; i < [commentArray count]; i++) {
                        
                        
                        //aFile = [NSString stringWithString:@"/Users/ogawakotaro/comment.txt"]; //setting the file to write to
                        //  aFile = [logFile stringByExpandingTildeInPath];
                        
                        aFileHandle = [NSFileHandle fileHandleForWritingAtPath:path]; //telling aFilehandle what file write to
                        [aFileHandle truncateFileAtOffset:[aFileHandle seekToEndOfFile]]; //setting aFileHandle to write at the end of the file
                        NSInteger vposInt = [[vposArray objectAtIndex:i]integerValue] - testTime * 100L;
                        NSString *time = [NSString stringWithFormat:@"%2ld:%2ld",vposInt/6000L, vposInt%6000L/100L];
                        
                        [aFileHandle writeData:[[NSString stringWithFormat:@"%@ %@ id:%@\n", time, [commentArray objectAtIndex:i],  [userIdArray objectAtIndex:i]]dataUsingEncoding:NSUTF8StringEncoding]]; //actually write the data
                    }
                    
                }
            }
            
            
            [str release];
            [dataStream release];        
            dataStream = nil;
        } break;
        case NSStreamEventHasSpaceAvailable:{
            NSLog(@"NSStreamEventHasSpaceAvailable");
            
            if (isOpen == YES) {
                NSString *str = [NSString stringWithFormat:@"<thread thread=\"%@\" version=\"20061206\" res_from=\"-1000\" />", self.threadId];
                //NSString *str = [text stringByAppendingString:eol];
                const uint8_t *rawstring = (const uint8_t *)[str UTF8String];
                //  NSString *rawstring2 = [NSString stringWithFormat:@"%@\0", rawstring];
                [outputStream write:rawstring maxLength:strlen((char *)rawstring)];
                uint8_t *rawString2[2];
                rawString2[0] = 0;
                rawString2[1] = 0;
                [outputStream write:rawString2 maxLength:1];
                [outputStream close];
                
            }	
            
            break;
        }
        case NSStreamEventErrorOccurred:{
            NSLog(@"NSStreamEventErrorOccurred");
            break;
        }
        case NSStreamEventEndEncountered:{
            NSLog(@"\n\n\n\nNSStreamEventEndCountered");
            break;
        }
            
    }
    
}


-(void)dealloc{
    self.sessionId = nil;
    self.delegate = nil;
    self.keepString = nil;
    self.dataStream = nil;
    self.rtmpdumpPath = nil;
    self.TICKET = nil;
    
    [xml release];
    //[addr release];
    
    [threadId release];
    [lv release];
    
    
    
    /*
     NSString *keepString;
     NSMutableArray *vposArray;
     NSMutableArray *commentArray;
     NSMutableArray *userIdArray;
     */  
    [URL release];
    //[TICKET release];
    
    [taskWhich release];
    [pipeWhich release];
    [tasks release];
    [pipes release];
    
    
    //    NSMutableData *dataStream;
    
    
    
    [super dealloc];
}

@end
