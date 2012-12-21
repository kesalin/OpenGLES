#include "OBJLoader.h"
#include <assert.h>
#include <fstream>
#include <sstream>
#include <iostream>
#include <algorithm>
#include "Vector.h"

using namespace std;

enum FaceType
{
	FaceTypeTriangle = 0,
	FaceTypeQuad = 1
};

bool IsSpace (string& s) 
{ 
	return s == " "; 
}

OBJLoader::OBJLoader(const string& modelPath):
m_modelFilepath(modelPath),
m_faceType(FaceTypeTriangle),
m_internalFlags(VertexFlagsVertex),
m_vertexFlags(0),
m_faceCount(0),
m_vertexCount(0),
m_normalCount(0),
m_textureCount(0),
m_vertexIndices(0),
m_normalIndices(0),
m_textureIndices(0)
{
	assert((m_modelFilepath.length() > 0) && "Model file path is null or empty!");

	InitInternalFlag();

	LoadIndices();
}

OBJLoader::~OBJLoader()
{
	if (m_textureIndices != NULL) {
		delete [] m_textureIndices;
		m_textureIndices = NULL;
	}

	if (m_normalIndices != NULL) {
		delete [] m_normalIndices;
		m_normalIndices = NULL;
	}

	if (m_vertexIndices != NULL) {
		delete [] m_vertexIndices;
		m_vertexIndices = NULL;
	}
}

std::vector<std::string> & OBJLoader::split(const std::string &s, char delim, std::vector<std::string> &elems)
{
	std::stringstream ss(s);
	std::string item;
	while(std::getline(ss, item, delim)) {
		elems.push_back(item);
	}
	return elems;
}

std::vector<std::string> OBJLoader::split(const std::string &s, char delim)
{
	std::vector<std::string> elems;
	return split(s, delim, elems);
}

void OBJLoader::LoadVertexIndex(const vector<std::string> & triangleVertex, unsigned short * pv, unsigned short * pn, unsigned short * pt)
{
	for (int i = 0; i < 3; i++)
	{
		string vertexStr = triangleVertex[i];
		vector<string> parts = split(vertexStr, '/');
		int j = 0;
		*pv++ = atoi(parts[j++].c_str()) - 1;		// index start with 1	
		if (m_internalFlags & VertexFlagsNormals) {
			assert(pn && parts.size() >= 2 && "Invalid normal indices pointer.");
			*pn++ = atoi(parts[j++].c_str()) - 1;	// index start with 1
		}

		if (m_internalFlags & VertexFlagsTexCoords) {
			assert(pt && parts.size() >= 3 && "Invalid texture indices pointer.");
			*pt++ = atoi(parts[j++].c_str()) - 1;	// index start with 1
		}
	}
}

