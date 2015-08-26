#include <mix/mix_shader.h>
#include <mix/mix_log.h>
#include <mix/mix_string.h>

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
}
