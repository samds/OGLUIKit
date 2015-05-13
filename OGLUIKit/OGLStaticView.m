//
//  OGLStaticView.mm
//  OGLUIKit
//
//  Created by samuel on 26/08/2014.
//  Copyright (c) 2014 SDS. All rights reserved.
//

#import "OGLStaticView.h"
#import <OpenGL/OpenGL.h>
#import "OGLTools.h"

#define SUPPORT_RETINA_RESOLUTION 0

// OpenGL 3.2 is only supported on MacOS X Lion and later
// CGL_VERSION_1_3 is defined as 1 on MacOS X Lion and later
#if CGL_VERSION_1_3
// Set to 0 to run on the Legacy OpenGL Profile
#define ESSENTIAL_GL_PRACTICES_SUPPORT_GL3 1
#else
#define ESSENTIAL_GL_PRACTICES_SUPPORT_GL3 0
#warning USED OLD OPEN_GL
#endif //!CGL_VERSION_1_3

#if ESSENTIAL_GL_PRACTICES_SUPPORT_GL3
#import <OpenGL/gl3.h>
#else
#import <OpenGL/gl.h>
#endif


@implementation OpenGLStaticView

////////////////////////////////////////////////////////////////////////////////
// Constructor
////////////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(NSRect)frame
           renderer:(id)renderer
           delegate:(id<OpenGLStaticViewDelegate>)delegate;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setViewDelegate:delegate];
        [self setRenderer:renderer];
        [self awakeFromNib];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame delegate:(id<OpenGLViewDelegate>)delegate
{
//    NSAssert([rendererClass conformsToProtocol:@protocol(WorldRendererProtocol)],
//             @"myRender must be conform to protocol WorldRendererProtocol");
    
    // Implicitly call initWithFrame:pixelFormat:
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
//        self.rendererClass = rendererClass;
        self.openGLDelegate = delegate;
        [self awakeFromNib];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
// Remove all others init
////////////////////////////////////////////////////////////////////////////////

- (instancetype)init
{
    abort();
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    abort();
}

- (instancetype)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format
{
    if (format) {
        abort();
    }
    else {
        return [super initWithFrame:frameRect pixelFormat:format];
    }
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    abort();
}

////////////////////////////////////////////////////////////////////////////////


- (void)awakeFromNib
{
    NSOpenGLPixelFormatAttribute attrs[] =
	{
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, 24,
		// Must specify the 3.2 Core Profile to use OpenGL 3.2
#if ESSENTIAL_GL_PRACTICES_SUPPORT_GL3
		NSOpenGLPFAOpenGLProfile,
		NSOpenGLProfileVersion3_2Core,
#endif
		0
	};
	
	NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	
	if (!pf)
	{
		NSLog(@"No OpenGL pixel format");
	}
    
    NSOpenGLContext* context = [[NSOpenGLContext alloc] initWithFormat:pf shareContext:nil];
    
#if ESSENTIAL_GL_PRACTICES_SUPPORT_GL3 && defined(DEBUG)
	// When we're using a CoreProfile context, crash if we call a legacy OpenGL function
	// This will make it much more obvious where and when such a function call is made so
	// that we can remove such calls.
	// Without this we'd simply get GL_INVALID_OPERATION error for calling legacy functions
	// but it would be more difficult to see where that function was called.
	CGLEnable((CGLContextObj)[context CGLContextObj], kCGLCECrashOnRemovedFunctions);
#endif
	
    [self setPixelFormat:pf];
    
    [self setOpenGLContext:context];
    
#if SUPPORT_RETINA_RESOLUTION
    // Opt-In to Retina resolution
    [self setWantsBestResolutionOpenGLSurface:YES];
#endif // SUPPORT_RETINA_RESOLUTION
    
    [self.window makeFirstResponder:self];
}

- (void)initGL
{
    // The reshape function may have changed the thread to which our OpenGL
	// context is attached before prepareOpenGL and initGL are called.  So call
	// makeCurrentContext to ensure that our OpenGL context current to this
	// thread (i.e. makeCurrentContext directs all OpenGL calls on this thread
	// to [self openGLContext])
	[[self openGLContext] makeCurrentContext];
    
    // Synchronize buffer swaps with vertical refresh rate
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    
    // Init our renderer.  Use 0 for the defaultFBO which is appropriate for
	// OSX (but not iOS since iOS apps must create their own FBO)
    
    // Wait the creation of the OpenGL context before perform any OpenGL call.
//    self.myRenderer = [[self.rendererClass alloc] init];
//    GetGLError();
    
    ////////////////////////////////////////////////
    // Set up OpenGL state that will never change //
    ////////////////////////////////////////////////
    
    // Depth test will always be enabled
//    glEnable(GL_DEPTH_TEST);
	glDisable(GL_DEPTH_TEST);
    OGL_GET_GL_ERROR();
    
    // Accept fragment if it closer to the camera than the former one
    //    glDepthFunc(GL_LESS);
    
    // We will always cull back faces for better performance
    //    glEnable(GL_CULL_FACE);
    
    // Allow to clear only the region defined by the glViewport() function.
    //    glEnable(GL_SCISSOR_TEST);
    
//    glDisable(GL_LINE_SMOOTH);
//    GetGLError();

    // Always use this clear color
    // glClearColor(0.5f, 0.4f, 0.5f, 1.0f);
}

- (void)prepareOpenGL
{
    NSLog(@"%s",__FUNCTION__);
    
    [super prepareOpenGL];
    
    // Make all the OpenGL calls to setup rendering
	//  and build the necessary rendering objects
	[self initGL];
    
    // Register to be notified when the window closes so we can stop the displaylink
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:[self window]];
    
    
    [self.viewDelegate didCreateOpenGLContext:nil];
}

