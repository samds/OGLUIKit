//
//  OGLDynamicWindow.h
//  OGLUIKit
//
//  Created by samuel on 26/08/2014.
//  Copyright (c) 2014 SDS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OpenGLContextDelegate;
@class OpenGLDynamicView;


@interface OpenGLDynamicWindow : NSWindow

/*
 * The OpenGL view inside the window
 */
@property(strong,nonatomic) OpenGLDynamicView *myOpenGLView;

/*
 * The window's delegate.
 */
@property(weak,nonatomic) id<OpenGLContextDelegate> openGLDelegate;

/*
 * Initializes the window with the specified values.
 *
 * @param frame         Origin and size of the window’s content area
 *                      in screen coordinates.
 */
- (instancetype)initWithFrame:(CGRect)frame;

/*
 * Initializes the window with the specified values.
 *
 * @param frame         Origin and size of the window’s content area 
 *                      in screen coordinates.
 * @param delegate      OpenGL view's delegate (to get feedback about 
 *                      OpenGL context creation, resize operation, ...).
 */
- (instancetype)initWithFrame:(CGRect)frame
                     delegate:(id<OpenGLContextDelegate>)delegate;

/*
 * Switch between Full-Screen mode or windowed mode.
 */
- (void)toggleWindowMode;

/*
 * Display a borderless window that covers the whole screen.
 */
- (void)setFullScreen;

/*
 * Display a window with a title bar at the given origin and size.
 *
 * @param windowFrame   The frame rectangle for the window, 
 *                      including the title bar.
 */
- (void)setWindowedMode:(NSRect)windowFrame;

@end