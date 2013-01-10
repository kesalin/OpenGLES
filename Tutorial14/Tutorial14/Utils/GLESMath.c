//
//  GLESMath.c
//
//  Created by kesalin@gmail.com on 12-11-26.
//  Copyright (c) 2012. http://blog.csdn.net/kesalin/. All rights reserved.
//

#include "GLESMath.h"
#include <stdlib.h>
#include <math.h>

void * memcpy(void *, const void *, size_t);
void * memset(void *, int, size_t);

unsigned int ksNextPot(unsigned int n)
{
    n--;
    n |= n >> 1; n |= n >> 2;
    n |= n >> 4; n |= n >> 8;
    n |= n >> 16;
    n++;
    return n;
}

//
// Vectoer math utils
//

float ksVectorLength(const KSVec3 * in)
{
	return (float)sqrt(in->x * in->x + in->y * in->y + in->z * in->z);
}

void ksCrossProduct(KSVec3 * out, const KSVec3 * a, const KSVec3 * b)
{
	out->x = a->y * b->z - a->z * b->y;
	out->y = a->z * b->x - a->x * b->z;
	out->z = a->x * b->y - b->y * a->x;
}

void ksVectorSubtract(KSVec3 * out, const KSVec3 * a, const KSVec3 * b)
{
	out->x = a->x - b->x;
	out->y = a->y - b->y;
	out->z = a->z - b->z;
}

void ksVectorNormalize(KSVec3 * v)
{
	float length = ksVectorLength(v);
	if (length != 0)
	{
		length = 1.0 / length;
		v->x *= length;
		v->y *= length;
		v->z *= length;
	}
}

//
// Matrix math utils
//

void ksScale(KSMatrix4 *result, GLfloat sx, GLfloat sy, GLfloat sz)
{
    result->m[0][0] *= sx;
    result->m[0][1] *= sx;
    result->m[0][2] *= sx;
    result->m[0][3] *= sx;
    
    result->m[1][0] *= sy;
    result->m[1][1] *= sy;
    result->m[1][2] *= sy;
    result->m[1][3] *= sy;
    
    result->m[2][0] *= sz;
    result->m[2][1] *= sz;
    result->m[2][2] *= sz;
    result->m[2][3] *= sz;
}

void ksTranslate(KSMatrix4 *result, GLfloat tx, GLfloat ty, GLfloat tz)
{
    result->m[3][0] += (result->m[0][0] * tx + result->m[1][0] * ty + result->m[2][0] * tz);
    result->m[3][1] += (result->m[0][1] * tx + result->m[1][1] * ty + result->m[2][1] * tz);
    result->m[3][2] += (result->m[0][2] * tx + result->m[1][2] * ty + result->m[2][2] * tz);
    result->m[3][3] += (result->m[0][3] * tx + result->m[1][3] * ty + result->m[2][3] * tz);
}

void ksRotate(KSMatrix4 *result, GLfloat angle, GLfloat x, GLfloat y, GLfloat z)
{
    GLfloat sinAngle, cosAngle;
    GLfloat mag = sqrtf(x * x + y * y + z * z);
    
    sinAngle = sinf ( angle * M_PI / 180.0f );
    cosAngle = cosf ( angle * M_PI / 180.0f );
    if ( mag > 0.0f )
    {
        GLfloat xx, yy, zz, xy, yz, zx, xs, ys, zs;
        GLfloat oneMinusCos;
        KSMatrix4 rotMat;
        
        x /= mag;
        y /= mag;
        z /= mag;
        
        xx = x * x;
        yy = y * y;
        zz = z * z;
        xy = x * y;
        yz = y * z;
        zx = z * x;
        xs = x * sinAngle;
        ys = y * sinAngle;
        zs = z * sinAngle;
        oneMinusCos = 1.0f - cosAngle;
        
        rotMat.m[0][0] = (oneMinusCos * xx) + cosAngle;
        rotMat.m[0][1] = (oneMinusCos * xy) - zs;
        rotMat.m[0][2] = (oneMinusCos * zx) + ys;
        rotMat.m[0][3] = 0.0F; 
        
        rotMat.m[1][0] = (oneMinusCos * xy) + zs;
        rotMat.m[1][1] = (oneMinusCos * yy) + cosAngle;
        rotMat.m[1][2] = (oneMinusCos * yz) - xs;
        rotMat.m[1][3] = 0.0F;
        
        rotMat.m[2][0] = (oneMinusCos * zx) - ys;
        rotMat.m[2][1] = (oneMinusCos * yz) + xs;
        rotMat.m[2][2] = (oneMinusCos * zz) + cosAngle;
        rotMat.m[2][3] = 0.0F; 
        
        rotMat.m[3][0] = 0.0F;
        rotMat.m[3][1] = 0.0F;
        rotMat.m[3][2] = 0.0F;
        rotMat.m[3][3] = 1.0F;
        
        ksMatrixMultiply( result, &rotMat, result );
    }
}

