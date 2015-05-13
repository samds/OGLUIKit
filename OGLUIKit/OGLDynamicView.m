//
//  OGLDynamicView.mm
//  OGLUIKit
//
//  Created by samuel on 26/08/2014.
//  Copyright (c) 2014 SDS. All rights reserved.
//

#import "OGLDynamicView.h"
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


@interface OpenGLDynamicView ()
{
    CVDisplayLinkRef displayLink; //display link for managing rendering thread
    /*
     * Current view size in pixel.
     */
    NSRect currentViewSize;
}
@property(assign,readwrite) BOOL isOpenGLContextInitialized;
- (instancetype)initWithFrame:(NSRect)frame
                     delegate:(id<OpenGLContextDelegate>)delegate;
@end

@implementation OpenGLDynamicView

////////////////////////////////////////////////////////////////////////////////
// Constructor
////////////////////////////////////////////////////////////////////////////////

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.isOpenGLContextInitialized = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code here.
        self.isOpenGLContextInitialized = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frame
                     delegate:(id<OpenGLContextDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.isOpenGLContextInitialized = NO;
        
        [self createOpenGLContextWithDelegate:delegate];
    }
    return self;
}

- (void)createOpenGLContextWithDelegate:(id<OpenGLContextDelegate>)delegate
{
    [self setViewDelegate:delegate];
    [self createOpenGLContext];
}

- (void)createOpenGLContext
{
    NSOpenGLPixelFormatAttribute attrs[] =
	{
		NSOpenGLPFADoubleBuffer,
//		NSOpenGLPFADepthSize, 24,
        NSOpenGLPFAColorSize, 24,
		NSOpenGLPFAAlphaSize, 8,
		// Must specify the 3.2 Core Profile to use OpenGL 3.2
#if ESSENTIAL_GL_PRACTICES_SUPPORT_GL3
		NSOpenGLPFAOpenGLProfile,
		NSOpenGLProfileVersion3_2Core,
#endif
		0
	};
	
	NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc]
                               initWithAttributes:attrs];
	
	if (!pf)
	{
		NSLog(@"No OpenGL pixel format");
	}
    
    NSOpenGLContext* context = [[NSOpenGLContext alloc] initWithFormat:pf
                                                          shareContext:nil];
    
#if ESSENTIAL_GL_PRACTICES_SUPPORT_GL3 && defined(DEBUG)
	// When we're using a CoreProfile context,
    // crash if we call a legacy OpenGL function
	// This will make it much more obvious where and when such a
    // function call is made so that we can remove such calls.
	// Without this we'd simply get GL_INVALID_OPERATION error
    // for calling legacy functions
	// but it would be more difficult to see where that function was called.
	CGLEnable((CGLContextObj)[context CGLContextObj],
                                            kCGLCECrashOnRemovedFunctions);
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
    [[self openGLContext] setValues:&swapInt
                       forParameter:NSOpenGLCPSwapInterval];
    
    // Init our renderer.  Use 0 for the defaultFBO which is appropriate for
	// OSX (but not iOS since iOS apps must create their own FBO)
}

