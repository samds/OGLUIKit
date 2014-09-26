//
//  OGLDynamicView.h
//  OGLUIKit
//
//  Created by samuel de santis on 26/08/2014.
//  Copyright (c) 2014 Samuel DE SANTIS. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol OpenGLViewDelegate,OpenGLDynamicViewDelegate,OpenGLRenderer;


@interface OpenGLDynamicView : NSOpenGLView
@property(weak,nonatomic) id<OpenGLDynamicViewDelegate> viewDelegate;
@property(assign,readonly) BOOL isOpenGLContextInitialized;
- (id)initWithFrame:(NSRect)frame
           delegate:(id<OpenGLDynamicViewDelegate>)delegate;
@end


@protocol OpenGLDynamicViewDelegate
- (void)didCreateOpenGLContext:(id)userInfo;
- (void)renderForTime:(const CVTimeStamp*)outputTime;
- (void)didUpdateWindowRect:(NSRect)rect;
- (void)windowWillClose:(NSNotification*)notification;
@end