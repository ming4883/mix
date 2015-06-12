#ifndef MIX_ARRAY_H
#define MIX_ARRAY_H

namespace mix
{

//! Provides various operations on c-style static array (e.g. char array[10]; int array[123];)
class CStaticArray
{
public: 
	//! Fill the whole static array with val.
    template<typename T, int N>
    static void fill (T (&_carray)[N], T&& val)
    {
        Elem<T, N-1>::set ((T*)_carray, val);
    }

	//! Returns the number of elements in a static array.
    template<typename T, int N>
    static int countof (T (&_carray)[N])
    {
        return N;
    }

private:
  	template<typename T, int N>
    struct Elem
    {
        static inline void set (T* array, T&& val)
        {
            array[N] = val;
            Elem<T, N-1>::set (array, (T&&)val);
        }

        static inline void set (T* array, T val)
        {
            array[N] = val;
            Elem<T, N-1>::set (array, val);
        }
    };

    template<typename T>
    struct Elem<T, 0>
    {
        static inline void set (T* array, T&& val)
        {
            array[0] = val;
        }

        static inline void set (T* array, T val)
        {
            array[0] = val;
        }
    };
 
};

} // namespace mix

#endif // MIX_ARRAY_H
