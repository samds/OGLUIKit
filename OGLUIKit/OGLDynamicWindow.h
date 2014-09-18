//
//  OGLDynamicWindow.h
//  OGLUIKit
//
//  Created by samuel de santis on 26/08/2014.
//  Copyright (c) 2014 Samuel DE SANTIS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OpenGLDynamicViewDelegate;
@class OpenGLDynamicView;


@interface OpenGLDynamicWindow : NSWindow

@property(strong,nonatomic) OpenGLDynamicView *myOpenGLView;
@property(weak,nonatomic) id<OpenGLDynamicViewDelegate> openGLDelegate;

- (instancetype)initWithFrame:(CGRect)frame
                     delegate:(id<OpenGLDynamicViewDelegate>)delegate;

@end