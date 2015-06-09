#include <mix_entry/mix_event.h>

namespace mix
{

    Event::Event (HashFNV32 _type, Finalizer _finalizer)
        : type (_type)
        , m_finalizer (_finalizer)
        , m_next (nullptr)
    {
    }

}
