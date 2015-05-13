//
//  OGLDynamicView.h
//  OGLUIKit
//
//  Created by samuel on 26/08/2014.
//  Copyright (c) 2014 SDS. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol OpenGLViewDelegate,OpenGLContextDelegate,OpenGLRenderer;


@interface OpenGLDynamicView : NSOpenGLView
@property(weak,nonatomic) id<OpenGLContextDelegate> viewDelegate;
@property(assign,readonly) BOOL isOpenGLContextInitialized;
- (instancetype)init;
- (instancetype)initWithFrame:(NSRect)frameRect;
- (void)createOpenGLContextWithDelegate:(id<OpenGLContextDelegate>)delegate;
@end


@protocol OpenGLContextDelegate
- (void)didCreateOpenGLContext:(id)userInfo;
- (void)renderForTime:(const CVTimeStamp*)outputTime;
- (void)didUpdateWindowRect:(NSRect)rect;
- (void)windowWillClose:(NSNotification*)notification;
@end