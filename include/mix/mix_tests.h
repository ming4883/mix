#ifndef MIX_TESTS_H
#define MIX_TESTS_H

#include <gtest/gtest.h>

#include <sstream>

#include <bx/thread.h>
#include <functional>

namespace mix
{

class TestListener : public ::testing::EmptyTestEventListener
{
public:
    typedef std::stringstream Stream;

    static std::string fmtTestCnt (int i)
    {
        Stream ret;
        ret << i;
        if (i > 1)
            ret << " tests";
        else
            ret << " test";

        return ret.str();
    }

    static std::string fmtTestCaseCnt (int i)
    {
        Stream ret;
        ret << i;
        if (i > 1)
            ret << " test cases";
        else
            ret << " test case";

        return ret.str();
    }

    static void output (bool _isError, Stream& _msg);

    void OnTestIterationStart (const ::testing::UnitTest& unit_test, int iter) override
    {
        Stream msg;
        msg << "\n";
        msg << "[==========] ";
        msg << "Running " << fmtTestCnt (unit_test.test_to_run_count()) << " from " << fmtTestCaseCnt (unit_test.test_case_to_run_count());
        msg << " (iteration " << (iter + 1) << ")";
        msg << "\n";

        output (false, msg);
    }

    void OnTestIterationEnd (const ::testing::UnitTest& unit_test, int) override
    {
        Stream msg;

        msg << "[==========] ";
        msg << fmtTestCnt (unit_test.test_to_run_count()) << " from " << fmtTestCaseCnt (unit_test.test_case_to_run_count()) << " ran.";

        if (::testing::GTEST_FLAG (print_time))
        {
            msg << " (" << unit_test.elapsed_time() << " ms total)";
        }
        msg << "\n";
        msg << "[  PASSED  ] " << fmtTestCnt (unit_test.successful_test_count()) << "\n";

        output (false, msg);

        if (!unit_test.Passed())
        {
            msg.clear();
            const int failed_test_count = unit_test.failed_test_count();
            msg << "[  FAILED  ] " << fmtTestCnt (failed_test_count) << "\n";

            output (true, msg);
        }
    }

    void OnTestCaseStart (const ::testing::TestCase& test_case) override
    {
        Stream msg;
        msg << "\n";
        msg << "[----------] " << fmtTestCnt (test_case.test_to_run_count()) << " from " << test_case.name() << "\n";
        output (false, msg);
    }

    void OnTestCaseEnd (const ::testing::TestCase& test_case) override
    {
        Stream msg;
        msg << "[----------] " << fmtTestCnt (test_case.test_to_run_count()) << " from " << test_case.name();

        if (::testing::GTEST_FLAG(print_time))
            msg << " (" << test_case.elapsed_time() << ") ms";

        msg << "\n";
        msg << "\n";
        output (false, msg);
    }

    void OnTestPartResult(const ::testing::TestPartResult& result) override
    {
        if (result.type() == ::testing::TestPartResult::kSuccess)
            return;

        const char* file_name = result.file_name();

        file_name = (nullptr == file_name) ? "unknown file" : file_name;

        Stream msg;
        msg << "\nat " << file_name << ":" << result.line_number() << ": Failure\n";
        msg << result.summary() << "\n";

        output (result.failed(), msg);
    }

    void OnTestStart (const ::testing::TestInfo& test_info)
    {
        const testing::TestResult& test_result = *test_info.result();

        Stream msg;
        msg << "[          ] " << test_info.name() << "\n";

        output (test_result.Failed(), msg);
    }

    void OnTestEnd (const ::testing::TestInfo& test_info) override
    {
        const testing::TestResult& test_result = *test_info.result();

        Stream msg;

        if (test_result.Passed())
            msg << "[       OK ] ";
        else if (test_result.HasNonfatalFailure())
            msg << "[     FAIL ] ";
        else
            msg << "[    FATAL ] ";

        msg << test_info.name();

        if (::testing::GTEST_FLAG(print_time))
            msg << " (" << test_result.elapsed_time() << ") ms";

        msg << "\n";

        output (test_result.Failed(), msg);
    }

};

class ThreadWithLambda : public bx::Thread
{
public:
    typedef std::function<int32_t (void*)> Func;
    
    ThreadWithLambda (Func&& _func) : m_func (_func)
    {

    }

    void init(void* _userdata, uint32_t _stackSize = 0, const char* _name = NULL)
    {
        m_userdata = _userdata;
        bx::Thread::init (&threadCallback, this, _stackSize, _name);
    }

private:
    Func m_func;
    void* m_userdata;

    using bx::Thread::init;

    static int32_t threadCallback (void* _userData)
    {
        ThreadWithLambda* _this = reinterpret_cast<ThreadWithLambda*> (_userData);
        return _this->m_func (_this->m_userdata);
    }
};

} // namespace mix

template<typename T, size_t SIZE>
::testing::AssertionResult ArraysMatch(const T (&expected)[SIZE], const T (&actual)[SIZE])
{
	for (size_t i(0); i < SIZE; ++i){
		if (expected[i] != actual[i]){
			return ::testing::AssertionFailure() << "array[" << i
				<< "] (" << actual[i] << ") != expected[" << i
				<< "] (" << expected[i] << ")";
		}
	}

	return ::testing::AssertionSuccess();
}

#endif // MIX_TESTS_H