- (void)prepareOpenGL
{
    NSLog(@"%s",__FUNCTION__);

    [super prepareOpenGL];

    // Make all the OpenGL calls to setup rendering
	//  and build the necessary rendering objects
	[self initGL];
    
    ////////////////////////////////////////////////
    // Set up OpenGL state that will never change //
    ////////////////////////////////////////////////
    
    // Init buffer specified by the renderer
    self.isOpenGLContextInitialized = YES;
    [self.viewDelegate didCreateOpenGLContext:nil];
    
    ////////////////////////////////////////////////
    // Init the CVDisplayLink                     //
    ////////////////////////////////////////////////
    
    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
    
    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(displayLink,
                                   &MyDisplayLinkCallback,
                                   (__bridge void *)(self)
                                   );
    
    // Set the display link for the current renderer
    CGLContextObj cglContext =
                        (CGLContextObj)[[self openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat =
                    (CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink,
                                                      cglContext,
                                                      cglPixelFormat);
    
    // Activate the display link
    CVDisplayLinkStart(displayLink);
    
    ////////////////////////////////////////////////
    // Other                                      //
    ////////////////////////////////////////////////
    
    // Register to be notified when the window closes so
    // we can stop the displaylink
    [[NSNotificationCenter defaultCenter]
                                    addObserver:self
                                       selector:@selector(windowWillClose:)
                                           name:NSWindowWillCloseNotification
                                         object:[self window]
    ];
}

- (void) windowWillClose:(NSNotification*)notification
{
	// Stop the display link when the window is closing because default
	// OpenGL render buffers will be destroyed.  If display link continues to
	// fire without renderbuffers, OpenGL draw calls will set errors.
	CVDisplayLinkStop(displayLink);
    [self.viewDelegate windowWillClose:notification];
}

- (void) dealloc
{
    NSLog(@"%s",__FUNCTION__);

	// Stop the display link BEFORE releasing anything in the view
    // otherwise the display link thread may call into the view and crash
    // when it encounters something that has been release
	CVDisplayLinkStop(displayLink);
    
    // Release the display link
	CVDisplayLinkRelease(displayLink);
    
	// Release the display link AFTER display link has been released
	// [m_renderer release];
	
    // Automatically called with ARC
	// [super dealloc];
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink,
                                      const CVTimeStamp* now,
                                      const CVTimeStamp* outputTime,
                                      CVOptionFlags flagsIn,
                                      CVOptionFlags* flagsOut,
                                      void* displayLinkContext)
{
    CVReturn result = [(__bridge OpenGLDynamicView*)displayLinkContext
                                                    getFrameForTime:outputTime
                       ];
    return result;
}

- (CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime
{
    // Add your drawing codes here
//    NSLog(@"Rate Scalar : %f",outputTime->rateScalar);
//    NSLog(@"Video Time : %lli",outputTime->videoTime);
//    NSLog(@"Video Refresh Period : %lli",outputTime->videoRefreshPeriod);
//    NSLog(@"Video Time Scale : %i",outputTime->videoTimeScale);
//    NSLog(@"Host Time : %lli",outputTime->hostTime);
//    CVDisplayLinkGetActualOutputVideoRefreshPeriod(displayLink);
    
//    double deltaTime = 1.0 / (outputTime->rateScalar *
//      (double)outputTime->videoTimeScale /
//      (double)outputTime->videoRefreshPeriod);
//    NSLog(@"delta %f",deltaTime);
    
	[self drawView:outputTime];
	
    return kCVReturnSuccess;
}

/*
 * If outputTime is NULL redraw the last frame
 */
- (void) drawView:(const CVTimeStamp*)outputTime
{
	[[self openGLContext] makeCurrentContext];
    
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main
	// thread. Add a mutex around to avoid the threads accessing the context
	// simultaneously when resizing
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    
    // Draws in back buffer
    [self.viewDelegate renderForTime:outputTime];
    
	CGLFlushDrawable((CGLContextObj)[[self openGLContext] CGLContextObj]);
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

- (void) drawRect: (NSRect) theRect
{
    NSLog(@"%s",__FUNCTION__);
	// Called during resize operations
	
	// Avoid flickering during resize by drawiing
	[self drawView:NULL];
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
    
    // Rendering at retina resolutions will reduce aliasing,
    // but at the potential cost of framerate and battery life due to the
    // GPU needing to render more pixels.
    
    // Any calculations the renderer does which use pixel dimentions, must be
    // in "retina" space.  [NSView convertRectToBacking] converts point sizes
    // to pixel sizes.  Thus the renderer gets the size in pixels, not points,
    // so that it can set it's viewport and perform and other pixel based
    // calculations appropriately.
    // viewRectPixels will be larger (2x) than viewRectPoints
    // for retina displays.
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
    
    if ( !NSIsEmptyRect(viewRectPixels) &
         !NSEqualRects(viewRectPixels, currentViewSize)
        ) {
        currentViewSize = viewRectPixels;
        
        // Set the new dimensions in our renderer
        [self.viewDelegate didUpdateWindowRect:viewRectPixels];
    }
    
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

@end
