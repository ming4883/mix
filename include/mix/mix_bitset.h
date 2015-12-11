#ifndef MIX_BITSET_H
#define MIX_BITSET_H

#include <bx/bx.h>
#include <assert.h>

namespace mix
{

/*! Helper for bit operations.
    Bits are counted from zero and the counting direction is from right to left 
    i.e. [bit-7 bit-6 bit-5 bit-4 bit-3 bit-2 bit-1 bit-0]
 */
class Bitset
{
public:
    template<typename INT_TYPE>
    static BX_FORCE_INLINE void set(INT_TYPE& _bits, uint8_t _whichBit)
    {
        assert(_whichBit < sizeof (INT_TYPE) * 8);
        _bits = _bits | (1 << _whichBit);
    }

    template<typename INT_TYPE>
    static BX_FORCE_INLINE void unset(INT_TYPE& _bits, uint8_t _whichBit)
    {
        assert(_whichBit < sizeof (INT_TYPE) * 8);
        _bits = _bits & ~(1 << _whichBit);
    }

    template<typename INT_TYPE>
    static BX_FORCE_INLINE bool test(INT_TYPE _bits, uint8_t _whichBit)
    {
        assert(_whichBit < sizeof (INT_TYPE) * 8);
        return (_bits & (1 << _whichBit)) > 0;
    }
};


} // namespace mix

#endif // MIX_BITSET_H
