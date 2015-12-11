#include <mix/mix_allocator.h>

namespace mix
{
    AllocatorI& AllocatorI::getDefault()
    {
        static AllocatorCrt<0> _alloc;
        return _alloc;
    }
}

#if defined (MIX_TESTS)
#   include "mix_allocator.tests.inl"
#endif
