//
//  GLESMath.h
//  Tutorial03
//
//  Created by kesalin@gmail.com on 12-11-26.
//  Copyright (c) 2012年 Created by kesalin@gmail.com on. All rights reserved.
//

#ifndef GLESMATH_H
#define GLESMATH_H

#include <OpenGLES/ES2/gl.h>

#ifndef M_PI
#define M_PI 3.1415926535897932384626433832795f
#endif

#define DEG2RAD( a ) (((a) * M_PI) / 180.0f)
#define RAD2DEG( a ) (((a) * 180.f) / M_PI)

// angle indexes
#define	PITCH				0		// up / down
#define	YAW					1		// left / right
#define	ROLL				2		// fall over

#ifdef __cplusplus
extern "C" {
#endif
    
    typedef unsigned char 		byte;
    
    typedef struct
    {
        GLfloat   m[4][4];
    } KSMatrix4;
    
    typedef GLfloat KSVec_t;
    typedef KSVec_t KSVec2[2];
    typedef KSVec_t KSVec3[3];
    typedef KSVec_t KSVec4[4];
    
    typedef struct cplane_s {
        KSVec3	normal;
        float	dist;
        byte	type;			// for fast side tests: 0,1,2 = axial, 3 = nonaxial
        byte	signbits;		// signx + (signy<<1) + (signz<<2), used as lookup during collision
        byte	pad[2];
    } cplane_t;
    
    typedef struct {
        KSVec3		origin;
        KSVec3		axis[3];
    } orientation_t;
    
    extern	KSVec3	vec3_origin;
    extern	KSVec3	axisDefault[3];
    
    //
    // Vector math utils
    //
    static inline void VectorInverse( KSVec3 v ) {
        v[0] = -v[0];
        v[1] = -v[1];
        v[2] = -v[2];
    }
    
    static inline void VectorClear( KSVec3 v ) {
        v[0] = v[1] = v[2] = 0;
    }
    
    static inline void VectorNegate( KSVec3 a, KSVec3 b ) {
        b[0] = -a[0];
        b[1] = -a[1];
        b[2] = -a[2];
    }
    
    static inline void VectorSet( KSVec3 out, KSVec_t x, KSVec_t y, KSVec_t z ) {
        out[0] = x;
        out[1] = y;
        out[2] = z;
    }
    
    static inline void VectorCopy( const KSVec3 in, KSVec3 out ) {
        out[0] = in[0];
        out[1] = in[1];
        out[2] = in[2];
    }
    
    static inline void Vector4Copy( const KSVec4 in, KSVec4 out ) {
        out[0] = in[0];
        out[1] = in[1];
        out[2] = in[2];
        out[3] = in[3];
    }
    
    static inline int VectorCompare( const KSVec3 v1, const KSVec3 v2 ) {
        if (v1[0] != v2[0] || v1[1] != v2[1] || v1[2] != v2[2]) {
            return 0;
        }

        return 1;
    }
    
    static inline KSVec_t VectorLengthSquared( const KSVec3 v ) {
        return (v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
    }
    
    static inline KSVec_t VectorLength( const KSVec3 v ) {
        return (KSVec_t)sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
    }
    
    static inline void VectorSubtract( const KSVec3 veca, const KSVec3 vecb, KSVec3 out ) {
        out[0] = veca[0]-vecb[0];
        out[1] = veca[1]-vecb[1];
        out[2] = veca[2]-vecb[2];
    }
    
    static inline void VectorAdd( const KSVec3 veca, const KSVec3 vecb, KSVec3 out ) {
        out[0] = veca[0]+vecb[0];
        out[1] = veca[1]+vecb[1];
        out[2] = veca[2]+vecb[2];
    }
    
    static inline void VectorScale( const KSVec3 in, KSVec_t scale, KSVec3 out ) {
        out[0] = in[0]*scale;
        out[1] = in[1]*scale;
        out[2] = in[2]*scale;
    }
    
    static inline void Vector4Scale( const KSVec4 in, KSVec_t scale, KSVec4 out ) {
        out[0] = in[0]*scale;
        out[1] = in[1]*scale;
        out[2] = in[2]*scale;
        out[3] = in[3]*scale;
    }
    
    static KSVec_t VectorNormalize( KSVec3 v ) {
        float length, ilength;
        
        length = v[0]*v[0] + v[1]*v[1] + v[2]*v[2];
        length = sqrt (length);
        
        if ( length ) {
            ilength = 1/length;
            v[0] *= ilength;
            v[1] *= ilength;
            v[2] *= ilength;
        }
        else {
            printf("Warning: zero length verctor when normalize.");
        }
        
        return length;
    }
    
    static inline void VectorMA( const KSVec3 veca, float scale, const KSVec3 vecb, KSVec3 vecc ) {
        vecc[0] = veca[0] + scale*vecb[0];
        vecc[1] = veca[1] + scale*vecb[1];
        vecc[2] = veca[2] + scale*vecb[2];
    }
    
    static inline KSVec_t Distance( const KSVec3 p1, const KSVec3 p2 ) {
        KSVec3	v;
        
        VectorSubtract (p2, p1, v);
        return VectorLength( v );
    }
    
    static inline KSVec_t DistanceSquared( const KSVec3 p1, const KSVec3 p2 ) {
        KSVec3	v;
        
        VectorSubtract (p2, p1, v);
        return v[0]*v[0] + v[1]*v[1] + v[2]*v[2];
    }
    
    static inline KSVec_t DotProduct( const KSVec3 v1, const KSVec3 v2 ) {
        return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
    }
    
    static inline void CrossProduct( const KSVec3 v1, const KSVec3 v2, KSVec3 cross ) {
        cross[0] = v1[1]*v2[2] - v1[2]*v2[1];
        cross[1] = v1[2]*v2[0] - v1[0]*v2[2];
        cross[2] = v1[0]*v2[1] - v1[1]*v2[0];
    }
    
    // axis and angles
    //
    void VecToAngles( const KSVec3 value1, KSVec3 angles );
    void AnglesToAxis( const KSVec3 angles, KSVec3 axis[3] );
    void AxisClear( KSVec3 axis[3] );
    void AxisCopy( KSVec3 in[3], KSVec3 out[3] );
    
    void AngleVectors( const KSVec3 angles, KSVec3 forward, KSVec3 right, KSVec3 up);
    float AngleMod(float a);
    float LerpAngle (float from, float to, float frac);
    float AngleSubtract( float a1, float a2 );
    void AnglesSubtract( KSVec3 v1, KSVec3 v2, KSVec3 v3 );
    
    float AngleNormalize360 ( float angle );
    float AngleNormalize180 ( float angle );
    float AngleDelta ( float angle1, float angle2 );
    
    // plane
    //
    void SetPlaneSignbits( struct cplane_s *out );
    int BoxOnPlaneSide (KSVec3 emins, KSVec3 emaxs, struct cplane_s *plane);

    unsigned char PlaneFromPoints( KSVec4 plane, const KSVec3 a, const KSVec3 b, const KSVec3 c );
    void ProjectPointOnPlane( KSVec3 dst, const KSVec3 p, const KSVec3 normal );
    void RotatePointAroundVector( KSVec3 dst, const KSVec3 dir, const KSVec3 point, float degrees );
    void RotateAroundDirection( KSVec3 axis[3], float yaw );
    void MakeNormalVectors( const KSVec3 forward, KSVec3 right, KSVec3 up );
    
    void MatrixMultiply(float in1[3][3], float in2[3][3], float out[3][3]);
    
    // assumes "src" is normalized
    //
    void PerpendicularVector( KSVec3 dst, const KSVec3 src );
    
    //
    /// multiply matrix specified by result with a scaling matrix and return new matrix in result
    /// result Specifies the input matrix.  Scaled matrix is returned in result.
    /// sx, sy, sz Scale factors along the x, y and z axes respectively
    //
    void ksScale(KSMatrix4 *result, GLfloat sx, GLfloat sy, GLfloat sz);
    
    //
    /// multiply matrix specified by result with a translation matrix and return new matrix in result
    /// result Specifies the input matrix.  Translated matrix is returned in result.
    /// tx, ty, tz Scale factors along the x, y and z axes respectively
    //
    void ksTranslate(KSMatrix4 *result, GLfloat tx, GLfloat ty, GLfloat tz);
    
    //
    /// multiply matrix specified by result with a rotation matrix and return new matrix in result
    /// result Specifies the input matrix.  Rotated matrix is returned in result.
    /// angle Specifies the angle of rotation, in degrees.
    /// x, y, z Specify the x, y and z coordinates of a vector, respectively
    //
    void ksRotate(KSMatrix4 *result, GLfloat angle, GLfloat x, GLfloat y, GLfloat z);

    //
    /// perform the following operation - result matrix = srcA matrix * srcB matrix
    /// result Returns multiplied matrix
    /// srcA, srcB Input matrices to be multiplied
    //
    void ksMatrixMultiply(KSMatrix4 *result, const KSMatrix4 *srcA, const KSMatrix4 *srcB);
    
    //
    //// return an indentity matrix 
    //// result returns identity matrix
    //
    void ksMatrixLoadIdentity(KSMatrix4 *result);
    
    //
    /// multiply matrix specified by result with a perspective matrix and return new matrix in result
    /// result Specifies the input matrix.  new matrix is returned in result.
    /// fovy Field of view y angle in degrees
    /// aspect Aspect ratio of screen
    /// nearZ Near plane distance
    /// farZ Far plane distance
    //
    void ksPerspective(KSMatrix4 *result, float fovy, float aspect, float nearZ, float farZ);
    
    //
    /// multiply matrix specified by result with a perspective matrix and return new matrix in result
    /// result Specifies the input matrix.  new matrix is returned in result.
    /// left, right Coordinates for the left and right vertical clipping planes
    /// bottom, top Coordinates for the bottom and top horizontal clipping planes
    /// nearZ, farZ Distances to the near and far depth clipping planes.  These values are negative if plane is behind the viewer
    //
    void ksOrtho(KSMatrix4 *result, float left, float right, float bottom, float top, float nearZ, float farZ);
    
    //
    // multiply matrix specified by result with a perspective matrix and return new matrix in result
    /// result Specifies the input matrix.  new matrix is returned in result.
    /// left, right Coordinates for the left and right vertical clipping planes
    /// bottom, top Coordinates for the bottom and top horizontal clipping planes
    /// nearZ, farZ Distances to the near and far depth clipping planes.  Both distances must be positive.
    //
    void ksFrustum(KSMatrix4 *result, float left, float right, float bottom, float top, float nearZ, float farZ);
    
#ifdef __cplusplus
}
#endif

#endif // GLESMATH_H
