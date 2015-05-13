//
//  OGLStaticWindow.h
//  OGLUIKit
//
//  Created by samuel on 26/08/2014.
//  Copyright (c) 2014 SDS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OpenGLViewDelegate;
@class OpenGLStaticView;

/*
 * Static OpenGL View
 */
@interface OpenGLStaticWindow : NSWindow

@property(strong,nonatomic) OpenGLStaticView *myOpenGLView;
@property(weak,nonatomic) id<OpenGLViewDelegate> openGLDelegate;

- (instancetype)initWithFrame:(CGRect)frame
                     delegate:(id<OpenGLViewDelegate>)delegate;
- (instancetype)initWithFrame:(CGRect)frame
                     renderer:(id)renderer
                 viewDelegate:(id)delegate;
@end

