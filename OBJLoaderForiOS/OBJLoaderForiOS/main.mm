//
//  main.m
//  OBJLoaderForiOS
//
//  Created by kesalin@gmail.com kesalin on 12-12-17.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBJLoader.h"

int main (int argc, const char * argv[])
{

    @autoreleasepool {
        NSLog(@">>>>>>>>>>>>>>>> OBJ loader for iOS <<<<<<<<<<<<<<<<<<<<<<<<<<<<");
        
        NSString * modelFilepath = [NSString stringWithFormat:@"%@",
                                    @"/Users/kesalin/Documents/Work/OpenGL-ES/OpenGLES/OBJLoaderForiOS/OBJLoaderForiOS/Model"];
        modelFilepath = [modelFilepath stringByAppendingString:@"/cube.obj"];
        
        NSLog(@"%@", modelFilepath);
        
        OBJLoader * loader = new OBJLoader([modelFilepath UTF8String]);
        loader->SetVertexFlags(VertexFlagsNormals);
        
        int vertexCount = loader->GetVertexCount();
        int triangleCount = loader->GetFaceCount();
        int normalCount = loader->GetNormalCount();
        int textureCordCount = loader->GetTextureCount();
        int triangleIndexCount = loader->GetTriangleIndexCount();
        int vertexSize = loader->GetVertexSize();
        
        NSLog(@"\n >> vertexSize : %d\n\n >> vertexCount : %d\n >> faceCount : %d\n >> normalCount : %d\n >> texture count : %d\n",
              vertexSize, vertexCount, triangleCount, normalCount, textureCordCount);
        
        float * vertices = new float[triangleIndexCount * vertexSize];
        loader->GenerateVertices(vertices);
        
        float * p = vertices;
        for (int i = 0; i < vertexCount; i++) {
            NSMutableString * info = [[NSMutableString alloc] init];
            [info appendFormat:@" >> %i : ", i];
            for (int j = 0; j < vertexSize; j++) {
                
                [info appendFormat:@" %f", *p++];
            }
            
            NSLog(@"%@", info);
        }
        
        delete [] vertices;
        delete loader;

    }
    return 0;
}

