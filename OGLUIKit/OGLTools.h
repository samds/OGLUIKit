//
//  OGLTools.h
//  OGLUIKit
//
//  Created by samuel de santis on 26/08/2014.
//  Copyright (c) 2014 Samuel DE SANTIS. All rights reserved.
//

#ifndef OpenGLTutorial_OpenGLTools_h
#define OpenGLTutorial_OpenGLTools_h

#include <OpenGL/gl3.h>
#include <CoreFoundation/CFBase.h> // CFStringRef

#ifdef __cplusplus
extern "C" {
#endif
    
/*
 * Load a vertex & fragment shaders into memory.
 *
 * @param vertex_file_path      path to the vertex shader file
 * @param fragment_file_path    path to the fragment shader file
 *
 * @return                      the program id of the program object 
 *                              newly created
 */
GLuint load_shaders(const char* vertex_file_path,
                    const char* fragment_file_path);

/*
 * Convert an OpenGL internal error in a human readable string.
 *
 * @return a readable string describing the error
 */
const char* get_readable_error(GLenum error);

/*
 * OS X ONLY.
 * Search a file with the given name and extension 
 * in the current bundle ressourse.
 *
 * @param file          The name of the requested resource.
 * @param extension     The abstract type of the requested resource.
 *                      (Without the first dot)
 *
 * @return              a C string whose contents the path 
 *                      to <file>.<extension>.
 *                      NULL if the ressource cannot be found.
 */
const char* path_to_file(CFStringRef file, CFStringRef extension);

/*
 * Display the last Open GL error
 */
#define OGL_GET_GL_ERROR()                              \
{														\
    GLenum err = glGetError();							\
    while (err != GL_NO_ERROR) {						\
        printf("GLError %s set in File:%s Line:%d\n",	\
                get_readable_error(err),                \
                __FILE__,								\
                __LINE__);								\
        err = glGetError();								\
    }													\
}


/*
 * Convenient macro to generate offset
 */
#define OGL_BUFFER_OFFSET(bytes)  ((GLvoid*)((GLubyte*) NULL + (bytes)))

#ifdef __cplusplus
}
#endif

#endif
