#include <mix/mix_tests.h>
#include <string>

class TestsOfAllocator : public ::testing::Test
{
public:
    struct AllocOwner
    {
        mix::AllocatorI& m_alloc;

        std::string data;

        AllocOwner (mix::AllocatorI& _alloc)
            : m_alloc (_alloc)
        {
        }
    };


    struct NonAllocOwner
    {
        std::string data;

        NonAllocOwner()
        {
        }
    };
    
    TestsOfAllocator()
    {
    }

    void SetUp() override
    {
    }

    void TearDown() override
    {
    }
};

MIX_CLASS_IS_ALLOCATOR_OWNER (TestsOfAllocator::AllocOwner)

TEST_F (TestsOfAllocator, Allocator_Alignment)
{
    #define DoAllocatorAlignedTest(align) { \
        mix::AllocatorCrt<align> allocator;\
        void* _p = allocator.allocate(12);\
        EXPECT_EQ (0, reinterpret_cast<long> (_p) % align);\
        _p = allocator.reallocate (_p, 24);\
        EXPECT_EQ (0, reinterpret_cast<long> (_p) % align);\
        allocator.deallocate (_p);\
    }
    
    DoAllocatorAlignedTest (2);
    DoAllocatorAlignedTest (4);
    DoAllocatorAlignedTest (8);
    DoAllocatorAlignedTest (16);
    DoAllocatorAlignedTest (32);
    DoAllocatorAlignedTest (64);
    DoAllocatorAlignedTest (128);
}

TEST_F (TestsOfAllocator, Allocator_OwnerObjects)
{
    mix::AllocatorCrt<0> _alloc;

    {
        AllocOwner* _obj = mix_new <AllocOwner> (_alloc);
        mix_del (_alloc, _obj);
    }
    
    {
        NonAllocOwner* _obj = mix_new <NonAllocOwner> (_alloc);
        mix_del (_alloc, _obj);
    }
}