void OBJLoader::LoadIndices()
{
	int count = GetTriangleIndexCount();

	m_vertexIndices = new unsigned short[count];
	memset(m_vertexIndices, 0, count * sizeof(unsigned short));

	if (m_internalFlags & VertexFlagsNormals) {
		m_normalIndices = new unsigned short[count];
		memset(m_normalIndices, 0, count * sizeof(unsigned short));
	}

	if (m_internalFlags & VertexFlagsTexCoords) {
		m_textureIndices = new unsigned short[count];
		memset(m_textureIndices, 0, count * sizeof(unsigned short));
	}

	// Load indices
	//
	unsigned short * pv = m_vertexIndices;
	unsigned short * pn = m_normalIndices;
	unsigned short * pt = m_textureIndices;

	char buf[MaxLineSize];
	ifstream objFile(m_modelFilepath.c_str());
	while (objFile) {
        memset(buf, 0, MaxLineSize * sizeof(char));
		objFile.getline(buf, MaxLineSize - 1);
        
		string str = buf;
		vector<string> vertices = split(str, ' ');
		vertices.erase(std::remove_if(vertices.begin(), vertices.end(), IsSpace), vertices.end());

		if (vertices.size() > 0 && vertices[0] == "f") {
			cout << " > " << str	 << endl;

			vertices.erase(vertices.begin());

			if (m_faceType == FaceTypeTriangle ) {
				assert((vertices.size() >= 3) && "Triangle vertex count is less than 3.");

				LoadVertexIndex(vertices, pv, pn, pt);

				pv += 3;
				if (m_internalFlags & VertexFlagsNormals) {
					pn += 3;
				}
				if (m_internalFlags & VertexFlagsTexCoords) {
					pt += 2;
				}
			}
			else if (m_faceType == FaceTypeQuad) {
				assert((vertices.size() >= 4) && "Quad vertex count is less than 4.");

				// 0 2 1
				// 0 3 2
				vector<string> triangle;
				triangle.push_back(vertices[0]);
				triangle.push_back(vertices[2]);
				triangle.push_back(vertices[1]);

				LoadVertexIndex(triangle, pv, pn, pt);

				pv += 3;
				if (m_internalFlags & VertexFlagsNormals) {
					pn += 3;
				}
				if (m_internalFlags & VertexFlagsTexCoords) {
					pt += 2;
				}

				triangle.clear();
				triangle.push_back(vertices[0]);
				triangle.push_back(vertices[3]);
				triangle.push_back(vertices[2]);

				LoadVertexIndex(triangle, pv, pn, pt);

				pv += 3;
				if (m_internalFlags & VertexFlagsNormals) {
					pn += 3;
				}
				if (m_internalFlags & VertexFlagsTexCoords) {
					pt += 2;
				}
			}
		}
	}

	objFile.close();

	if (m_vertexIndices != NULL) {
		cout << "==================== Vertex" << endl;
		PrintIndices(m_vertexIndices, count);
	}

	if (m_normalIndices != NULL) {
		cout << "==================== Normal" << endl;
		PrintIndices(m_normalIndices, count);
	}

	if (m_textureIndices != NULL) {
		cout << "==================== Texture" << endl;
		PrintIndices(m_textureIndices, count);
	}
}

void OBJLoader::PrintIndices(const unsigned short * indices, int count)
{
	if (indices == NULL)
		return;

	int step = 3;
	if (m_faceType == FaceTypeQuad) {
		step = 4;
	}

	for (int i = 0; i < count; i++)
	{
		cout << " " << indices[i];

		if (i != 0 && (i + 1) % step == 0) {
			cout << endl;
		}
	}

	cout << endl;
}

void OBJLoader::InitInternalFlag()
{
	ifstream objFile(m_modelFilepath.c_str());
	while (objFile) {
		char buf[MaxLineSize];
		objFile.getline(buf, MaxLineSize - 1);
		string str = buf;
		vector<string> vertices = split(str, ' ');
		vertices.erase(std::remove_if(vertices.begin(), vertices.end(), IsSpace), vertices.end());

		if (vertices.size() > 0 && vertices[0] == "f") {

			vertices.erase(vertices.begin());

			if (vertices.size() == 4) {
				m_faceType = FaceTypeQuad;
			}
			else if (vertices.size() == 3) {
				m_faceType = FaceTypeTriangle;
			}
			else {
				assert(false && "vertex format not supported.");
			}
			
			vector<string> parts = split(vertices[0], '/');
			if (parts.size() == 2) {
				m_internalFlags |= VertexFlagsNormals;
			}
			else if (parts.size() == 3) {
				m_internalFlags |= (VertexFlagsNormals | VertexFlagsTexCoords);
			}
			
			break;
		}
	}

	objFile.close();
}

void OBJLoader::SetVertexFlags(unsigned char flags)
{
	m_vertexFlags = flags;
    
//    if (m_vertexFlags & VertexFlagsTexCoords) {
//        GetTextureCount();
//        
//        assert(m_textureCount > 0 && "Invalid vertex flags! No texture cord in model file.");
//    }
}

int OBJLoader::GetVertexSize()
{
	int floatsPerVertex = 3;
	if (m_vertexFlags & VertexFlagsNormals)
		floatsPerVertex += 3;
	if (m_vertexFlags & VertexFlagsTexCoords)
		floatsPerVertex += 2;

	return floatsPerVertex;
}