void ksMatrixMultiply(KSMatrix4 *result, const KSMatrix4 *srcA, const KSMatrix4 *srcB)
{
    KSMatrix4    tmp;
    int         i;
    
	for (i=0; i<4; i++)
	{
		tmp.m[i][0] =	(srcA->m[i][0] * srcB->m[0][0]) +
        (srcA->m[i][1] * srcB->m[1][0]) +
        (srcA->m[i][2] * srcB->m[2][0]) +
        (srcA->m[i][3] * srcB->m[3][0]) ;
        
		tmp.m[i][1] =	(srcA->m[i][0] * srcB->m[0][1]) + 
        (srcA->m[i][1] * srcB->m[1][1]) +
        (srcA->m[i][2] * srcB->m[2][1]) +
        (srcA->m[i][3] * srcB->m[3][1]) ;
        
		tmp.m[i][2] =	(srcA->m[i][0] * srcB->m[0][2]) + 
        (srcA->m[i][1] * srcB->m[1][2]) +
        (srcA->m[i][2] * srcB->m[2][2]) +
        (srcA->m[i][3] * srcB->m[3][2]) ;
        
		tmp.m[i][3] =	(srcA->m[i][0] * srcB->m[0][3]) + 
        (srcA->m[i][1] * srcB->m[1][3]) +
        (srcA->m[i][2] * srcB->m[2][3]) +
        (srcA->m[i][3] * srcB->m[3][3]) ;
	}
    
    memcpy(result, &tmp, sizeof(KSMatrix4));
}

void ksCopyMatrix4(KSMatrix4 * target, const KSMatrix4 * src)
{
    memcpy(target, src, sizeof(KSMatrix4));
}

void ksTranspose(KSMatrix4 *result, const KSMatrix4 * src)
{
    KSMatrix4 tmp;
    tmp.m[0][0] = src->m[0][0]; 
    tmp.m[0][1] = src->m[1][0];
    tmp.m[0][2] = src->m[2][0];
    tmp.m[0][3] = src->m[3][0];
    
    tmp.m[1][0] = src->m[0][1]; 
    tmp.m[1][1] = src->m[1][1];
    tmp.m[1][2] = src->m[2][1];
    tmp.m[1][3] = src->m[3][1];
    
    tmp.m[2][0] = src->m[0][2]; 
    tmp.m[2][1] = src->m[1][2];
    tmp.m[2][2] = src->m[2][2];
    tmp.m[2][3] = src->m[3][2];
    
    tmp.m[3][0] = src->m[0][3]; 
    tmp.m[3][1] = src->m[1][3];
    tmp.m[3][2] = src->m[2][3];
    tmp.m[3][3] = src->m[3][3];
    
    memcpy(result, &tmp, sizeof(KSMatrix4));
}

void ksMatrix4ToMatrix3(KSMatrix3 * t, const KSMatrix4 * src)
{
    t->m[0][0] = src->m[0][0];
    t->m[0][1] = src->m[0][1];
    t->m[0][2] = src->m[0][2];
    t->m[1][0] = src->m[1][0];
    t->m[1][1] = src->m[1][1];
    t->m[1][2] = src->m[1][2];
    t->m[2][0] = src->m[2][0];
    t->m[2][1] = src->m[2][1];
    t->m[2][2] = src->m[2][2];
}

void ksMatrixLoadIdentity(KSMatrix4 *result)
{
    memset(result, 0x0, sizeof(KSMatrix4));

    result->m[0][0] = 1.0f;
    result->m[1][1] = 1.0f;
    result->m[2][2] = 1.0f;
    result->m[3][3] = 1.0f;
}

