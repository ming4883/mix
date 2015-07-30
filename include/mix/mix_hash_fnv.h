#ifndef MIX_HASH_FNV_H
#define MIX_HASH_FNV_H

#include <bx/platform.h>

namespace mix
{

class HashFNV32
{
public:
    typedef int32_t HashCode;

    HashCode hashValue;

    // FNV1a
    enum { FNV_PRIME = 16777619u };

    /// Compile time implementation
    template <HashCode N, HashCode I>
    struct Fnv1aCT
    {
        inline static HashCode hash (const char (&str) [N])
        {
            return (Fnv1aCT<N, I-1>::hash (str) ^ str [I-1]) * FNV_PRIME;
        }
    };

    template <HashCode N>
    struct Fnv1aCT<N, 1>
    {
        inline static HashCode hash (const char (&str) [N])
        {
            return (2166136261u ^ str[0]) * FNV_PRIME;
        }
    };

    /// Run time implementation
    struct Fnv1aRT
    {
        inline static HashCode hashByte (unsigned char octet, HashCode seed)
        {
            return (seed ^ octet) * FNV_PRIME;
        }

        inline static HashCode hash (const void* data, unsigned long N)
        {
            HashCode hash = 2166136261u;

            const unsigned char* ptr = (unsigned char*) data;

            while (N--)
                hash = hashByte (*ptr++, hash);

            return hash;
        }
    };

    template <HashCode N>
    inline HashFNV32 (const char (&str) [N])
        : hashValue (Fnv1aCT<N, N>::hash (str))
    {
    }

    template <typename T>
    inline HashFNV32 (const T& data)
        : hashValue (Fnv1aRT::hash (&data, sizeof (T)))
    {
    }

    inline HashFNV32()
        : hashValue (0)
    {
    }

    inline HashFNV32 (const void* data, unsigned long numOfBytes)
        : hashValue (Fnv1aRT::hash (data, numOfBytes))
    {
    }

    bool operator == (const HashFNV32& rhs) const
    {
        return hashValue == rhs.hashValue;
    }

    bool operator != (const HashFNV32& rhs) const
    {
        return hashValue != rhs.hashValue;
    }

    bool operator < (const HashFNV32& rhs) const
    {
        return hashValue < rhs.hashValue;
    }

    bool operator > (const HashFNV32& rhs) const
    {
        return hashValue > rhs.hashValue;
    }

    operator int () const
    {
        return * ((int*)&hashValue);
    }
};

} // namespace mix

#endif // MIX_HASH_FNV_H
