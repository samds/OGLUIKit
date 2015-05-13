//
//  OGLStaticWindow.mm
//  OGLUIKit
//
//  Created by samuel on 26/08/2014.
//  Copyright (c) 2014 SDS. All rights reserved.
//

#import "OGLStaticWindow.h"
#import "OGLStaticView.h"

#define MINIMUM_WINDOW_SIZE NSMakeSize(320, 240)

////////////////////////////////////////////////////////////////////////////////
//                              Static Window                                 //
////////////////////////////////////////////////////////////////////////////////

@interface OpenGLStaticWindow ()
@end

@implementation OpenGLStaticWindow

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
                     delegate:(id<OpenGLViewDelegate>)delegate
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
        self.openGLDelegate = delegate;
        
        // Minimum size for the window
        [window setMinSize:MINIMUM_WINDOW_SIZE];
        
        self.myOpenGLView =
        [[OpenGLStaticView alloc] initWithFrame:frame
                                       delegate:delegate];
        
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
    }
    return self;
}

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
                     renderer:(id)renderer
                 viewDelegate:(id)delegate;
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
        [[OpenGLStaticView alloc] initWithFrame:frame
                                       renderer:renderer
                                       delegate:delegate ];
        
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
    }
    return self;
}

@end
