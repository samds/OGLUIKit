//
//  OGLTypes.h
//  OGLUIKit
//
//  Created by samuel on 26/08/2014.
//  Copyright (c) 2014 SDS. All rights reserved.
//

#ifndef OGLUIKit_OGLTypes_h
#define OGLUIKit_OGLTypes_h

#include <OpenGL/gltypes.h>
#include <GLKit/GLKMatrix4.h>

#ifdef __cplusplus
extern "C" {
#endif

struct OGLrect {
    GLint x,y;
    GLsizei width,height;
};
typedef struct OGLrect OGLrect;

struct OGLsize {
    GLsizei width,height;
};
typedef struct OGLsize OGLsize;

#ifdef __cplusplus
}
#endif

#endif
