//
//  GLESMath.c
//  Tutorial03
//
//  Created by kesalin@gmail.com on 12-11-26.
//  Copyright (c) 2012年 Created by kesalin@gmail.com on. All rights reserved.
//

#include "GLESMath.h"
#include <stdlib.h>
#include <math.h>

KSVec3	vec3_origin = {0,0,0};
KSVec3	axisDefault[3] = { { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 } };

void *memcpy(void *, const void *, size_t);
void *memset(void *, int, size_t);

//
// Axis
// 
void VecToAngles( const KSVec3 value1, KSVec3 angles)
{
    float	forward;
	float	yaw, pitch;
    
	if ( value1[1] == 0 && value1[0] == 0 ) {
		yaw = 0;
		if ( value1[2] > 0 ) {
			pitch = 90;
		}
		else {
			pitch = 270;
		}
	}
	else {
		if ( value1[0] ) {
			yaw = ( atan2 ( value1[1], value1[0] ) * 180 / M_PI );
		}
		else if ( value1[1] > 0 ) {
			yaw = 90;
		}
		else {
			yaw = 270;
		}
		if ( yaw < 0 ) {
			yaw += 360;
		}
        
		forward = sqrt ( value1[0]*value1[0] + value1[1]*value1[1] );
		pitch = ( atan2(value1[2], forward) * 180 / M_PI );
		if ( pitch < 0 ) {
			pitch += 360;
		}
	}
    
	angles[PITCH] = -pitch;
	angles[YAW] = yaw;
	angles[ROLL] = 0;
}

void AnglesToAxis( const KSVec3 angles, KSVec3 axis[3] ) {
	KSVec3	right;
    
	// angle vectors returns "right" instead of "y axis"
	AngleVectors( angles, axis[0], right, axis[2] );
	VectorSubtract( vec3_origin, right, axis[1] );
}

void AxisClear( KSVec3 axis[3] )
{
	axis[0][0] = 1;
	axis[0][1] = 0;
	axis[0][2] = 0;
	axis[1][0] = 0;
	axis[1][1] = 1;
	axis[1][2] = 0;
	axis[2][0] = 0;
	axis[2][1] = 0;
	axis[2][2] = 1;
}

void AxisCopy( KSVec3 in[3], KSVec3 out[3] )
{
	VectorCopy( in[0], out[0] );
	VectorCopy( in[1], out[1] );
	VectorCopy( in[2], out[2] );
}

//
// Angle
//

void AngleVectors( const KSVec3 angles, KSVec3 forward, KSVec3 right, KSVec3 up)
{
    float           angle;
	static float    sr, sp, sy, cr, cp, cy;
	// static to help MS compiler fp bugs
    
	angle = angles[YAW] * (M_PI*2 / 360);
	sy = sin(angle);
	cy = cos(angle);
	angle = angles[PITCH] * (M_PI*2 / 360);
	sp = sin(angle);
	cp = cos(angle);
	angle = angles[ROLL] * (M_PI*2 / 360);
	sr = sin(angle);
	cr = cos(angle);
    
	if (forward)
	{
		forward[0] = cp*cy;
		forward[1] = cp*sy;
		forward[2] = -sp;
	}
	if (right)
	{
		right[0] = (-1*sr*sp*cy+-1*cr*-sy);
		right[1] = (-1*sr*sp*sy+-1*cr*cy);
		right[2] = -1*sr*cp;
	}
	if (up)
	{
		up[0] = (cr*sp*cy+-sr*-sy);
		up[1] = (cr*sp*sy+-sr*cy);
		up[2] = cr*cp;
	}
}

float LerpAngle (float from, float to, float frac) {
	float	a;
    
	if ( to - from > 180 ) {
		to -= 360;
	}
	if ( to - from < -180 ) {
		to += 360;
	}
	a = from + frac * (to - from);
    
	return a;
}

// Always returns a value from -180 to 180
float AngleSubtract( float a1, float a2 )
{
    float	a;
    
	a = a1 - a2;
	while ( a > 180 ) {
		a -= 360;
	}
	while ( a < -180 ) {
		a += 360;
	}
	return a;
}

void AnglesSubtract( KSVec3 v1, KSVec3 v2, KSVec3 v3 )
{
    v3[0] = AngleSubtract( v1[0], v2[0] );
	v3[1] = AngleSubtract( v1[1], v2[1] );
	v3[2] = AngleSubtract( v1[2], v2[2] );
}

float AngleMod(float a)
{
    a = (360.0/65536) * ((int)(a*(65536/360.0)) & 65535);
	return a;
}

// returns angle normalized to the range [0 <= angle < 360]
float AngleNormalize360 ( float angle )
{
    return (360.0 / 65536) * ((int)(angle * (65536 / 360.0)) & 65535);
}

float AngleNormalize180 ( float angle )
{
    angle = AngleNormalize360( angle );
	if ( angle > 180.0 ) {
		angle -= 360.0;
	}
	return angle;
}

