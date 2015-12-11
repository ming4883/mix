#ifndef MIX_RENDERING_H
#define MIX_RENDERING_H

#include <mix/mix_asset.h>
#include <mix/mix_pool.h>

#include <bgfx/bgfx.h>

namespace mix
{

class Shader
{
public:
    
    //! load a gpu program from assets.
    static bgfx::ProgramHandle loadFromAsset (const char* _vsPath, const char* _fsPath);

    /*! load a gpu program from assets with:
        vs: "shader/%s_vs_main.sb"
        fs: "shader/%s_fs_main.sb"
     */
    static bgfx::ProgramHandle loadFromAsset (const char* _name);
};

namespace RenderBucketFlags
{
    /*!
     1 << 0 : [0 - static IB, 1 - dynamic IB]
     1 << 1 : [0 - static VB, 1 - dynamic VB]
     others : reserved
    */
    enum Enum
    {
        IB_BIT = 0x0u,
        VB_BIT = 0x1u,
    };
}

class RenderBucket
{
public:
    uint32_t flags; //!< see RenderBucketFlags::Enum.
    uint64_t renderStates; //!< bgfx::setState()
    uint32_t blendFactors; //!< bgfx::setState()
    uint32_t stencilStates[2]; //!< bgfx::setStencil()

    bgfx::ProgramHandle program;

    union
    {
        bgfx::DynamicIndexBufferHandle ibDynamic;
        bgfx::IndexBufferHandle ibStatic;
    };
    uint32_t ibStart;
    uint32_t ibCount;

    union
    {
        bgfx::DynamicVertexBufferHandle vbDynamic;
        bgfx::VertexBufferHandle vbStatic;
    };
    uint32_t vbStart;
    uint32_t vbCount;

    //! Setup static index buffer bindings
    void setIBStatic (bgfx::IndexBufferHandle _ib, uint32_t _ibStart, uint32_t _ibCount);
    
    //! Setup dynamic index buffer bindings
    void setIBDynamic (bgfx::DynamicIndexBufferHandle _ib, uint32_t _ibStart, uint32_t _ibCount);

    //! Setup static index buffer bindings
    void setVBStatic (bgfx::VertexBufferHandle _vb, uint32_t _vbStart, uint32_t _vbCount);
    
    //! Setup dynamic index buffer bindings
    void setVBDynamic (bgfx::DynamicVertexBufferHandle _vb, uint32_t _vbStart, uint32_t _vbCount);
};

class RenderQueue
{
private:
    MIX_DECALRE_POOLTYPE(RenderBucketPool, RenderBucket);
    RenderBucketPool m_buckets;

public:
    RenderQueue (AllocatorI& _allocator, size_t _initialBucketCount);

    void reset();

    RenderBucket* addBucket();
};

} // namespace mix

#endif // MIX_RENDERING_H
