#ifndef MIX_ASSET_H
#define MIX_ASSET_H

#include <mix/mix_buffer.h>
#include <mix/mix_result.h>
#include <mix/mix_string.h>
#include <bx/Mutex.h>
#include <bx/readerwriter.h>

namespace mix
{

class Asset
{
public:
    static void init();

    static void shutdown();

    static Result load (Buffer& _outBuffer, const char* _assetname);

private:
    friend class AssetImpl;
};

} // namespace mix

#endif // MIX_ASSET_H
