#pragma once

#include <string>
#include <vector>
#include "ISurface.h"

class OBJLoader
{
public:
	OBJLoader(const std::string& filePath);
	~OBJLoader(void);

	void SetVertexFlags(unsigned char flags = 0);

	int GetVertexSize();
	int GetVertexCount();
	int GetTriangleIndexCount();
	int GetFaceCount();
	void GenerateVertices(float * vertices);
	void GenerateTriangleIndices(unsigned short * indices);

    int GetNormalCount();
	int GetTextureCount();
    
private:
	void InitInternalFlag();
	int GetCountOf(const std::string& str);

	void LoadIndices();

	void LoadVertexIndex(const std::vector<std::string> & triangleVertex, unsigned short * pv, unsigned short * pn, unsigned short * pt);

	std::vector<std::string> split(const std::string &s, char delim);
	std::vector<std::string> &split(const std::string &s, char delim, std::vector<std::string> &elems);

	void PrintIndices(const unsigned short * indices, int count);
    void PrintArray(const float * data, int count, int stide, const std::string& info);
private:
	std::string m_modelFilepath;

	unsigned char m_faceType;
	unsigned char m_internalFlags;
	unsigned char m_vertexFlags;

	int m_faceCount;
	int m_vertexCount;
	int m_normalCount;
	int m_textureCount;

	unsigned short * m_vertexIndices;
	unsigned short * m_normalIndices;
	unsigned short * m_textureIndices;

	static const int MaxLineSize = 128;
};