int ksInvert(KSMatrix4 * out, const KSMatrix4 * in)
{
    float * m = (float *)(&in->m[0][0]);
	float * om = (float *)(&out->m[0][0]);
	double inv[16], det;
	int i;
    
	inv[0] = m[5]  * m[10] * m[15] - 
    m[5]  * m[11] * m[14] - 
    m[9]  * m[6]  * m[15] + 
    m[9]  * m[7]  * m[14] +
    m[13] * m[6]  * m[11] - 
    m[13] * m[7]  * m[10];
    
	inv[4] = -m[4]  * m[10] * m[15] + 
    m[4]  * m[11] * m[14] + 
    m[8]  * m[6]  * m[15] - 
    m[8]  * m[7]  * m[14] - 
    m[12] * m[6]  * m[11] + 
    m[12] * m[7]  * m[10];
    
	inv[8] = m[4]  * m[9] * m[15] - 
    m[4]  * m[11] * m[13] - 
    m[8]  * m[5] * m[15] + 
    m[8]  * m[7] * m[13] + 
    m[12] * m[5] * m[11] - 
    m[12] * m[7] * m[9];
    
	inv[12] = -m[4]  * m[9] * m[14] + 
    m[4]  * m[10] * m[13] +
    m[8]  * m[5] * m[14] - 
    m[8]  * m[6] * m[13] - 
    m[12] * m[5] * m[10] + 
    m[12] * m[6] * m[9];
    
	inv[1] = -m[1]  * m[10] * m[15] + 
    m[1]  * m[11] * m[14] + 
    m[9]  * m[2] * m[15] - 
    m[9]  * m[3] * m[14] - 
    m[13] * m[2] * m[11] + 
    m[13] * m[3] * m[10];
    
	inv[5] = m[0]  * m[10] * m[15] - 
    m[0]  * m[11] * m[14] - 
    m[8]  * m[2] * m[15] + 
    m[8]  * m[3] * m[14] + 
    m[12] * m[2] * m[11] - 
    m[12] * m[3] * m[10];
    
	inv[9] = -m[0]  * m[9] * m[15] + 
    m[0]  * m[11] * m[13] + 
    m[8]  * m[1] * m[15] - 
    m[8]  * m[3] * m[13] - 
    m[12] * m[1] * m[11] + 
    m[12] * m[3] * m[9];
    
	inv[13] = m[0]  * m[9] * m[14] - 
    m[0]  * m[10] * m[13] - 
    m[8]  * m[1] * m[14] + 
    m[8]  * m[2] * m[13] + 
    m[12] * m[1] * m[10] - 
    m[12] * m[2] * m[9];
    
	inv[2] = m[1]  * m[6] * m[15] - 
    m[1]  * m[7] * m[14] - 
    m[5]  * m[2] * m[15] + 
    m[5]  * m[3] * m[14] + 
    m[13] * m[2] * m[7] - 
    m[13] * m[3] * m[6];
    
	inv[6] = -m[0]  * m[6] * m[15] + 
    m[0]  * m[7] * m[14] + 
    m[4]  * m[2] * m[15] - 
    m[4]  * m[3] * m[14] - 
    m[12] * m[2] * m[7] + 
    m[12] * m[3] * m[6];
    
	inv[10] = m[0]  * m[5] * m[15] - 
    m[0]  * m[7] * m[13] - 
    m[4]  * m[1] * m[15] + 
    m[4]  * m[3] * m[13] + 
    m[12] * m[1] * m[7] - 
    m[12] * m[3] * m[5];
    
	inv[14] = -m[0]  * m[5] * m[14] + 
    m[0]  * m[6] * m[13] + 
    m[4]  * m[1] * m[14] - 
    m[4]  * m[2] * m[13] - 
    m[12] * m[1] * m[6] + 
    m[12] * m[2] * m[5];
    
	inv[3] = -m[1] * m[6] * m[11] + 
    m[1] * m[7] * m[10] + 
    m[5] * m[2] * m[11] - 
    m[5] * m[3] * m[10] - 
    m[9] * m[2] * m[7] + 
    m[9] * m[3] * m[6];
    
	inv[7] = m[0] * m[6] * m[11] - 
    m[0] * m[7] * m[10] - 
    m[4] * m[2] * m[11] + 
    m[4] * m[3] * m[10] + 
    m[8] * m[2] * m[7] - 
    m[8] * m[3] * m[6];
    
	inv[11] = -m[0] * m[5] * m[11] + 
    m[0] * m[7] * m[9] + 
    m[4] * m[1] * m[11] - 
    m[4] * m[3] * m[9] - 
    m[8] * m[1] * m[7] + 
    m[8] * m[3] * m[5];
    
	inv[15] = m[0] * m[5] * m[10] - 
    m[0] * m[6] * m[9] - 
    m[4] * m[1] * m[10] + 
    m[4] * m[2] * m[9] + 
    m[8] * m[1] * m[6] - 
    m[8] * m[2] * m[5];
    
	det = m[0] * inv[0] + m[1] * inv[4] + m[2] * inv[8] + m[3] * inv[12];
    
	if (det == 0)
		return 0;
    
	det = 1.0 / det;
	for (i = 0; i < 16; i++)
		*om++ = (float)(inv[i] * det);
    
	return 1;
}

