#ifndef MIX_SHADER_H
#define MIX_SHADER_H

#include <mix/mix_asset.h>
#include <bgfx.h>

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

} // namespace mix

#endif // MIX_SHADER_H
