#if defined (MIX_WINDOWS_DESKTOP)

#include <mix/mix_asset.h>
#include <mix/mix_application.h>
#include <Windows.h>
#include <memory>

namespace mix
{
    class AssetImpl
    {
    public:
        bx::FileReaderI* m_fileReader;
        bx::FileWriterI* m_fileWriter;

        static AssetImpl sharedInst;

        AssetImpl()
            : m_fileReader (new bx::CrtFileReader)
            , m_fileWriter (new bx::CrtFileWriter)
        {
        }

        ~AssetImpl()
        {
            delete m_fileReader;
            delete m_fileWriter;
        }

        //! Load all content of the raw path _filepath into _outBuffer
        Result load (Buffer& _outBuffer, const char* _filepath)
        {
            if (nullptr == m_fileReader)
                return Result::fail ("File Reader is not supported on this platform");

            if (0 != bx::open (m_fileReader, _filepath))
                return Result::fail ("cannot open file");
        
            uint32_t _size = (uint32_t)bx::getSize (m_fileReader);
            uint32_t _read = 0;

            if (_size > 0)
            {
                Buffer _buf (_size, nullptr);
                _read = (uint32_t)bx::read (m_fileReader, _buf.ptr(), _size);
                _outBuffer = std::move (_buf);
            }

            bx::close (m_fileReader);
            
            if (_size != _read)
                return Result::fail ("inconsistent size in bx::read()");

            return Result::ok();
        }

    };

    AssetImpl AssetImpl::sharedInst;

    void Asset::init (void* platformData)
    {
    }

    void Asset::shutdown (void)
    {
    }

    Result Asset::load (Buffer& _outBuffer, const char* _assetname)
    {
        mix::StringFormatter _filepath;

        // for running in deployed layout
        {
            Result _ret = AssetImpl::sharedInst.load (_outBuffer, _filepath.format ("runtime/%s", _assetname));
            if (_ret.isOK())
                return _ret;
        }
        
        return Result::fail ("asset not found");
    }
}

#endif // #if defined (MIX_WINDOWS_DESKTOP)
