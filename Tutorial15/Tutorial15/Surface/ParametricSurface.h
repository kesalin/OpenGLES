#pragma once

#include "Vector.h"

enum VertexFlags 
{
	VertexFlagsNormals = 1 << 0,
	VertexFlagsTexCoords = 1 << 1,
};

struct ISurface
{
	virtual ~ISurface() {}

	virtual void SetVertexFlags(unsigned char flags = 0) = 0;

	virtual int GetVertexSize() const = 0;
	virtual int GetVertexCount() const = 0;
	virtual int GetLineIndexCount() const = 0;
	virtual int GetTriangleIndexCount() const = 0;

	virtual void GenerateVertices(float * vertices) const = 0;
	virtual void GenerateLineIndices(unsigned short * indices) const = 0;
	virtual void GenerateTriangleIndices(unsigned short * indices) const = 0;
};

struct ParametricInterval
{
    ivec2 Divisions;
    vec2 UpperBound;
    vec2 TextureCount;
};

class ParametricSurface : public ISurface
{
public:
	void SetVertexFlags(unsigned char flags = 0);

	int GetVertexSize() const;
    int GetVertexCount() const;
    int GetLineIndexCount() const;
    int GetTriangleIndexCount() const;

	void GenerateVertices(float * vertices) const;
	void GenerateLineIndices(unsigned short * indices) const;
	void GenerateTriangleIndices(unsigned short * indices) const;

protected:
    void SetInterval(const ParametricInterval& interval);
    virtual vec3 Evaluate(const vec2& domain) const = 0;
    virtual bool InvertNormal(const vec2& domain) const { return false; }

private:
    vec2 ComputeDomain(float i, float j) const;
    ivec2 m_slices;
    ivec2 m_divisions;
    vec2 m_upperBound;
	vec2 m_textureCount;
	unsigned char m_vertexFlags;
};
