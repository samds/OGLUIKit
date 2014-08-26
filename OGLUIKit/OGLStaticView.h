//
//  OGLStaticView.h
//  OGLUIKit
//
//  Created by samuel de santis on 26/08/2014.
//  Copyright (c) 2014 Samuel DE SANTIS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol OpenGLViewDelegate,OpenGLStaticViewDelegate;


@interface OpenGLStaticView : NSOpenGLView

@property(weak,nonatomic) id<OpenGLViewDelegate> openGLDelegate;


@property(weak,nonatomic) id renderer;
@property(weak,nonatomic) id<OpenGLStaticViewDelegate> viewDelegate;

- (id)initWithFrame:(NSRect)frame
           renderer:(id)renderer
           delegate:(id<OpenGLStaticViewDelegate>)delegate;
- (id)initWithFrame:(NSRect)frame delegate:(id<OpenGLViewDelegate>)delegate;
- (void)drawView;
- (void)drawRect:(NSRect)theRect;

@end


@protocol OpenGLStaticViewDelegate

- (void)didCreateOpenGLContext:(id)userInfo;
- (void)windowWillClose:(NSNotification*)notification;

@end