- (void) windowWillClose:(NSNotification*)notification
{
    [self.viewDelegate windowWillClose:notification];
}

- (void) dealloc
{
	// Release the display link AFTER display link has been released
	// [m_renderer release];
	
    // Automatically called with ARC
	// [super dealloc];
}

- (void) drawView
{
//    NSLog(@"%s",__FUNCTION__);

	[[self openGLContext] makeCurrentContext];
    
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main
	// thread. Add a mutex around to avoid the threads accessing the context
	// simultaneously when resizing
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    
    // Draws in back buffer
    [self.renderer render];
    
    // Copies the back buffer of a double-buffered context to the front buffer.
	CGLFlushDrawable((CGLContextObj)[[self openGLContext] CGLContextObj]);
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

- (void) drawRect: (NSRect) theRect
{
    NSLog(@"%s",__FUNCTION__);
	// Called during resize operations
	
	// Avoid flickering during resize by drawiing
	[self drawView];
}

- (void) reshape
{
    NSLog(@"%s",__FUNCTION__);
	[super reshape];
	
	// We draw on a secondary thread through the display link. However, when
	// resizing the view, -drawRect is called on the main thread.
	// Add a mutex around to avoid the threads accessing the context
	// simultaneously when resizing.
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    
	// Get the view size in Points
	NSRect viewRectPoints = [self bounds];
    
#if SUPPORT_RETINA_RESOLUTION
    
    // Rendering at retina resolutions will reduce aliasing, but at the potential
    // cost of framerate and battery life due to the GPU needing to render more
    // pixels.
    
    // Any calculations the renderer does which use pixel dimentions, must be
    // in "retina" space.  [NSView convertRectToBacking] converts point sizes
    // to pixel sizes.  Thus the renderer gets the size in pixels, not points,
    // so that it can set it's viewport and perform and other pixel based
    // calculations appropriately.
    // viewRectPixels will be larger (2x) than viewRectPoints for retina displays.
    // viewRectPixels will be the same as viewRectPoints for non-retina displays
    NSRect viewRectPixels = [self convertRectToBacking:viewRectPoints];
    
#else //if !SUPPORT_RETINA_RESOLUTION
    
    // App will typically render faster and use less power rendering at
    // non-retina resolutions since the GPU needs to render less pixels.  There
    // is the cost of more aliasing, but it will be no-worse than on a Mac
    // without a retina display.
    
    // Points:Pixels is always 1:1 when not supporting retina resolutions
    NSRect viewRectPixels = viewRectPoints;
    
#endif // !SUPPORT_RETINA_RESOLUTION
    
//    NSLog(@"View Rect Pixels %f %f",viewRectPixels.size.width,viewRectPixels.size.height);
    
	// Set the new dimensions in our renderer
    [self.renderer didUpdateWindowRect:viewRectPixels];
    
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

- (void)renewGState
{
    NSLog(@"%s",__FUNCTION__);
	// Called whenever graphics state updated (such as window resize)
	
	// OpenGL rendering is not synchronous with other rendering on the OSX.
	// Therefore, call disableScreenUpdatesUntilFlush so the window server
	// doesn't render non-OpenGL content in the window asynchronously from
	// OpenGL content, which could cause flickering.  (non-OpenGL content
	// includes the title bar and drawing done by the app with other APIs)
	[[self window] disableScreenUpdatesUntilFlush];
    
	[super renewGState];
}

#pragma mark - Windows


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
- (void) keyDown:(NSEvent *)event
{
    NSLog(@"%@",[event debugDescription]);
	unichar c = [[event charactersIgnoringModifiers] characterAtIndex:0];
    
	switch (c)
	{
            // Handle [ESC] key
		case 27:
            [self.window close];
			return;
            // Have f key toggle fullscreen
		case 'f':
			return;
	}
    
	// Allow other character to be handled (or not and beep)
	[super keyDown:event];
}

@end