float AngleDelta ( float angle1, float angle2 )
{
    return AngleNormalize180( angle1 - angle2 );
}

//
// Planes
//

void SetPlaneSignbits( struct cplane_s *out )
{
	int	bits, j;
    
	// for fast box on planeside test
	bits = 0;
	for (j=0 ; j<3 ; j++) {
		if (out->normal[j] < 0) {
			bits |= 1<<j;
		}
	}
	out->signbits = bits; 
}

int BoxOnPlaneSide (KSVec3 emins, KSVec3 emaxs, struct cplane_s *p)
{
    float	dist1, dist2;
	int		sides;
    
    // fast axial cases
	if (p->type < 3)
	{
		if (p->dist <= emins[p->type])
			return 1;
		if (p->dist >= emaxs[p->type])
			return 2;
		return 3;
	}
    
    // general case
	switch (p->signbits)
	{
        case 0:
            dist1 = p->normal[0]*emaxs[0] + p->normal[1]*emaxs[1] + p->normal[2]*emaxs[2];
            dist2 = p->normal[0]*emins[0] + p->normal[1]*emins[1] + p->normal[2]*emins[2];
            break;
        case 1:
            dist1 = p->normal[0]*emins[0] + p->normal[1]*emaxs[1] + p->normal[2]*emaxs[2];
            dist2 = p->normal[0]*emaxs[0] + p->normal[1]*emins[1] + p->normal[2]*emins[2];
            break;
        case 2:
            dist1 = p->normal[0]*emaxs[0] + p->normal[1]*emins[1] + p->normal[2]*emaxs[2];
            dist2 = p->normal[0]*emins[0] + p->normal[1]*emaxs[1] + p->normal[2]*emins[2];
            break;
        case 3:
            dist1 = p->normal[0]*emins[0] + p->normal[1]*emins[1] + p->normal[2]*emaxs[2];
            dist2 = p->normal[0]*emaxs[0] + p->normal[1]*emaxs[1] + p->normal[2]*emins[2];
            break;
        case 4:
            dist1 = p->normal[0]*emaxs[0] + p->normal[1]*emaxs[1] + p->normal[2]*emins[2];
            dist2 = p->normal[0]*emins[0] + p->normal[1]*emins[1] + p->normal[2]*emaxs[2];
            break;
        case 5:
            dist1 = p->normal[0]*emins[0] + p->normal[1]*emaxs[1] + p->normal[2]*emins[2];
            dist2 = p->normal[0]*emaxs[0] + p->normal[1]*emins[1] + p->normal[2]*emaxs[2];
            break;
        case 6:
            dist1 = p->normal[0]*emaxs[0] + p->normal[1]*emins[1] + p->normal[2]*emins[2];
            dist2 = p->normal[0]*emins[0] + p->normal[1]*emaxs[1] + p->normal[2]*emaxs[2];
            break;
        case 7:
            dist1 = p->normal[0]*emins[0] + p->normal[1]*emins[1] + p->normal[2]*emins[2];
            dist2 = p->normal[0]*emaxs[0] + p->normal[1]*emaxs[1] + p->normal[2]*emaxs[2];
            break;
        default:
            dist1 = dist2 = 0;		// shut up compiler
            break;
	}
    
	sides = 0;
	if (dist1 >= p->dist)
		sides = 1;
	if (dist2 < p->dist)
		sides |= 2;
    
	return sides;
}

// Returns 0 if the triangle is degenrate.
// The normal will point out of the clock for clockwise ordered points
unsigned char PlaneFromPoints( KSVec4 plane, const KSVec3 a, const KSVec3 b, const KSVec3 c )
{
    KSVec3	d1, d2;
    
	VectorSubtract( b, a, d1 );
	VectorSubtract( c, a, d2 );
	CrossProduct( d2, d1, plane );
	if ( VectorNormalize( plane ) == 0 ) {
		return 0;
	}
    
	plane[3] = DotProduct( a, plane );
	return 1;
}

void ProjectPointOnPlane( KSVec3 dst, const KSVec3 p, const KSVec3 normal )
{
    float d;
	KSVec3 n;
	float inv_denom;
    
	inv_denom =  DotProduct( normal, normal );
	inv_denom = 1.0f / inv_denom;
    
	d = DotProduct( normal, p ) * inv_denom;
    
	n[0] = normal[0] * inv_denom;
	n[1] = normal[1] * inv_denom;
	n[2] = normal[2] * inv_denom;
    
	dst[0] = p[0] - d * n[0];
	dst[1] = p[1] - d * n[1];
	dst[2] = p[2] - d * n[2];
}

