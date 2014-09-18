//
//  OGLRendererProtocol.h
//  OGLUIKit
//
//  Created by samuel de santis on 26/08/2014.
//  Copyright (c) 2014 Samuel DE SANTIS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OpenGLViewDelegate
-(void)didUpdateWindowRect:(NSRect)rect;
-(void)didCreateOpenGLContext:(id)userInfo;
@end
