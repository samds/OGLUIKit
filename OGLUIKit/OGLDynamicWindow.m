//
//  OGLDynamicWindow.m
//  OGLUIKit
//
//  Created by samuel on 26/08/2014.
//  Copyright (c) 2014 SDS. All rights reserved.
//

#import "OGLDynamicWindow.h"
#import "OGLDynamicView.h"

#define MINIMUM_WINDOW_SIZE NSMakeSize(320, 240)
#define DEFAULT_WINDOW_RECT NSMakeRect(0.0f, 0.0f, 800.0f, 600.0f)

////////////////////////////////////////////////////////////////////////////////
//                             Dynamic Window                                 //
////////////////////////////////////////////////////////////////////////////////

@interface OpenGLDynamicWindow ()
@property (assign,nonatomic) BOOL isFullScreen;
@property (assign,nonatomic) NSRect windowFrame;
@end

@implementation OpenGLDynamicWindow

/*
 * From Apple's Interface Builder User Guide
 * "Important: If you subsequently include an OpenGL view in one of your Cocoa
 * windows, be sure to disable the window’s “One Shot” option. The one-shot
 * option deletes the window object when it is hidden or miniaturized to the
 * dock. Unfortunately, destroying the window in this manner breaks the link
 * between the OpenGL drawing context and the window, which means the view can
 * no longer draw its contents. Disabling the one-shot option maintains the
 * connection and ensures that the OpenGL view has a place to render its
 * content."
 */
