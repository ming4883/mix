#ifndef MIX_MATH_H
#define MIX_MATH_H

#include <bx/float4_t.h>
#include <bx/float4x4_t.h>


namespace mix
{

struct Mat44
{
    static Mat44 cIdentity;
    // column-major layout
    // [0] [4] [8] [12]
    // [1] [5] [9] [13]
    // [2] [6] [10] [14]
    // [3] [7] [11] [15]
    float data[16];

    Mat44 (void) {}
    Mat44 (const float* _data)
    {
        data[0] = _data[0]; data[1] = _data[1]; data[2] = _data[2]; data[3] = _data[3];
        data[4] = _data[4]; data[5] = _data[5]; data[6] = _data[6]; data[7] = _data[7];
        data[8] = _data[8]; data[9] = _data[9]; data[10] = _data[10]; data[11] = _data[11];
        data[12] = _data[12]; data[13] = _data[13]; data[14] = _data[14]; data[15] = _data[15];
    }
    Mat44 (
        float _0, float _1, float _2, float _3,
        float _4, float _5, float _6, float _7,
        float _8, float _9, float _10, float _11,
        float _12, float _13, float _14, float _15)
    {
        data[0] = _0; data[1] = _1; data[2] = _2; data[3] = _3;
        data[4] = _4; data[5] = _5; data[6] = _6; data[7] = _7;
        data[8] = _8; data[9] = _9; data[10] = _10; data[11] = _11;
        data[12] = _12; data[13] = _13; data[14] = _14; data[15] = _15;
    }

    // row-major access helpers
    inline float& r00 (void) {return data[0];}
    inline float& r01 (void) {return data[4];}
    inline float& r02 (void) {return data[8];}
    inline float& r03 (void) {return data[12];}

    inline float& r10 (void) {return data[1];}
    inline float& r11 (void) {return data[5];}
    inline float& r12 (void) {return data[9];}
    inline float& r13 (void) {return data[13];}

    inline float& r20 (void) {return data[2];}
    inline float& r21 (void) {return data[6];}
    inline float& r22 (void) {return data[10];}
    inline float& r23 (void) {return data[14];}

    inline float& r30 (void) {return data[3];}
    inline float& r31 (void) {return data[7];}
    inline float& r32 (void) {return data[11];}
    inline float& r33 (void) {return data[15];}

    inline float r00 (void) const {return data[0];}
    inline float r01 (void) const {return data[4];}
    inline float r02 (void) const {return data[8];}
    inline float r03 (void) const {return data[12];}

    inline float r10 (void) const {return data[1];}
    inline float r11 (void) const {return data[5];}
    inline float r12 (void) const {return data[9];}
    inline float r13 (void) const {return data[13];}

    inline float r20 (void) const {return data[2];}
    inline float r21 (void) const {return data[6];}
    inline float r22 (void) const {return data[10];}
    inline float r23 (void) const {return data[14];}

    inline float r30 (void) const {return data[3];}
    inline float r31 (void) const {return data[7];}
    inline float r32 (void) const {return data[11];}
    inline float r33 (void) const {return data[15];}

    void getTranslation (float* _v3) const;
};

struct Transform
{
public:
    static Transform cIdentity;

    float position[3]; //!< vec3, xyz
    float orientation[4]; //!< quaternion, xyzw
    float scale[3]; //!< vec3, xyz

    Transform (void) {}

    Transform (const float* _pos, const float* _orient, const float* _scl)
    {
        position[0] = _pos[0];
        position[1] = _pos[1];
        position[2] = _pos[2];

        orientation[0] = _orient[0];
        orientation[1] = _orient[1];
        orientation[2] = _orient[2];
        orientation[3] = _orient[3];

        scale[0] = _scl[0];
        scale[1] = _scl[1];
        scale[2] = _scl[2];
    }

    Transform (
        float _px, float _py, float _pz,
        float _ox, float _oy, float _oz, float _ow,
        float _sx, float _sy, float _sz)
    {
        position[0] = _px;
        position[1] = _py;
        position[2] = _pz;

        orientation[0] = _ox;
        orientation[1] = _oy;
        orientation[2] = _oz;
        orientation[3] = _ow;

        scale[0] = _sx;
        scale[1] = _sy;
        scale[2] = _sz;
    }

    void transformPoint (float* _pt) const;
    void transformDirection (float* _dir) const;

    Transform inverse (void) const;
    Transform derive (Transform _parent) const;
    Mat44 toMat44 (void) const;

    void setRotations (const float* _r3);
    void getRotations (float* _r3) const;

    void getUpDir (float* _v3) const;
    void getRightDir (float* _v3) const;
    void getForwardDir (float* _v3) const;
};


} // namespace mix

#endif // MIX_MATH_H
