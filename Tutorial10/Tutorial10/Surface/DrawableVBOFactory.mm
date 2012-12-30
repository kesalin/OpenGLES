//
//  DrawableVBOFactory.mm
//
//  Created by kesalin@gmail.com kesalin on 12-12-30.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import "DrawableVBOFactory.h"
#import "ParametricEquations.h"

//
// DrawableVBO implementation
//
@implementation DrawableVBO

@synthesize vertexBuffer, lineIndexBuffer, triangleIndexBuffer;
@synthesize vertexSize, lineIndexCount, triangleIndexCount;

- (void) cleanup
{
    if (vertexBuffer != 0) {
        glDeleteBuffers(1, &vertexBuffer);
        vertexBuffer = 0;
    }
    
    if (lineIndexBuffer != 0) {
        glDeleteBuffers(1, &lineIndexBuffer);
        lineIndexBuffer = 0;
    }
    
    if (triangleIndexBuffer) {
        glDeleteBuffers(1, &triangleIndexBuffer);
        triangleIndexBuffer = 0;
    }
}

@end

// DrawableVBOFactory implementation
//
@implementation DrawableVBOFactory

+ (ISurface *)createSurface:(SurfaceType)type
{
    ISurface * surface = NULL;
    
    if (type == SurfaceTorus) {
        surface = new Torus(2.0f, 0.3f);
    }
    else if (type == SurfaceTrefoilKnot) {
        surface = new TrefoilKnot(2.4f);
    }
    else if (type == SurfaceKleinBottle) {
        surface = new KleinBottle(0.3f);
    }
    else if (type == SurfaceMobiusStrip) {
        surface = new MobiusStrip(1.4);
    }
    else {
        surface = new Sphere(3.0f);
    }
    
    return surface;
}

+ (DrawableVBO *)createVBO:(SurfaceType)surfaceType
{
    ISurface * surface = [self createSurface:surfaceType];
    
    surface->SetVertexFlags(VertexFlagsNormals | VertexFlagsTexCoords);
    
    // Get vertice from surface.
    //
    int vertexSize = surface->GetVertexSize();
    int vBufSize = surface->GetVertexCount() * vertexSize;
    GLfloat * vbuf = new GLfloat[vBufSize];
    surface->GenerateVertices(vbuf);
    
    // Get triangle indice from surface
    //
    int triangleIndexCount = surface->GetTriangleIndexCount();
    unsigned short * triangleBuf = new unsigned short[triangleIndexCount];
    surface->GenerateTriangleIndices(triangleBuf);
    
    // Create the VBO for the vertice.
    //
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, vBufSize * sizeof(GLfloat), vbuf, GL_STATIC_DRAW);
    
    // Create the VBO for the triangle indice
    //
    GLuint triangleIndexBuffer;
    glGenBuffers(1, &triangleIndexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, triangleIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, triangleIndexCount * sizeof(GLushort), triangleBuf, GL_STATIC_DRAW);
    
    delete [] vbuf;
    delete [] triangleBuf;
    delete surface;
    
    DrawableVBO * vbo = [[DrawableVBO alloc] init];
    vbo.vertexBuffer = vertexBuffer;
    vbo.triangleIndexBuffer = triangleIndexBuffer;
    vbo.vertexSize = vertexSize;
    vbo.triangleIndexCount = triangleIndexCount;
    
    return vbo;
}

+ (DrawableVBO *)createVBOsForCube
{
    const GLfloat vertices[] = {
        -1.5f, -1.5f, 1.5f, 0, 0, 1, 0, 1,
        -1.5f, 1.5f, 1.5f, 0, 0, 1, 0, 0,
        1.5f, 1.5f, 1.5f, 0, 0, 1, 1, 0,
        1.5f, -1.5f, 1.5f, 0, 0, 1, 1, 1,
        
        1.5f, -1.5f, -1.5f, 0.577350, -0.577350, -0.577350, 0, 1,
        1.5f, 1.5f, -1.5f, 0.577350, 0.577350, -0.577350, 0, 0,
        -1.5f, 1.5f, -1.5f, -0.577350, 0.577350, -0.577350, 1, 0,
        -1.5f, -1.5f, -1.5f, -0.577350, -0.577350, -0.577350, 1, 1,
        
        -1.5f, -1.5f, -1.5f, -0.577350, -0.577350, -0.577350, 0, 1,
        -1.5f, 1.5f, -1.5f, -0.577350, 0.577350, -0.577350, 0, 0,
        -1.5f, 1.5f, 1.5f, -0.577350, 0.577350, 0.577350, 1, 0,
        -1.5f, -1.5f, 1.5f, -0.577350, -0.577350, 0.577350, 1, 1,
        
        1.5f, -1.5f, 1.5f, 0.577350, -0.577350, 0.577350, 0, 1,
        1.5f, 1.5f, 1.5f, 0.577350, 0.577350, 0.577350, 0, 0,
        1.5f, 1.5f, -1.5f, 0.577350, 0.577350, -0.577350, 1, 0,
        1.5f, -1.5f, -1.5f, 0.577350, -0.577350, -0.577350, 1, 1,
        
        -1.5f, 1.5f, 1.5f, 0, 1, 0, 0, 2,
        -1.5f, 1.5f, -1.5f, 0, 1, 0, 0, 0,
        1.5f, 1.5f, -1.5f, 0, 1, 0, 2, 0,
        1.5f, 1.5f, 1.5f, 0, 1, 0, 2, 2,
        
        -1.5f, -1.5f, -1.5f, -0.577350, -0.577350, -0.577350, 0, 1,
        -1.5f, -1.5f, 1.5f, -0.577350, -0.577350, 0.577350, 0, 0,
        1.5f, -1.5f, 1.5f, 0.577350, -0.577350, 0.577350, 1, 0,
        1.5f, -1.5f, -1.5f, 0.577350, -0.577350, -0.577350, 1, 1
    };
    
    const GLushort indices[] = {
        // Front face
        0, 1, 3, 1, 2, 3,
        
        // Back face
        7, 5, 4, 7, 6, 5,
        
        // Left face
        8, 9, 10, 8, 10, 11,
        
        // Right face
        12, 13, 14, 12, 14, 15,
        
        // Up face
        16, 17, 18, 16, 18, 19,
        
        // Down face
        20, 21, 22, 20, 22, 23
    };
    
    // Create the VBO for the vertice.
    //
    int vertexSize = 8;
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // Create the VBO for the triangle indice
    //
    int triangleIndexCount = sizeof(indices)/sizeof(indices[0]);
    GLuint triangleIndexBuffer; 
    glGenBuffers(1, &triangleIndexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, triangleIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, triangleIndexCount * sizeof(GLushort), indices, GL_STATIC_DRAW);
    
    DrawableVBO * vbo = [[DrawableVBO alloc] init];
    vbo.vertexBuffer = vertexBuffer;
    vbo.triangleIndexBuffer = triangleIndexBuffer;
    vbo.vertexSize = vertexSize;
    vbo.triangleIndexCount = triangleIndexCount;
    
    return vbo;
}

+ (DrawableVBO *) createDrawableVBO:(SurfaceType) type
{
    if (type == SurfaceCube) {
        return [self createVBOsForCube];
    }

    return [self createVBO:type];
}


@end