int OBJLoader::GetCountOf(const std::string& target)
{
	int count = 0;

	std::ifstream objFile(m_modelFilepath.c_str());
	while (objFile) {
		char buf[MaxLineSize];
		objFile.getline(buf, MaxLineSize - 1);
		string str = buf;
		vector<string> fInfo = split(str, ' ');
		if (fInfo.size() > 0 && fInfo[0] == target) {
			count++;
		}
	}

	objFile.close();

	return count;
}

int OBJLoader::GetVertexCount()
{
	if (m_vertexCount != 0)
		return m_vertexCount;

	m_vertexCount = GetCountOf("v");

	return m_vertexCount;
}

int OBJLoader::GetFaceCount()
{
	if (m_faceCount!= 0) {
		return m_faceCount;
	}

	m_faceCount = GetCountOf("f");

	if (m_faceType == FaceTypeQuad)
		m_faceCount *= 2;

	return m_faceCount;
}

int OBJLoader::GetTriangleIndexCount()
{
	return GetFaceCount() * 3;
}

int OBJLoader::GetNormalCount()
{
	if (m_normalCount!= 0) {
		return m_normalCount;
	}

	m_normalCount = GetCountOf("vn");

	return m_normalCount;
}

int OBJLoader::GetTextureCount()
{
	if (m_textureCount != 0) {
		return m_textureCount;
	}

	m_textureCount = GetCountOf("vt");

	return m_normalCount;
}

void OBJLoader::PrintArray(const float * data, int count, int stride, const string& info)
{
    if (data == NULL || count == 0) 
        return;
    
    cout << endl;
    cout << " ---------- " << info << "---------------- " << endl;
    for (int i = 0; i < count; i++) {
        
        cout << " " << data[i];

        if (i != 0 && ((i + 1) % stride) == 0) {
            cout << endl;
        }
    }

    cout << endl;
}