- (instancetype)initWithFrame:(CGRect)frame
                     delegate:(id<OpenGLContextDelegate>)delegate
{
    NSUInteger mask =     NSTitledWindowMask
    | NSClosableWindowMask
    | NSResizableWindowMask
    | NSMiniaturizableWindowMask ;
    
    self = [super initWithContentRect:frame
                            styleMask:mask
                              backing:NSBackingStoreBuffered
                                defer:YES];
    
    if (self) {
        NSWindow* window = self;
        // Minimum size for the window
        [window setMinSize:MINIMUM_WINDOW_SIZE];
        
        self.myOpenGLView =
        [[OpenGLDynamicView alloc] initWithFrame:frame];
        [self.myOpenGLView createOpenGLContextWithDelegate:delegate];
        
        [window.contentView addSubview:self.myOpenGLView];
        
        [self.myOpenGLView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *rightContraint =
        [NSLayoutConstraint constraintWithItem:self.myOpenGLView
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.myOpenGLView.superview
                                     attribute:NSLayoutAttributeLeading
                                    multiplier:1.0f
                                      constant:0.0f];
        NSLayoutConstraint *topContraint =
        [NSLayoutConstraint constraintWithItem:self.myOpenGLView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.myOpenGLView.superview
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0f
                                      constant:0.0f];
        NSLayoutConstraint *bottomContraint =
        [NSLayoutConstraint constraintWithItem:self.myOpenGLView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.myOpenGLView.superview
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0f
                                      constant:0.0f];
        NSLayoutConstraint *leftContraint =
        [NSLayoutConstraint constraintWithItem:self.myOpenGLView
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.myOpenGLView.superview
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0f
                                      constant:0.0f];
        
        [self.myOpenGLView.superview addConstraints:
         @[topContraint,leftContraint,rightContraint,bottomContraint]];
        
        // Init. variables
        self.isFullScreen = NO;
        self.windowFrame = window.frame;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    NSUInteger mask =     NSTitledWindowMask
    | NSClosableWindowMask
    | NSResizableWindowMask
    | NSMiniaturizableWindowMask ;
    
    self = [super initWithContentRect:frame
                            styleMask:mask
                              backing:NSBackingStoreBuffered
                                defer:YES];
    
    if (self) {
        NSWindow* window = self;
        // Minimum size for the window
        [window setMinSize:MINIMUM_WINDOW_SIZE];
        
        self.myOpenGLView =
        [[OpenGLDynamicView alloc] initWithFrame:frame];
        
        [window.contentView addSubview:self.myOpenGLView];
        
        [self.myOpenGLView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *rightContraint =
        [NSLayoutConstraint constraintWithItem:self.myOpenGLView
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.myOpenGLView.superview
                                     attribute:NSLayoutAttributeLeading
                                    multiplier:1.0f
                                      constant:0.0f];
        NSLayoutConstraint *topContraint =
        [NSLayoutConstraint constraintWithItem:self.myOpenGLView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.myOpenGLView.superview
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0f
                                      constant:0.0f];
        NSLayoutConstraint *bottomContraint =
        [NSLayoutConstraint constraintWithItem:self.myOpenGLView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.myOpenGLView.superview
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0f
                                      constant:0.0f];
        NSLayoutConstraint *leftContraint =
        [NSLayoutConstraint constraintWithItem:self.myOpenGLView
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.myOpenGLView.superview
                                     attribute:NSLayoutAttributeTrailing
                                    multiplier:1.0f
                                      constant:0.0f];
        
        [self.myOpenGLView.superview addConstraints:
         @[topContraint,leftContraint,rightContraint,bottomContraint]];
        
        // Init. variables
        self.isFullScreen = NO;
        self.windowFrame = window.frame;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
    
    [self setOpenGLDelegate:nil];
    [self setMyOpenGLView:nil];
}

#pragma mark - Full Screen

- (BOOL)acceptsFirstResponder
{
    return YES;
}

// Automatic if acceptsFirstResponder return YES.
//- (BOOL)canBecomeKeyView
//{
//    return YES;
//}

/*
 * Discussion:
 * Need to call [self.window makeFirstResponder:self]
 * And implement -(BOOL)canBecomeKeyView;
 */
//- (void) keyDown:(NSEvent *)event
//{
//    NSLog(@"%@",[event debugDescription]);
//	unichar c = [[event charactersIgnoringModifiers] characterAtIndex:0];
//    
//	switch (c)
//	{
//            // Handle [ESC] key
//		case 27:
//            [self close];
//			return;
//            // Have f key toggle fullscreen
//		case 'f':
//            [self toggleWindowMode];
//			return;
//	}
//    
//	// Allow other character to be handled (or not and beep)
//	[super keyDown:event];
//}

- (void)toggleWindowMode
{
    if (self.isFullScreen) {
        [self setWindowedMode:self.windowFrame];
    }
    else {
        // Saves the current window's frame rectangle
        self.windowFrame = self.frame;
        
        // Switch to full screen
        [self setFullScreen];
    }
}

- (void)setFullScreen;
{
    // Create a screen-sized window on the display you want to take over
    NSRect screenRect = [[NSScreen mainScreen] frame];
    
    // Initialize the window making it size of the screen and borderless
    //    self = [super initWithContentRect:screenRect
    //                            styleMask:NSBorderlessWindowMask
    //                              backing:NSBackingStoreBuffered
    //                                defer:YES];
    [self setStyleMask:NSBorderlessWindowMask];
    [self setFrame:screenRect display:YES animate:NO];
    
    // Set the window level to be above the menu bar to cover everything else
    [self setLevel:NSMainMenuWindowLevel+1];
    
    // Set opaque
    [self setOpaque:YES];
    
    // Hide this when user switches to another window (or app)
    [self setHidesOnDeactivate:YES];
    
    self.isFullScreen = YES;
}

- (void)setWindowedMode:(NSRect)windowFrame
{
    NSUInteger mask =     NSTitledWindowMask
                        | NSClosableWindowMask
                        | NSResizableWindowMask
                        | NSMiniaturizableWindowMask ;
    
    [self setStyleMask:mask];
    [self setFrame:windowFrame display:YES animate:NO];
    
    // Set the window level to be above the menu bar to cover everything else
    [self setLevel:NSNormalWindowLevel];
    
    // Set opaque
    [self setOpaque:YES];
    
    // Hide this when user switches to another window (or app)
    [self setHidesOnDeactivate:NO];
    
    self.isFullScreen = NO;
}

@end