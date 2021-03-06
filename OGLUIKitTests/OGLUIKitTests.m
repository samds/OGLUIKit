//
//  OGLUIKitTests.m
//  OGLUIKitTests
//
//  Created by samuel on 26/08/2014.
//  Copyright (c) 2014 SDS. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OGLUIKit/OGLUIKit.h>

@interface OGLUIKitTests : XCTestCase <OpenGLContextDelegate>
@property(strong,nonatomic) OpenGLDynamicWindow *window;
@end

@implementation OGLUIKitTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.window = [[OpenGLDynamicWindow alloc] initWithFrame:CGRectMake(0, 0, 800, 600) delegate:self];
    [self.window setReleasedWhenClosed:YES];
    [self.window center];
    [self.window setTitle:@"Hello"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
//    [self setWindow:nil];
}

- (void)testExample
{
    NSApplication *app = [NSApplication sharedApplication];
    [self.window makeKeyAndOrderFront:self];
	[app run];
    
    XCTAssert(TRUE, @"");
}

#pragma mark - OpenGL Dynamic View Delegate

- (void)didCreateOpenGLContext:(id)userInfo
{
    glDisable(GL_BLEND);
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_LINE_SMOOTH);
    glDisable(GL_SCISSOR_TEST);
    OGL_GET_GL_ERROR();
}

- (void)renderForTime:(const CVTimeStamp *)outputTime
{
    glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
    OGL_GET_GL_ERROR();
    glClear(GL_COLOR_BUFFER_BIT);
    OGL_GET_GL_ERROR();
}

- (void)didUpdateWindowRect:(NSRect)rect
{
    
}

- (void)windowWillClose:(NSNotification*)notification
{
	[[NSApplication sharedApplication] stop:self];
}

@end
