//
//  ksVector.c
//
//  Created by kesalin@gmail.com on 12-11-26.
//  Copyright (c) 2012. http://blog.csdn.net/kesalin/. All rights reserved.
//

#include "ksVector.h"
#include <math.h>

void ksVectorCopy(ksVec3 * out, const ksVec3 * in)
{
	out->x = in->x;
	out->y = in->y;
	out->z = in->z;
}

void ksVectorAdd(ksVec3 * out, const ksVec3 * a, const ksVec3 * b)
{
	out->x = a->x + b->x;
	out->y = a->y + b->y;
	out->z = a->z + b->z;
}

void ksVectorSubtract(ksVec3 * out, const ksVec3 * a, const ksVec3 * b)
{
	out->x = a->x - b->x;
	out->y = a->y - b->y;
	out->z = a->z - b->z;
}

void ksCrossProduct(ksVec3 * out, const ksVec3 * a, const ksVec3 * b)
{
	out->x = a->y * b->z - a->z * b->y;
	out->y = a->z * b->x - a->x * b->z;
	out->z = a->x * b->y - b->y * a->x;
}

float ksDotProduct(const ksVec3 * a, const ksVec3 * b)
{
	return (a->x * b->x + a->y * b->y + a->z * b->z);
}

void ksVectorLerp(ksVec3 * out, const ksVec3 * a, const ksVec3 * b, float t)
{
	out->x = (a->x * (1 - t) + b->x * t);
	out->y = (a->y * (1 - t) + b->y * t);
	out->z = (a->z * (1 - t) + b->z * t);
}

void ksVectorScale(ksVec3 * v, float scale)
{
	v->x *= scale;
	v->y *= scale;
	v->z *= scale;
}

void ksVectorInverse(ksVec3 * v)
{
	v->x = -v->x;
	v->y = -v->y;
	v->z = -v->z;
}

void ksVectorNormalize(ksVec3 * v)
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

int ksVectorCompare(const ksVec3 * a, const ksVec3 * b)
{
	if (a == b)
		return 1;

	if (a->x != b->x || a->y != b->y || a->z != b->z)
		return 0;
	return 1;
}

float ksVectorLength(const ksVec3 * in)
{
	return (float)sqrt(in->x * in->x + in->y * in->y + in->z * in->z);
}

float ksVectorLengthSquared(const ksVec3 * in)
{
	return (in->x * in->x + in->y * in->y + in->z * in->z);
}

float ksVectorDistance(const ksVec3 * a, const ksVec3 * b)
{
	ksVec3 v;
	ksVectorSubtract(&v, a, b);
	return ksVectorLength(&v);
}

float ksVectorDistanceSquared(const ksVec3 * a, const ksVec3 * b)
{
	ksVec3 v;
	ksVectorSubtract(&v, a, b);
	return (v.x * v.x + v.y * v.y + v.z * v.z);
}