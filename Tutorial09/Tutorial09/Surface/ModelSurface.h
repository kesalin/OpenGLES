//
//  ModelSurface.h
//  Tutorial09
//
//  Created by kesalin@gmail.com kesalin on 12-12-16.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#pragma once
#include <string>
#include "ISurface.h"

class ModelSurface : public ISurface
{
public :
    ModelSurface(const std::string& modelFilepath);
    ~ModelSurface();
    
    void SetVertexFlags(unsigned char flags = 0);
    
	int GetVertexSize();
	int GetVertexCount();
    int GetTriangleIndexCount();
	void GenerateVertices(float * vertices) const;
	void GenerateTriangleIndices(unsigned short * indices) const;
    
private:
    int GetFaceCount();

private:
    std::string m_modelFilepath;
    
    unsigned char m_vertexFlags;
    unsigned short * m_triangleIndices;
    int m_faceCount;
    int m_vertexCount;
    
    static const int MaxLineSize = 128;
};