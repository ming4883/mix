#include <mix/mix_zipfile.h>
#include <unzip.h>
#include <memory>

namespace mix
{
    ZipFile::ZipFile (const char* _filepath)
        : m_filepath (_filepath)
        , m_handle (nullptr)
    {
    }

    ZipFile::~ZipFile()
    {
    }

    Result ZipFile::beginRead()
    {
        ::unzFile _file = ::unzOpen (m_filepath.c_str());

        if (nullptr == _file)
            return Result::fail ("::unzOpen failed");

        m_handle = _file;

        return Result::ok();
    }

    Result ZipFile::read (Buffer& _outBuffer, const char* _pathInZip)
    {
        if (nullptr == m_handle)
            return Result::fail ("beginRead() was not invoked!");

        enum 
        {
            CaseSensitiveSys = 0,
            CaseSensitiveTrue = 1,
            CaseSensitiveFalse = 2,
        };

        if (UNZ_OK != ::unzLocateFile (m_handle, _pathInZip, CaseSensitiveFalse))
            return Result::fail ("file not exists in zip");

        unz_file_info _fileInfo;
        if (UNZ_OK != ::unzGetCurrentFileInfo (m_handle, &_fileInfo, nullptr, 0, nullptr, 0, nullptr, 0))
            return Result::fail ("failed to get current file info");

        Buffer _buf (_fileInfo.uncompressed_size);

        if (UNZ_OK != ::unzOpenCurrentFile (m_handle))
            return Result::fail ("failed to open current file");

        if (_fileInfo.uncompressed_size != ::unzReadCurrentFile (m_handle, _buf.ptr(), _buf.size()))
            return Result::fail ("failed to read current file");

        if (UNZ_CRCERROR == ::unzCloseCurrentFile(m_handle))
            return Result::fail ("error in current file's CRC");

        _outBuffer = std::move (_buf);

        return Result::ok();
    }

    void ZipFile::endRead()
    {
        if (nullptr != m_handle)
        {
            ::unzClose (m_handle);
            m_handle = nullptr;
        }
    }
}
