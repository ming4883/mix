#if defined (MIX_ANDROID)

#include <mix/mix_asset.h>
#include <mix/mix_zipfile.h>
#include <mix/mix_string.h>
#include <mix/mix_log.h>

namespace mix
{
    class AssetImpl
    {
    public:
        static AssetImpl sharedInst;

        AssetImpl()
			: m_apkZipFile (nullptr)
        {
        }

        ~AssetImpl()
        {
			if (m_apkZipFile)
				Log::e ("Asset", "Asset::shutdown() was not invoked.");
        }
		
		Result init (const char* _apkPath)
		{
			m_apkZipFile = new ZipFile (_apkPath);
		}
		
		void shutdown (void)
		{
			delete m_apkZipFile;
			m_apkZipFile = nullptr;
		}

        //! Load all content of the raw path _filepath into _outBuffer
        Result load (Buffer& _outBuffer, const char* _filepath)
        {
			if (nullptr == m_apkZipFile)
                return Result::fail ("Asset::init() wasn't called.");

			Result _ret;
			
			_ret = m_apkZipFile->beginRead();
            if (_ret.isFail())
				return _ret;
			
			_ret = m_apkZipFile->read (_outBuffer, m_strfmt.format ("assets/%s", _filepath));
			
			if (_ret.isFail())
				Log::e ("Asset", "failed to load %s, %s", _filepath, _ret.why());
			
			m_apkZipFile->endRead();
			
			return _ret;
        }
		
	private:
		ZipFile* m_apkZipFile;
		StringFormatter m_strfmt;
    };

    AssetImpl AssetImpl::sharedInst;
    void Asset::init (void* _platformData)
    {
		AssetImpl::sharedInst.init ((const char*)_platformData);
    }

    void Asset::shutdown (void)
    {
		AssetImpl::sharedInst.shutdown();
    }

    Result Asset::load (Buffer& _outBuffer, const char* _assetname)
    {
        return AssetImpl::sharedInst.load (_outBuffer, _assetname);
    }
}

#endif // #if defined (MIX_ANDROID)