void OBJLoader::GenerateVertices(float * outVertices)
{
    float * vertices = NULL;
	float * normals = NULL;
	float * textures = NULL;
    
    vertices = new float[m_vertexCount * 3];
    memset(vertices, 0, m_vertexCount * 3 * sizeof(float));

	if ((m_vertexFlags & VertexFlagsNormals) != 0) {
        GetNormalCount();
        if (m_normalCount > 0) {
            normals = new float[m_normalCount * 3];
            memset(normals, 0, m_normalCount * sizeof(float));
        }
	}

	if ((m_vertexFlags & VertexFlagsTexCoords) != 0) {
        GetTextureCount();
        
        if (m_textureCount > 0) {
            textures = new float[m_textureCount * 2];
            memset(textures, 0, m_textureCount * 2 * sizeof(float));
        }
	}

	float * pv = vertices;
	float * pn = normals;
	float * pt = textures;

	ifstream objFile(m_modelFilepath.c_str());
	while (objFile) {
		char buf[MaxLineSize];
		objFile.getline(buf, MaxLineSize - 1);
		string str = buf;
		vector<string> vertices = split(str, ' ');
		vertices.erase(std::remove_if(vertices.begin(), vertices.end(), IsSpace), vertices.end());

		if (vertices.size() > 0) {
            string type = vertices[0];
            vertices.erase(vertices.begin());
            
            // Read in the vertex positions.
            //
			if (type == "v") {
                assert(vertices.size() >= 3 && "Invalid vertex, no enough data.");
                
				int index = 0;
				for (; index < 3; )
				{
					*pv++ = atof(vertices[index++].c_str());
				}
			}
			
            // Read in the normals
            //
			else if (normals != NULL && type == "vn") {
                assert(vertices.size() >= 3 && "Invalid normal, no enough data.");
                
				int index = 0;
				for (; index < 3; )
				{
					*pn++ = atof(vertices[index++].c_str());
				}
			}

            // Read in the texture cord
            //
			else if (textures != NULL && type == "vt") {
                assert(vertices.size() >= 3 && "Invalid texture cord, no enough data.");
                
				int index = 0;
				for (; index < 2; )
				{
					*pt++ = atof(vertices[index++].c_str());
				}
			}
		}
	}

	objFile.close();
    
    PrintArray(vertices, m_vertexCount * 3, 3, "Vertex");
    PrintArray(normals, m_normalCount * 3, 3, "Normal");
    PrintArray(textures, m_textureCount * 2, 2, "Texcoord");
    
    int indexCount = GetTriangleIndexCount();
    
    float * p = outVertices;
    int index = 0;
    for (int i = 0; i < indexCount; i++) {
        int vi = m_vertexIndices[i];
        
        index = 0;
        for (; index < 3;) {
            *p++ = vertices[vi + index++];
        }
        
        if ((m_vertexFlags & VertexFlagsNormals) != 0) {
            if (m_normalIndices != NULL && normals != NULL) {
                int ni = m_normalIndices[i];
                index = 0;
                for (; index < 3;) {
                    *p++ = normals[ni + index++];
                }
            }
            else {
                //
            }
        }
        
        if ((m_vertexFlags & VertexFlagsTexCoords) != 0) {
            if (m_textureIndices != NULL && textures != NULL) {
                int ti = m_textureIndices[i];
                index = 0;
                for (; index < 2;) {
                    *p++ = textures[ti + index++];
                }
            }
            else {
                // default: UV = (0, 1)
                *p++ = 0;
                *p++ = 1;
            }
        }
    }
    
    PrintArray(outVertices, indexCount * GetVertexSize(), GetVertexSize(), "Out Vertex");

//    // modify normal and texture cord
//    //
//	if ((m_vertexFlags & VertexFlagsNormals) != 0) {
//
//		int stride = 6;
//		if ((m_vertexFlags & VertexFlagsTexCoords) != 0) {
//			stride += 2;
//		}
//
//		int index = 0;
//		for (int faceIndex = 0; faceIndex < m_faceCount; ++faceIndex) {
//			index = faceIndex * 3;
//			unsigned short ia = m_vertexIndices[index] * stride;
//			unsigned short ib = m_vertexIndices[index + 1] * stride;
//			unsigned short ic = m_vertexIndices[index + 2] * stride;
//
//            vec3 * a = (vec3 *)(&vertices[ia]);
//            vec3 * b = (vec3 *)(&vertices[ib]);
//            vec3 * c = (vec3 *)(&vertices[ic]);
//            
//            // Update normal
//            //
//            if (normals != NULL) {
//                ia = m_normalIndices[index];
//                ib = m_normalIndices[index];
//                ic = m_normalIndices[index];
//                
//                vec3 * na = (vec3 *)(&normals[index]);
//            }
//            else {
//                // Compute the facet normal.
//                vec3 facetNormal = (*b - *a).Cross(*c - *a);
//                facetNormal.Normalize();
//                
//                // Add the facet normal to the lighting normal of each adjoining vertex.
//                *(a + 1) += facetNormal;
//                *(b + 1) += facetNormal;
//                *(c + 1) += facetNormal;
//            }
//            
//            // Update texture coord
//            //
//            if ((m_vertexFlags & VertexFlagsTexCoords) != 0) {
//            }
//		}
//
//		// Normalize the normals.
//		for (int i = 0; i < m_vertexCount; i++) {
//			index = i * stride + 3;
//			vec3 * n = (vec3 *)(&vertices[index]);
//			n->Normalize();
//		}
//	}
    
    // Clear
    //
    if (vertices != NULL) {
        delete [] vertices;
        vertices = NULL;
    }

    if (normals != NULL) {
        delete [] normals;
        normals = NULL;
    }
    
    if (textures != NULL) {
        delete [] textures;
        textures = NULL;
    }
}

void OBJLoader::GenerateTriangleIndices(unsigned short * indices)
{
	memcpy(indices, m_vertexIndices, m_faceCount * 3 * sizeof(unsigned short));
}
