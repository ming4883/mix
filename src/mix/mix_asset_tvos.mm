#if !defined (MIX_TESTS)

#include <mix/mix_asset.h>
#include <mix/mix_log.h>
#include <mix/mix_zipfile.h>

#import <Foundation/Foundation.h>
#include <sys/stat.h>

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
            return Result::ok();
        }

        void shutdown (void)
        {
            if (m_apkZipFile)
            {
                delete m_apkZipFile;
                m_apkZipFile = nullptr;
            }
        }

        //! Load all content of the raw path _filepath into _outBuffer
        Result load (Buffer& _outBuffer, const char* _filepath)
        {
            if (nullptr == m_apkZipFile)
                return Result::fail ("runtime.zip does not exists");

            Result _ret;

            _ret = m_apkZipFile->beginRead();
            if (_ret.isFail())
                return _ret;

            _ret = m_apkZipFile->read (_outBuffer, m_strfmt.format ("%s", _filepath));

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
        BX_UNUSED (_platformData)
        CFBundleRef _mainBundle = CFBundleGetMainBundle();
        if (_mainBundle != nil)
        {
            CFURLRef _resourceURL = CFBundleCopyResourceURL (_mainBundle, CFSTR("runtime"), CFSTR("zip"), NULL);
            if (_resourceURL != nil)
            {
                char _path[PATH_MAX];
                if (CFURLGetFileSystemRepresentation(_resourceURL, TRUE, (UInt8 *)_path, PATH_MAX) )
                {
                    struct stat _;
                    if (0 == stat(_path, &_) && _.st_size > 0)
                        AssetImpl::sharedInst.init (_path);
                }
                CFRelease(_resourceURL);
            }
        }
    }

    void Asset::shutdown (void)
    {
        AssetImpl::sharedInst.shutdown();
    }

	Result Asset::load (Buffer& _outBuffer, const char* _assetname)
    {
        return AssetImpl::sharedInst.load(_outBuffer, _assetname);
    }
}

#endif // #if !defined (MIX_TESTS)
