#include <mix/mix_asset.h>

namespace mix
{
    void Asset::init (void* _platformData)
    {
    }

    void Asset::shutdown (void)
    {
    }

	Result Asset::load (Buffer& _outBuffer, const char* _assetname)
    {
        return Result::fail ("not supported");
    }
}
