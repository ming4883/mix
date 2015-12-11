#if !defined (MIX_TESTS)

#include <mix/mix_rendering.h>
#include <mix/mix_log.h>
#include <mix/mix_string.h>
#include <mix/mix_bitset.h>

namespace mix
{
    
    bgfx::ProgramHandle Shader::loadFromAsset (const char* _vsPath, const char* _fsPath)
    {
        Buffer _buf;
        Result _ret;

        bgfx::ShaderHandle _vsh, _fsh;

        if ((_ret = Asset::load (_buf, _vsPath)).isFail())
        {
            Log::e ("app", "failed to load vertex shader: %s", _ret.why());
            return BGFX_INVALID_HANDLE;
        }

        _vsh = bgfx::createShader (bgfx::copy (_buf.ptr(), _buf.size()));
        if (!bgfx::isValid (_vsh))
        {
            Log::e ("app", "failed to create vertex shader");
        }

        if ((_ret = Asset::load (_buf, _fsPath)).isFail())
        {
            Log::e ("app", "failed to load fragment shader: %s", _ret.why());
            return BGFX_INVALID_HANDLE;
        }

        _fsh = bgfx::createShader (bgfx::copy (_buf.ptr(), _buf.size()));
        if (!bgfx::isValid (_fsh))
        {
            Log::e ("app", "failed to create fragment shader");
        }

        return bgfx::createProgram (_vsh, _fsh, true);
    }
    
    bgfx::ProgramHandle Shader::loadFromAsset (const char* _name)
    {
        StringFormatter _vspath, _fspath;
        return loadFromAsset (_vspath.format ("shader/%s_vs_main.sb", _name), _fspath.format("shader/%s_fs_main.sb", _name));

    }

    void RenderBucket::setIBStatic (bgfx::IndexBufferHandle _ib, uint32_t _ibStart, uint32_t _ibCount)
    {
        ibStatic = _ib;
        ibStart = _ibStart;
        ibCount = _ibCount;
        Bitset::unset(flags, RenderBucketFlags::IB_BIT);
    }
    
    void RenderBucket::setIBDynamic (bgfx::DynamicIndexBufferHandle _ib, uint32_t _ibStart, uint32_t _ibCount)
    {
        ibDynamic = _ib;
        ibStart = _ibStart;
        ibCount = _ibCount;
        Bitset::set(flags, RenderBucketFlags::IB_BIT);
    }

    void RenderBucket::setVBStatic (bgfx::VertexBufferHandle _vb, uint32_t _vbStart, uint32_t _vbCount)
    {
        vbStatic = _vb;
        vbStart = _vbStart;
        vbCount = _vbCount;
        Bitset::unset(flags, RenderBucketFlags::VB_BIT);
    }
    
    void RenderBucket::setVBDynamic (bgfx::DynamicVertexBufferHandle _vb, uint32_t _vbStart, uint32_t _vbCount)
    {
        vbDynamic = _vb;
        vbStart = _vbStart;
        vbCount = _vbCount;
        Bitset::set(flags, RenderBucketFlags::VB_BIT);
    }

    RenderQueue::RenderQueue (AllocatorI& _allocator, size_t _initialBucketCount)
        : m_buckets (_allocator, _initialBucketCount, _initialBucketCount * 4)
    {
    }

    void RenderQueue::reset()
    {
        m_buckets.delAllObjects();
    }

    RenderBucket* RenderQueue::addBucket()
    {
        return m_buckets.newObject();
    }
}

#endif