void ksFrustum(KSMatrix4 *result, float left, float right, float bottom, float top, float nearZ, float farZ)
{
    float       deltaX = right - left;
    float       deltaY = top - bottom;
    float       deltaZ = farZ - nearZ;
    KSMatrix4    frust;
    
    if ( (nearZ <= 0.0f) || (farZ <= 0.0f) ||
        (deltaX <= 0.0f) || (deltaY <= 0.0f) || (deltaZ <= 0.0f) )
        return;
    
    frust.m[0][0] = 2.0f * nearZ / deltaX;
    frust.m[0][1] = frust.m[0][2] = frust.m[0][3] = 0.0f;
    
    frust.m[1][1] = 2.0f * nearZ / deltaY;
    frust.m[1][0] = frust.m[1][2] = frust.m[1][3] = 0.0f;
    
    frust.m[2][0] = (right + left) / deltaX;
    frust.m[2][1] = (top + bottom) / deltaY;
    frust.m[2][2] = -(nearZ + farZ) / deltaZ;
    frust.m[2][3] = -1.0f;
    
    frust.m[3][2] = -2.0f * nearZ * farZ / deltaZ;
    frust.m[3][0] = frust.m[3][1] = frust.m[3][3] = 0.0f;
    
    ksMatrixMultiply(result, &frust, result);
}

void ksPerspective(KSMatrix4 *result, float fovy, float aspect, float nearZ, float farZ)
{
    GLfloat frustumW, frustumH;
    
    frustumH = tanf( fovy / 360.0f * M_PI ) * nearZ;
    frustumW = frustumH * aspect;
    
    ksFrustum( result, -frustumW, frustumW, -frustumH, frustumH, nearZ, farZ );
}

void ksOrtho(KSMatrix4 *result, float left, float right, float bottom, float top, float nearZ, float farZ)
{
    float       deltaX = right - left;
    float       deltaY = top - bottom;
    float       deltaZ = farZ - nearZ;
    KSMatrix4    ortho;
    
    if ( (deltaX == 0.0f) || (deltaY == 0.0f) || (deltaZ == 0.0f) )
        return;
    
    ksMatrixLoadIdentity(&ortho);
    ortho.m[0][0] = 2.0f / deltaX;
    ortho.m[3][0] = -(right + left) / deltaX;
    ortho.m[1][1] = 2.0f / deltaY;
    ortho.m[3][1] = -(top + bottom) / deltaY;
    ortho.m[2][2] = -2.0f / deltaZ;
    ortho.m[3][2] = -(nearZ + farZ) / deltaZ;
    
    ksMatrixMultiply(result, &ortho, result);
}

void ksLookAt(KSMatrix4 * result, const KSVec3 * eye, const KSVec3 * target, const KSVec3 * up)
{
    KSVec3 side, up2, forward ;
	//ksVec4 eyePrime;
	KSMatrix4 transMat;
    
	ksVectorSubtract(&forward, target, eye);
	ksVectorNormalize(&forward);
    
	ksCrossProduct(&side, up, &forward);
	ksVectorNormalize(&side );
    
	ksCrossProduct(&up2, &side, &forward);
	ksVectorNormalize(&up2);
    
	ksMatrixLoadIdentity(result);
	result->m[0][0] = side.x;
	result->m[0][1] = side.y;
	result->m[0][2] = side.z;
	result->m[1][0] = up2.x;
	result->m[1][1] = up2.y;
	result->m[1][2] = up2.z;
	result->m[2][0] = -forward.x;
	result->m[2][1] = -forward.y;
	result->m[2][2] = -forward.z;
    
	ksMatrixLoadIdentity(&transMat);
	ksTranslate(&transMat, -eye->x, -eye->y, -eye->z);
    
	ksMatrixMultiply(result, result, &transMat);
    
	//eyePrime.x = -eye->x;
	//eyePrime.y = -eye->y;
	//eyePrime.z = -eye->z;
	//eyePrime.w = 1;
    
	//ksMatrixMultiplyVector(&eyePrime, result, &eyePrime);
	//ksMatrixTranspose(result, result);
    
	//result->m[3][0] = eyePrime.x;
	//result->m[3][1] = eyePrime.y;
	//result->m[3][2] = eyePrime.z;
	//result->m[3][3] = eyePrime.w;
}
