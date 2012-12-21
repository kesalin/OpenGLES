//
//  ModelSurface.cpp
//  Tutorial09
//
//  Created by kesalin@gmail.com kesalin on 12-12-16.
//  Copyright (c) 2012年 http://blog.csdn.net/kesalin/. All rights reserved.
//

#include "ModelSurface.h"
#include <fstream>
#include "Vector.h"

using namespace std;

ModelSurface::ModelSurface(const string& modelFilepath):
m_modelFilepath(modelFilepath),
m_vertexFlags(0),
m_triangleIndices(NULL),
m_faceCount(0),
m_vertexCount(0)
{
    int count = GetTriangleIndexCount();
    m_triangleIndices = new unsigned short[count];
    
    unsigned short * p = m_triangleIndices;
    ifstream objFile(m_modelFilepath.c_str());
    while (objFile) {
        char c = objFile.get();
        char space = objFile.get();
        if (c == 'f' && space == ' ') {
            objFile >> *p >> *(p + 1) >> *(p + 2);
            
            // index base on 1
            *p -= 1;
            *(p + 1) -= 1;
            *(p + 2) -= 1;
            
            p += 3;
        }
        objFile.ignore(MaxLineSize, '\n');
    }
}

ModelSurface::~ModelSurface()
{
    if (m_triangleIndices != NULL) {
        delete [] m_triangleIndices;
        m_triangleIndices = NULL;
    }
}

void ModelSurface::SetVertexFlags(unsigned char flags)
{
    m_vertexFlags = flags;
}

int ModelSurface::GetVertexSize()
{
	int floatsPerVertex = 3;
	if (m_vertexFlags & VertexFlagsNormals)
		floatsPerVertex += 3;
	if (m_vertexFlags & VertexFlagsTexCoords)
		floatsPerVertex += 2;
    
	return floatsPerVertex;
}

int ModelSurface::GetVertexCount()
{
    if (m_vertexCount != 0)
        return m_vertexCount;
    
    std::ifstream objFile(m_modelFilepath.c_str());
    while (objFile) {
        char c = objFile.get();
        char space = objFile.get();
        if (c == 'v' && space == ' ')
            m_vertexCount++;
        objFile.ignore(MaxLineSize, '\n');
    }

    return m_vertexCount;
}

int ModelSurface::GetFaceCount()
{
    if (m_faceCount == 0) {
        std::ifstream objFile(m_modelFilepath.c_str());
        while (objFile) {
            char c = objFile.get();
            char space = objFile.get();
            if (c == 'f' && space == ' ')
                m_faceCount++;
            objFile.ignore(MaxLineSize, '\n');
        }
    }
    
    return m_faceCount;
}

int ModelSurface::GetTriangleIndexCount()
{
    return GetFaceCount() * 3;
}

void ModelSurface::GenerateVertices(float * vertices) const
{
    // Read in the vertex positions and initialize lighting normals to (0, 0, 0).
    //
    float * p = vertices;
    ifstream objFile(m_modelFilepath.c_str());
    while (objFile) {
        char c = objFile.get();
        char space = objFile.get();
        if (c == 'v' && space == ' ') {
            objFile >> *p >> *(p + 1) >> *(p + 2);
            
            if ((m_vertexFlags & VertexFlagsNormals) != 0) {
                *(p + 3) = *(p + 4) = *(p + 5) = 0;
                p += 6;
            }
            else {
                p += 3;
            }
        }
        
        objFile.ignore(MaxLineSize, '\n');
    }
    
    if ((m_vertexFlags & VertexFlagsNormals) != 0) {
        int index = 0;
        for (int faceIndex = 0; faceIndex < m_faceCount; ++faceIndex) {
            index = faceIndex * 3;
            unsigned short ia = m_triangleIndices[index] * 6;
            unsigned short ib = m_triangleIndices[index + 1] * 6;
            unsigned short ic = m_triangleIndices[index + 2] * 6;
            
            // Compute the facet normal.
            vec3 * a = (vec3 *)(&vertices[ia]);
            vec3 * b = (vec3 *)(&vertices[ib]);
            vec3 * c = (vec3 *)(&vertices[ic]);
            vec3 facetNormal = (*b - *a).Cross(*c - *a);
            facetNormal.Normalize();

            // Add the facet normal to the lighting normal of each adjoining vertex.
            *(a + 1) += facetNormal;
            *(b + 1) += facetNormal;
            *(c + 1) += facetNormal;
        }
        
        // Normalize the normals.
        for (int i = 0; i < m_vertexCount; i++) {
            index = i * 6 + 3;
            vec3 * n = (vec3 *)(&vertices[index]);
            n->Normalize();
        }
    }
}

void ModelSurface::GenerateTriangleIndices(unsigned short * indices) const
{
    memcpy(indices, m_triangleIndices, m_faceCount * 3 * sizeof(unsigned short));
}
