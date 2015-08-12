#ifndef MIX_RESULT_H
#define MIX_RESULT_H

namespace mix
{

class Result
{
public:
    static Result ok (void);
    static Result fail (const char* _why);
    
    Result (void);
    Result (bool _ok, const char* _why = nullptr);
    
    bool isOK() const;
    bool isFail() const;
    
    const char* why() const;
    
private:
    bool m_ok;
    const char* m_why;
};

    
} // namespace mix

#endif // MIX_RESULT_H
