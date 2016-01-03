
#include <mix/mix_math.h>

#include <bx/fpumath.h>

namespace mix
{

Mat44 Mat44::cIdentity (
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
    );

void Mat44::getTranslation (float* _v3) const
{
    _v3[0] = r03();
    _v3[1] = r13();
    _v3[2] = r23();
}

Transform Transform::cIdentity (
    0, 0, 0,
    0, 0, 0, 1,
    1, 1, 1);

void quatTransformVec3 (const float* _quat, float* _v3)
{
    // http://blog.molecular-matters.com/2013/05/24/a-faster-quaternion-vector-multiplication/
    // t = 2 * cross(q.xyz, v)
    // v' = v + q.w * t + cross(q.xyz, t)
    float _t[3];
    float _qwt[3];
    float _qxt[3];
    bx::vec3Cross(_t, _quat, _v3);
    bx::vec3Mul(_t, _t, 2);

    bx::vec3Cross(_qxt, _quat, _t);
    bx::vec3Mul(_qwt, _t, _quat[3]);
    bx::vec3Add(_v3, _v3, _qwt);
    bx::vec3Add(_v3, _v3, _qxt);
}

void Transform::transformPoint (float* _v3) const
{
    bx::vec3Mul(_v3, _v3, scale);
    quatTransformVec3(orientation, _v3);
    bx::vec3Add(_v3, _v3, position);
}

void Transform::transformDirection (float* _v3) const
{
    bx::vec3Mul(_v3, _v3, scale);
    quatTransformVec3(orientation, _v3);
}

Transform Transform::inverse (void) const
{
    Transform _inv;

// reference https://bitbucket.org/sinbad/ogre/src/b0aa50969c29851666250f74ee35a635b2d4097e/OgreMain/src/OgreMatrix4.cpp?at=default#cl-227
    _inv.scale[0] = 1.0f / scale[0];
    _inv.scale[1] = 1.0f / scale[1];
    _inv.scale[2] = 1.0f / scale[2];

    bx::quatInvert(_inv.orientation, orientation);

    bx::vec3Mul(_inv.position, position, -1);
    quatTransformVec3(_inv.orientation, _inv.position);
    bx::vec3Mul(_inv.position, _inv.position, _inv.scale);

    return _inv;
}

Transform Transform::derive (Transform _parent) const
{
    Transform _ret;
    bx::quatMul (_ret.orientation, _parent.orientation, orientation);

    bx::vec3Mul (_ret.scale, _parent.scale, scale);

    bx::vec3Mul (_ret.position, _parent.scale, position);

    quatTransformVec3(_parent.orientation, _ret.position);

    bx::vec3Add (_ret.position, _ret.position, _parent.position);

    return _ret;
}

Mat44 Transform::toMat44 (void) const
{
    Mat44 _rot, _ret;
    bx::mtxQuat(_rot.data, orientation);

    _ret.r00() = scale[0] * _rot.r00();
    _ret.r01() = scale[1] * _rot.r01();
    _ret.r02() = scale[2] * _rot.r02();
    _ret.r10() = scale[0] * _rot.r10();
    _ret.r11() = scale[1] * _rot.r11();
    _ret.r12() = scale[2] * _rot.r12();
    _ret.r20() = scale[0] * _rot.r20();
    _ret.r21() = scale[1] * _rot.r21();
    _ret.r22() = scale[2] * _rot.r22();

    _ret.r03() = position[0];
    _ret.r13() = position[1];
    _ret.r23() = position[2];

    _ret.r30() = _ret.r31() = _ret.r32() = 0;
    _ret.r33() = 1;

    return _ret;
}

}
