//
//  ISurface.h
//  Tutorial09
//
//  Created by kesalin@gmail.com kesalin on 12-12-16.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#pragma once

enum VertexFlags 
{
	VertexFlagsNormals = 1 << 0,
	VertexFlagsTexCoords = 1 << 1,
};

struct ISurface
{
	virtual ~ISurface() {}
    
	virtual void SetVertexFlags(unsigned char flags = 0) = 0;
    
	virtual int GetVertexSize() = 0;
	virtual int GetVertexCount() = 0;
    
	virtual int GetTriangleIndexCount() = 0;
	virtual void GenerateVertices(float * vertices) const = 0;
	virtual void GenerateTriangleIndices(unsigned short * indices) const = 0;
};