void RotatePointAroundVector( KSVec3 dst, const KSVec3 dir, const KSVec3 point, float degrees )
{
 	float	m[3][3];
	float	im[3][3];
	float	zrot[3][3];
	float	tmpmat[3][3];
	float	rot[3][3];
	int	i;
	KSVec3 vr, vup, vf;
	float	rad;
    
	vf[0] = dir[0];
	vf[1] = dir[1];
	vf[2] = dir[2];
    
	PerpendicularVector( vr, dir );
	CrossProduct( vr, vf, vup );
    
	m[0][0] = vr[0];
	m[1][0] = vr[1];
	m[2][0] = vr[2];
    
	m[0][1] = vup[0];
	m[1][1] = vup[1];
	m[2][1] = vup[2];
    
	m[0][2] = vf[0];
	m[1][2] = vf[1];
	m[2][2] = vf[2];
    
	memcpy( im, m, sizeof( im ) );
    
	im[0][1] = m[1][0];
	im[0][2] = m[2][0];
	im[1][0] = m[0][1];
	im[1][2] = m[2][1];
	im[2][0] = m[0][2];
	im[2][1] = m[1][2];
    
	memset( zrot, 0, sizeof( zrot ) );
	zrot[0][0] = zrot[1][1] = zrot[2][2] = 1.0F;
    
	rad = DEG2RAD( degrees );
	zrot[0][0] = cos( rad );
	zrot[0][1] = sin( rad );
	zrot[1][0] = -sin( rad );
	zrot[1][1] = cos( rad );
    
	MatrixMultiply( m, zrot, tmpmat );
	MatrixMultiply( tmpmat, im, rot );
    
	for ( i = 0; i < 3; i++ ) {
		dst[i] = rot[i][0] * point[0] + rot[i][1] * point[1] + rot[i][2] * point[2];
	}   
}

void RotateAroundDirection( KSVec3 axis[3], float yaw )
{
    // create an arbitrary axis[1] 
	PerpendicularVector( axis[1], axis[0] );
    
	// rotate it around axis[0] by yaw
	if ( yaw ) {
		KSVec3	temp;
        
		VectorCopy( axis[1], temp );
		RotatePointAroundVector( axis[1], axis[0], temp, yaw );
	}
    
	// cross to get axis[2]
	CrossProduct( axis[0], axis[1], axis[2] );
}

// Given a normalized forward vector, create two other perpendicular vectors
void MakeNormalVectors( const KSVec3 forward, KSVec3 right, KSVec3 up )
{
    float		d;
    
	// this rotate and negate guarantees a vector
	// not colinear with the original
	right[1] = -forward[0];
	right[2] = forward[1];
	right[0] = forward[2];
    
	d = DotProduct (right, forward);
	VectorMA (right, -d, forward, right);
	VectorNormalize (right);
	CrossProduct (right, forward, up);
}

/*
 ** assumes "src" is normalized
 */
void PerpendicularVector( KSVec3 dst, const KSVec3 src )
{
    int	pos;
	int i;
	float minelem = 1.0F;
	KSVec3 tempvec;
    
	/*
     ** find the smallest magnitude axially aligned vector
     */
	for ( pos = 0, i = 0; i < 3; i++ )
	{
		if ( fabs( src[i] ) < minelem )
		{
			pos = i;
			minelem = fabs( src[i] );
		}
	}
	tempvec[0] = tempvec[1] = tempvec[2] = 0.0F;
	tempvec[pos] = 1.0F;
    
	/*
     ** project the point onto the plane defined by src
     */
	ProjectPointOnPlane( dst, tempvec, src );
    
	/*
     ** normalize the result
     */
	VectorNormalize( dst );
}

void MatrixMultiply(float in1[3][3], float in2[3][3], float out[3][3])
{
	out[0][0] = in1[0][0] * in2[0][0] + in1[0][1] * in2[1][0] +
    in1[0][2] * in2[2][0];
	out[0][1] = in1[0][0] * in2[0][1] + in1[0][1] * in2[1][1] +
    in1[0][2] * in2[2][1];
	out[0][2] = in1[0][0] * in2[0][2] + in1[0][1] * in2[1][2] +
    in1[0][2] * in2[2][2];
	out[1][0] = in1[1][0] * in2[0][0] + in1[1][1] * in2[1][0] +
    in1[1][2] * in2[2][0];
	out[1][1] = in1[1][0] * in2[0][1] + in1[1][1] * in2[1][1] +
    in1[1][2] * in2[2][1];
	out[1][2] = in1[1][0] * in2[0][2] + in1[1][1] * in2[1][2] +
    in1[1][2] * in2[2][2];
	out[2][0] = in1[2][0] * in2[0][0] + in1[2][1] * in2[1][0] +
    in1[2][2] * in2[2][0];
	out[2][1] = in1[2][0] * in2[0][1] + in1[2][1] * in2[1][1] +
    in1[2][2] * in2[2][1];
	out[2][2] = in1[2][0] * in2[0][2] + in1[2][1] * in2[1][2] +
    in1[2][2] * in2[2][2];
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


void ksMatrixLoadIdentity(KSMatrix4 *result)
{
    memset(result, 0x0, sizeof(KSMatrix4));

    result->m[0][0] = 1.0f;
    result->m[1][1] = 1.0f;
    result->m[2][2] = 1.0f;
    result->m[3][3] = 1.0f;
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
