//
//  OGLTypes.h
//  OGLUIKit
//
//  Created by samuel de santis on 17/09/2014.
//  Copyright (c) 2014 Samuel DE SANTIS. All rights reserved.
//

#ifndef OGLUIKit_OGLTypes_h
#define OGLUIKit_OGLTypes_h

#include <OpenGL/gltypes.h>
#include <GLKit/GLKMatrix4.h>

namespace ogl {

struct OGLrect {
    GLint x,y;
    GLsizei width,height;
};
typedef struct OGLrect OGLrect;

struct OGLsize {
    GLsizei width,height;
};
typedef struct OGLsize OGLsize;

} // namespace ogl

#endif
