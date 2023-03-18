%option freespace
%option namespace=saddle
%option lexer=lexer
%option unicode
%option full

%option bison-complete
%option bison-cc-namespace=saddle
%option bison-cc-parser=parser
%option bison-locations

%top{
#include "parser.hpp"
#include "location.hpp"
#include "base64.hpp"

#include <ctime>
}

%class{
    std::tm time{};
    std::string tmp_str;
    base64::decoder b64_decoder;
}

dig          [[:digit:]]
id_start     [\p{UnicodeIdentifierStart}_]
id_continue  [\p{UnicodeIdentifierPart}\-]
id           {id_start} {id_continue}*
ns           {id} ":"
attr_id      {id} "="
mcm          "/*" .*? "*/"
scm          ( "//" | "--" | # ) [^\n]* ( \n | <<EOF>> )
wsp          [\p{Zs}\t]*
eol          [\n]
frc          {dig}* "." {dig}+ | {dig}+ "."
exp          "e" [+-]? {dig}+
flt          {frc} {exp}? | {dig}+ {exp}
f32          {flt}[Ff]
f64          {flt}[Dd]
f128         {flt}("BD"|"bd")
int          {dig}{dig}*
int64        {int}[Ll]
truthy       "on" | "true"
falsey       "off" | "false"
wysiwyg      "`" [^\n]*? "`"
base64       [A-Za-z0-9+/]* [=]{0,2}

%o tabs=4
%x ESC_STR
%x SCOMMENT
%x STR_NEXT_LINE
%x BASE64
%%

{mcm} /* ignored */
"#" .*  /* ignored */
"--" .* /* ignored */
"//" .* /* ignored */

{wsp}     /* ignored */
{eol}     { return parser::make_EOL(location()); }
{truthy}  { return parser::make_BOOLEAN(true, location()); }
{falsey}  { return parser::make_BOOLEAN(false, location()); }
{int}     { return parser::make_INT32(atol(text()), location()); }
{int64}   { return parser::make_INT64(atoll(text()), location()); }
{f32}     { return parser::make_FLT32(strtof(text(), NULL), location()); }
{f64}     { return parser::make_FLT64(strtod(text(), NULL), location()); }
{f128}    { return parser::make_FLT128(strtold(text(), NULL), location()); }
{wysiwyg} { return parser::make_TEXT({text() + 1, size() - 1}, location()); }
{id}      { return parser::make_ID(str(), location()); }
"{"       { return parser::make_LBRACKET(location()); }
"}"       { return parser::make_RBRACKET(location()); }
";"       { return parser::make_SEMICOLON(location()); }
\"[^"\\]* { tmp_str.append(text() + 1, size() - 1); start(ESC_STR); }
"["       { start(BASE64); }

{ns}      { return parser::make_NS({text(), size() - 1}, location()); }
{attr_id} { return parser::make_ATTR_ID({text(), size() - 1}, location()); }

<<EOF>>     { return parser::make_EOF(location()); }
.           { return parser::make_YYUNDEF(location()); }

<BASE64> {
    {base64} { b64_decoder.feed(text()); }
    {wsp}    /* ignored */
    {eol}    /* ignored */
    "]" {
        auto result = parser::make_BINARY(b64_decoder.finish(), location());
        b64_decoder = base64::decoder{};
        start(INITIAL);
        return result;
    }
    .        { return parser::make_YYUNDEF(location()); }
}

<ESC_STR> {
    [^"\\]+ { tmp_str.append(text()); }
    \\a     { tmp_str.push_back('\a'); }
    \\b     { tmp_str.push_back('\b'); }
    \\f     { tmp_str.push_back('\f'); }
    \\n     { tmp_str.push_back('\n'); }
    \\r     { tmp_str.push_back('\r'); }
    \\t     { tmp_str.push_back('\t'); }
    \\v     { tmp_str.push_back('\v'); }
    \\\\    { tmp_str.push_back('\\'); }
    \\\"    { tmp_str.push_back('\"'); }
    \\\n    { start(STR_NEXT_LINE); }

    \"      {
        auto result = parser::make_TEXT(std::move(tmp_str), location());
        tmp_str.clear();
        start(INITIAL);
        return result;
    }

    \\.     { return parser::make_YYUNDEF(location()); }
    .       { return parser::make_YYUNDEF(location()); }
}

<STR_NEXT_LINE> {
    {wsp}
    [^n] { matcher().less(0); start(ESC_STR); }
}

%%
