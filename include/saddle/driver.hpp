#ifndef C6AC23ED_1CD6_4391_AF8F_627ACF305FE0
#define C6AC23ED_1CD6_4391_AF8F_627ACF305FE0

#include "parser.hpp"

#include <list>
#include <string>
#include <variant>

namespace saddle
{

template <typename T>
using list_type = std::list<T>;

enum class value_kind
{
    text,
    int32,
    int64,
    flt32,
    flt64,
    flt128,
    boolean,
    binary,
};

using value_type =
    std::variant<
        std::monostate,
        std::string,
        std::int32_t,
        std::int64_t,
        float,
        double,
        long double,
        bool,
        std::vector<unsigned char>
    >;

struct value
{
    using list_type = list_type<value>;

    value_kind kind;
    value_type data;
};

struct attribute
{
    using list_type = list_type<attribute>;

    std::string ns;
    std::string name;

    value value;
};

struct tag
{
    using list_type = list_type<tag>;

    std::string ns;
    std::string name;
    value::list_type values;
    attribute::list_type attribs;
    tag::list_type children;
};

struct document
{
    tag::list_type tags;
};

// class parser
// {
//     explicit parser(FILE *);
//     explicit parser(std::istream &);
//     explicit parser(std::string_view &);

//     parser(parser &) = delete;
//     parser(parser &&) = delete;
//     parser &operator=(parser &) = delete;
//     parser &operator=(parser &&) = delete;

// };

}

#endif /* C6AC23ED_1CD6_4391_AF8F_627ACF305FE0 */
