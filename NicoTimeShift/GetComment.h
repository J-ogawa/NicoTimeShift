//
//  Comment.h
//  NicoTimeShift
//
//  Created by 小川 洸太郎 on 11/12/02.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GetCommentDelegate

@optional
-(void)stopIndicator;
-(void)screenError;
-(void)addObNotifi;

@end

@interface GetComment : NSObject <NSStreamDelegate>{
    id <GetCommentDelegate>delegate;
    NSString *sessionId;
    NSString *xml;
    NSString *addr;
    NSInteger port;
    NSString *threadId;
    NSString *lv;
    
    NSString *rtmpdumpPath;
    
    NSInputStream *inputStream;
	NSOutputStream *outputStream;
	BOOL isOpen;
    NSString *keepString;
    NSMutableArray *vposArray;
    NSMutableArray *commentArray;
    NSMutableArray *userIdArray;
    
    NSMutableArray *URL;
    NSString *TICKET;
    
    NSTask *taskWhich;
    NSPipe *pipeWhich;
    NSMutableArray *tasks;
    NSMutableArray *pipes;
    
    int taskIndex;
    
    NSMutableData *dataStream;
    NSInteger testTime;
}

-(NSString *)getMovieComment:(NSInteger)browse lvNumber:(NSString *)lv;
-(BOOL)checkRtmpdump;
-(BOOL)getXml;
-(BOOL)getUserSession:(NSInteger)browser;
-(BOOL)getAPT;
-(BOOL)getComment;
-(BOOL)getMovie;
-(void)socketOpen:(NSString *)ipAddress port:(NSInteger)portNo;
-(void)doTask;
@property(nonatomic,retain)NSString *sessionId;
@property(nonatomic,retain)id delegate;
@property(nonatomic,retain)NSString *keepString;
@property(nonatomic,retain)NSMutableData *dataStream;
@property(nonatomic,retain)NSString *rtmpdumpPath;
@property(nonatomic,retain)NSString *threadId;
@property(nonatomic,retain)NSString *TICKET;

@end
