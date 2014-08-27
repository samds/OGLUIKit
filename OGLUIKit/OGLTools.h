//
//  OGLTools.h
//  OGLUIKit
//
//  Created by samuel de santis on 26/08/2014.
//  Copyright (c) 2014 Samuel DE SANTIS. All rights reserved.
//

#ifndef OpenGLTutorial_OpenGLTools_h
#define OpenGLTutorial_OpenGLTools_h


#include <fstream>
#include <OpenGL/gl3.h>

/*static */inline GLuint loadShaders(const char * vertex_file_path,const char * fragment_file_path);

static inline const char * GetGLErrorString(GLenum error)
{
	const char *str;
	switch( error )
	{
		case GL_NO_ERROR:
			str = "GL_NO_ERROR";
			break;
		case GL_INVALID_ENUM:
			str = "GL_INVALID_ENUM";
			break;
		case GL_INVALID_VALUE:
			str = "GL_INVALID_VALUE";
			break;
		case GL_INVALID_OPERATION:
			str = "GL_INVALID_OPERATION";
			break;
#if defined __gl_h_ || defined __gl3_h_
		case GL_OUT_OF_MEMORY:
			str = "GL_OUT_OF_MEMORY";
			break;
		case GL_INVALID_FRAMEBUFFER_OPERATION:
			str = "GL_INVALID_FRAMEBUFFER_OPERATION";
			break;
#endif
#if defined __gl_h_
		case GL_STACK_OVERFLOW:
			str = "GL_STACK_OVERFLOW";
			break;
		case GL_STACK_UNDERFLOW:
			str = "GL_STACK_UNDERFLOW";
			break;
		case GL_TABLE_TOO_LARGE:
			str = "GL_TABLE_TOO_LARGE";
			break;
#endif
		default:
			str = "(ERROR: Unknown Error Enum)";
			break;
	}
	return str;
}

#define GetGLError()									\
{														\
    GLenum err = glGetError();							\
    while (err != GL_NO_ERROR) {						\
        printf("GLError %s set in File:%s Line:%d\n",	\
                GetGLErrorString(err),					\
                __FILE__,								\
                __LINE__);								\
        err = glGetError();								\
    }													\
}

#define BUFFER_OFFSET(bytes)  ((GLubyte*) NULL + (bytes))

#endif
