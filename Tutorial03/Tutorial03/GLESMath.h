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
#define M_PI 3.14159265358979323846f
#endif

#define DEG2RAD( a ) (((a) * M_PI) / 180.0f)
#define RAD2DEG( a ) (((a) * 180.f) / M_PI)

#define DotProduct(x,y)			((x)[0]*(y)[0]+(x)[1]*(y)[1]+(x)[2]*(y)[2])
#define VectorSubtract(a,b,c)	((c)[0]=(a)[0]-(b)[0],(c)[1]=(a)[1]-(b)[1],(c)[2]=(a)[2]-(b)[2])
#define VectorAdd(a,b,c)		((c)[0]=(a)[0]+(b)[0],(c)[1]=(a)[1]+(b)[1],(c)[2]=(a)[2]+(b)[2])
#define VectorCopy(a,b)			((b)[0]=(a)[0],(b)[1]=(a)[1],(b)[2]=(a)[2])
#define	VectorScale(v, s, o)	((o)[0]=(v)[0]*(s),(o)[1]=(v)[1]*(s),(o)[2]=(v)[2]*(s))
#define	VectorMA(v, s, b, o)	((o)[0]=(v)[0]+(b)[0]*(s),(o)[1]=(v)[1]+(b)[1]*(s),(o)[2]=(v)[2]+(b)[2]*(s))

#define VectorClear(a)			((a)[0]=(a)[1]=(a)[2]=0)
#define VectorNegate(a,b)		((b)[0]=-(a)[0],(b)[1]=-(a)[1],(b)[2]=-(a)[2])
#define VectorSet(v, x, y, z)	((v)[0]=(x), (v)[1]=(y), (v)[2]=(z))
#define Vector4Copy(a,b)		((b)[0]=(a)[0],(b)[1]=(a)[1],(b)[2]=(a)[2],(b)[3]=(a)[3])

#ifdef __cplusplus
extern "C" {
#endif
    
    typedef struct
    {
        GLfloat   m[4][4];
    } KSMatrix4;
    
    typedef GLfloat KSVec_t;
    typedef KSVec_t KSVec2[2];
    typedef KSVec_t KSVec3[3];
    typedef KSVec_t KSVec4[4];
    
    static inline int VectorCompare( const KSVec3 v1, const KSVec3 v2 )
    {
        if (v1[0] != v2[0] || v1[1] != v2[1] || v1[2] != v2[2]) {
            return 0;
        }			
        return 1;
    }
    
    static inline KSVec_t VectorLength( const KSVec3 v )
    {
        return (KSVec_t)sqrt (v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
    }
    
    static inline KSVec_t VectorLengthSquared( const KSVec3 v )
    {
        return (v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
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
    
    static inline void VectorNormalizeFast( KSVec3 v )
    {
//        float ilength = Q_rsqrt( DotProduct( v, v ) );
//        
//        v[0] *= ilength;
//        v[1] *= ilength;
//        v[2] *= ilength;
    }
    
    static inline void VectorInverse( KSVec3 v ){
        v[0] = -v[0];
        v[1] = -v[1];
        v[2] = -v[2];
    }
    
    static inline void CrossProduct( const KSVec3 v1, const KSVec3 v2, KSVec3 cross ) {
        cross[0] = v1[1]*v2[2] - v1[2]*v2[1];
        cross[1] = v1[2]*v2[0] - v1[0]*v2[2];
        cross[2] = v1[0]*v2[1] - v1[1]*v2[0];
    }
    
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
    void ksMatrixMultiply(KSMatrix4 *result, KSMatrix4 *srcA, KSMatrix4 *srcB);
    
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
