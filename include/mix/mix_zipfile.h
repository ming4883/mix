#ifndef MIX_ZIPFILE_H
#define MIX_ZIPFILE_H

#include <mix/mix_buffer.h>
#include <mix/mix_result.h>
#include <mix/mix_string.h>
#include <bx/Mutex.h>

namespace mix
{

class ZipFile
{
public:
    ZipFile (const char* _filepath);
    ~ZipFile();

    Result beginRead();

    Result read (Buffer& _outBuffer, const char* _pathInZip);

    void endRead();

private:
    Utf8Buffer m_filepath;
    void* m_handle;
};

} // namespace mix

#endif // MIX_ZIPFILE_H
