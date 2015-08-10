#if defined (MIX_ANDROID)

#include <mix/mix_asset.h>
#include <android/log.h>

namespace mix
{
    void Asset::init()
    {
    }

    void Asset::shutdown()
    {
    }

    Result Asset::load (Buffer& _outBuffer, const char* _assetname)
    {
        return Result::fail ("not supported");
    }
}

#endif // #if defined (MIX_ANDROID)
