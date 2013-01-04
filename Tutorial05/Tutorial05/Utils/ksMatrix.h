//
//  ksMatrix.h
//
//  Created by kesalin@gmail.com on 12-11-26.
//  Copyright (c) 2012. http://blog.csdn.net/kesalin/. All rights reserved.
//

#ifndef __KS_MATRIX_H__
#define __KS_MATRIX_H__

#include <math.h>
#include "ksVector.h"

#ifndef M_PI
#define M_PI 3.1415926535897932384626433832795f
#endif

#define DEG2RAD( a ) (((a) * M_PI) / 180.0f)
#define RAD2DEG( a ) (((a) * 180.f) / M_PI)

// angle indexes
#define	PITCH				0		// up / down
#define	YAW					1		// left / right
#define	ROLL				2		// fall over

typedef struct ksMatrix3
{
	float   m[3][3];
} ksMatrix3;

typedef struct ksMatrix4
{
	float   m[4][4];
} ksMatrix4;

#ifdef __cplusplus
extern "C" {
#endif

	unsigned int ksNextPot(unsigned int n);

	void ksMatrixCopy(ksMatrix4 * target, const ksMatrix4 * src);

	int ksMatrixInvert(ksMatrix4 * out, const ksMatrix4 * in);

    void ksMatrixTranspose(ksMatrix4 * result, const ksMatrix4 * src);
    
	void ksMatrix4ToMatrix3(ksMatrix3 * target, const ksMatrix4 * src);
    
    void ksMatrixDotVector(ksVec4 * out, const ksMatrix4 * m, const ksVec4 * v);
    
	//
	/// multiply matrix specified by result with a scaling matrix and return new matrix in result
	/// result Specifies the input matrix.  Scaled matrix is returned in result.
	/// sx, sy, sz Scale factors along the x, y and z axes respectively
	//
	void ksMatrixScale(ksMatrix4 * result, float sx, float sy, float sz);

	//
	/// multiply matrix specified by result with a translation matrix and return new matrix in result
	/// result Specifies the input matrix.  Translated matrix is returned in result.
	/// tx, ty, tz Scale factors along the x, y and z axes respectively
	//
	void ksMatrixTranslate(ksMatrix4 * result, float tx, float ty, float tz);

	//
	/// multiply matrix specified by result with a rotation matrix and return new matrix in result
	/// result Specifies the input matrix.  Rotated matrix is returned in result.
	/// angle Specifies the angle of rotation, in degrees.
	/// x, y, z Specify the x, y and z coordinates of a vector, respectively
	//
	void ksMatrixRotate(ksMatrix4 * result, float angle, float x, float y, float z);

	//
	/// perform the following operation - result matrix = srcA matrix * srcB matrix
	/// result Returns multiplied matrix
	/// srcA, srcB Input matrices to be multiplied
	//
	void ksMatrixMultiply(ksMatrix4 * result, const ksMatrix4 *srcA, const ksMatrix4 *srcB);

	//
	//// return an identity matrix 
	//// result returns identity matrix
	//
	void ksMatrixLoadIdentity(ksMatrix4 * result);

	//
	/// multiply matrix specified by result with a perspective matrix and return new matrix in result
	/// result Specifies the input matrix.  new matrix is returned in result.
	/// fovy Field of view y angle in degrees
	/// aspect Aspect ratio of screen
	/// nearZ Near plane distance
	/// farZ Far plane distance
	//
	void ksPerspective(ksMatrix4 * result, float fovy, float aspect, float nearZ, float farZ);

	//
	/// multiply matrix specified by result with a perspective matrix and return new matrix in result
	/// result Specifies the input matrix.  new matrix is returned in result.
	/// left, right Coordinates for the left and right vertical clipping planes
	/// bottom, top Coordinates for the bottom and top horizontal clipping planes
	/// nearZ, farZ Distances to the near and far depth clipping planes.  These values are negative if plane is behind the viewer
	//
	void ksOrtho(ksMatrix4 * result, float left, float right, float bottom, float top, float nearZ, float farZ);

	//
	// multiply matrix specified by result with a perspective matrix and return new matrix in result
	/// result Specifies the input matrix.  new matrix is returned in result.
	/// left, right Coordinates for the left and right vertical clipping planes
	/// bottom, top Coordinates for the bottom and top horizontal clipping planes
	/// nearZ, farZ Distances to the near and far depth clipping planes.  Both distances must be positive.
	//
	void ksFrustum(ksMatrix4 * result, float left, float right, float bottom, float top, float nearZ, float farZ);

	void ksLookAt(ksMatrix4 * result, const ksVec3 * eye, const ksVec3 * target, const ksVec3 * up);

#ifdef __cplusplus
}
#endif

#endif // __KS_MATRIX_H__