#include "lexer.hpp"
#include "parser.hpp"

#include <saddle/driver.hpp>
#include <cstdio>
#include <cinttypes>
#include <fstream>

void print_value(saddle::value &val)
{
    switch (val.kind) {
        case saddle::value_kind::text:
            printf("[text] %s", std::get<std::string>(val.data).c_str());
            break;

        case saddle::value_kind::binary: {
            auto v = std::get<std::vector<unsigned char>>(val.data);

            printf("[binary] ");

            for (auto ch : v) {
                printf("%02X", ch);
            }

            break;
        }

        case saddle::value_kind::boolean:
            printf("[bool] %s", std::get<bool>(val.data) ? "true" : "false");
            break;

        case saddle::value_kind::int32:
            printf("[int32] %" PRId32 , std::get<std::int32_t>(val.data));
            break;

        case saddle::value_kind::int64:
            printf("[int64] %" PRId64 , std::get<std::int64_t>(val.data));
            break;

        case saddle::value_kind::flt32:
            printf("[flt32] %f", std::get<float>(val.data));
            break;

        case saddle::value_kind::flt64:
            printf("[flt64] %lf", std::get<double>(val.data));
            break;

        case saddle::value_kind::flt128:
            printf("[flt128] %Lf", std::get<long double>(val.data));
            break;

        default:
            printf("[unknown]");
    }
}

void print_attribute(saddle::attribute &attrib)
{
    if (!attrib.ns.empty()) {
        printf("(%s) ", attrib.ns.c_str());
    }

    printf("%s = ", attrib.name.c_str());
    print_value(attrib.value);
}

void print_indent(int level)
{
    while (level > 0) {
        printf(" ");
        --level;
    }
}

void print_tags(saddle::tag::list_type &tags, int level);

void print_tag(saddle::tag &tag, int level)
{
    print_indent(level);

    if (!tag.ns.empty()) {
        printf("(%s) ", tag.ns.c_str());
    }

    printf("Tag: %s {\n", tag.name.c_str());

    if (!tag.values.empty()) {
        print_indent(level + 1);
        printf("Values [\n");

        for (saddle::value &val : tag.values) {
            print_indent(level + 2);
            print_value(val);
            printf("\n");
        }

        print_indent(level + 1);
        printf("]\n");
    }

    if (!tag.attribs.empty()) {
        print_indent(level + 1);
        printf("Attributes [\n");

        for (saddle::attribute &attrib : tag.attribs) {
            print_indent(level + 2);
            print_attribute(attrib);
            printf("\n");
        }

        print_indent(level + 1);
        printf("]\n");
    }

    if (!tag.children.empty()) {
        print_indent(level + 1);
        printf("Children [\n");

        print_tags(tag.children, level + 2);

        print_indent(level + 1);
        printf("]\n");
    }

    print_indent(level);
    printf("}\n");
}

void print_tags(saddle::tag::list_type &tags, int level)
{
    for (saddle::tag tag : tags) {
        print_tag(tag, level);
    }
}

int main(int argc, char **argv)
{
    /* Eventually, the driver will encompass both
     * the lexer and parser and will be the only
     * inclusion. */

    FILE *file = fopen(argv[1], "r");
    fseek(file, 0, SEEK_END);
    long fsize = ftell(file);
    fseek(file, 0, SEEK_SET);

    saddle::document ast;
    saddle::lexer lexer(file);
    lexer.filename = argv[1];

    saddle::parser parser(lexer, ast);
    // parser.set_debug_level(1);

    auto start = std::chrono::system_clock::now();

    std::vector<char> test;
    test.reserve(fsize);

#if 0
    for (long i = 0; i < fsize; ++i) {
        test.push_back((char)fgetc(file));
    }

#elif 1

    if (parser.parse() != 0) {
        std::cerr << "Failed to do the thing\n";
    }

    // print_tags(ast.tags, 0);

#elif 0

    for (;;) {
        saddle::parser::symbol_type tok = lexer.lex();

        if (tok.kind() == saddle::parser::symbol_kind_type::S_YYUNDEF) {
            printf("failed\n");
            return 1;
        }

        if (tok.kind() == saddle::parser::symbol_kind_type::S_YYEOF) {
            break;
        }
    }

#endif

    auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now() - start);
    printf("%lld", elapsed.count());
}