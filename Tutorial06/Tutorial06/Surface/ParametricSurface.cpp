#include "ParametricSurface.h"

void ParametricSurface::SetInterval(const ParametricInterval& interval)
{
    m_divisions = interval.Divisions;
    m_upperBound = interval.UpperBound;
    m_textureCount = interval.TextureCount;
    m_slices = m_divisions - ivec2(1, 1);
}

void ParametricSurface::SetVertexFlags(unsigned char flags)
{
	m_vertexFlags = flags;
}

int ParametricSurface::GetVertexSize() const
{
	int floatsPerVertex = 3;
	if (m_vertexFlags & VertexFlagsNormals)
		floatsPerVertex += 3;
	if (m_vertexFlags & VertexFlagsTexCoords)
		floatsPerVertex += 2;

	return floatsPerVertex;
}

int ParametricSurface::GetVertexCount() const
{
    return m_divisions.x * m_divisions.y;
}

int ParametricSurface::GetLineIndexCount() const
{
    return 4 * m_slices.x * m_slices.y;
}

int ParametricSurface::GetTriangleIndexCount() const
{
    return 6 * m_slices.x * m_slices.y;
}

vec2 ParametricSurface::ComputeDomain(float x, float y) const
{
    return vec2(x * m_upperBound.x / m_slices.x, y * m_upperBound.y / m_slices.y);
}

void ParametricSurface::GenerateVertices(float * vertices) const
{
	float* attribute = vertices;
	for (int j = 0; j < m_divisions.y; j++) {
		for (int i = 0; i < m_divisions.x; i++) {

			// Compute Position
			vec2 domain = ComputeDomain(i, j);
			vec3 range = Evaluate(domain);
			attribute = range.Write(attribute);

			// Compute Normal
			if (m_vertexFlags & VertexFlagsNormals) {
				float s = i, t = j;

				// Nudge the point if the normal is indeterminate.
				if (i == 0) s += 0.01f;
				if (i == m_divisions.x - 1) s -= 0.01f;
				if (j == 0) t += 0.01f;
				if (j == m_divisions.y - 1) t -= 0.01f;

				// Compute the tangents and their cross product.
				vec3 p = Evaluate(ComputeDomain(s, t));
				vec3 u = Evaluate(ComputeDomain(s + 0.01f, t)) - p;
				vec3 v = Evaluate(ComputeDomain(s, t + 0.01f)) - p;
				vec3 normal = u.Cross(v).Normalized();
				if (InvertNormal(domain))
					normal = -normal;
				attribute = normal.Write(attribute);
			}

			// Compute Texture Coordinates
			if (m_vertexFlags & VertexFlagsTexCoords) {
				float s = m_textureCount.x * i / m_slices.x;
				float t = m_textureCount.y * j / m_slices.y;
				attribute = vec2(s, t).Write(attribute);
			}
		}
	}
}

void ParametricSurface::GenerateLineIndices(unsigned short * indices) const
{
	unsigned short * index = indices;
	for (int j = 0, vertex = 0; j < m_slices.y; j++) {
		for (int i = 0; i < m_slices.x; i++) {
			int next = (i + 1) % m_divisions.x;
			*index++ = vertex + i;
			*index++ = vertex + next;
			*index++ = vertex + i;
			*index++ = vertex + i + m_divisions.x;
		}
		vertex += m_divisions.x;
	}
}

void ParametricSurface::GenerateTriangleIndices(unsigned short * indices) const
{
	unsigned short * index = indices;
	for (int j = 0, vertex = 0; j < m_slices.y; j++) {
		for (int i = 0; i < m_slices.x; i++) {
			int next = (i + 1) % m_divisions.x;
			*index++ = vertex + i;
			*index++ = vertex + next;
			*index++ = vertex + i + m_divisions.x;
			*index++ = vertex + next;
			*index++ = vertex + next + m_divisions.x;
			*index++ = vertex + i + m_divisions.x;
		}
		vertex += m_divisions.x;
	}
}
