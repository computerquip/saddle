%require  "3.8"
%language "c++"

%define api.namespace {saddle}
%define api.parser.class {parser}
%define api.value.type variant
%define api.token.constructor

%define parse.error verbose

%defines

%output "parser.cpp"
%header "parser.hpp"

%locations
%define api.location.file "location.hpp"

%code requires {
#include <saddle/driver.hpp>
#include <typeinfo>

namespace saddle {
    class lexer; // Generated by reflex
}
}

%parse-param {saddle::lexer& lexer}
%parse-param {saddle::document &doc}

%code {
  #include "lexer.hpp" // Generated by Reflex
  #undef yylex
  #define yylex lexer.lex // We pass the lexer the first argument.
}

%define api.token.prefix {SDL_TK_}
%token                              EOF       0  "end of file"
%token <std::string>                NS           "namespace"
%token <std::string>                ATTR_ID      "attrib id"
%token <std::string>                ID           "id"
%token <std::string>                TEXT         "text"
%token <std::int32_t>               INT32        "int32"
%token <std::int64_t>               INT64        "int64"
%token <float>                      FLT32        "float32"
%token <double>                     FLT64        "float64"
%token <long double>                FLT128       "float128"
%token <bool>                       BOOLEAN      "boolean"
%token <std::vector<unsigned char>> BINARY       "binary"
%token                              LBRACKET     "{"
%token                              RBRACKET     "}"
%token                              SEMICOLON    ";"
%token                              EOL          "end of line"

%nterm <saddle::tag>                   tag
%nterm <saddle::tag::list_type>        tags
%nterm <saddle::tag::list_type>        children
%nterm <saddle::attribute>             attribute
%nterm <saddle::attribute::list_type>  attributes
%nterm <saddle::value>                 value
%nterm <saddle::value::list_type>      values

%%

document : tags EOF {
  doc.tags = std::move($1);
}

tags
  : %empty {
    /* do nothing */
  }

  | tags EOL {
    $$ = std::move($1);
  }

  | tags tag EOL {
    $1.push_back($2);
    $$ = std::move($1);
  }

  | tags tag SEMICOLON {
    $1.push_back($2);
    $$ = std::move($1);
  }

  | tags tag children {
    $2.children = std::move($3);
    $1.emplace_back(std::move($2));
    $$ = std::move($1);
  }
  ;

tag
  : ID values attributes {
    $$.name = $1;
    $$.values = std::move($2);
    $$.attribs = std::move($3);
  }

  | NS ID values attributes {
    $$.ns = $1;
    $$.name = $2;
    $$.values = std::move($3);
    $$.attribs = std::move($4);
  }

  | value values attributes {
    $$.name = "content";
    $$.values.push_back($1);
    $$.values = std::move($2);
    $$.attribs = std::move($3);
  }

;

children
  : LBRACKET tags RBRACKET {
    $$ = std::move($2);
  }

attributes
  : %empty { }
  | attributes attribute {
    $1.push_back(std::move($2));
    $$ = std::move($1);
  }
;

attribute
  : ATTR_ID value {
    $$.name = $1;
    $$.value = std::move($2);
  }

  | NS ATTR_ID value {
    $$.ns = $1;
    $$.name = $2;
    $$.value = std::move($3);
  }

values
  : %empty {}
  | values value {
    $1.emplace_back(std::move($2));
    $$ = std::move($1);
  }
;

value
  : INT32 {
    $$.kind = saddle::value_kind::int32;
    $$.data = $1;
  }

  | INT64 {
    $$.kind = saddle::value_kind::int64;
    $$.data = $1;
  }

  | FLT32 {
    $$.kind = saddle::value_kind::flt32;
    $$.data = $1;
  }

  | FLT64 {
    $$.kind = saddle::value_kind::flt64;
    $$.data = $1;
  }

  | FLT128 {
    $$.kind = saddle::value_kind::flt128;
    $$.data = $1;
  }

  | BOOLEAN {
    $$.kind = saddle::value_kind::boolean;
    $$.data = $1;
  }

  | TEXT {
    $$.kind = saddle::value_kind::text;
    $$.data = std::move($1);
  }

  | BINARY {
    $$.kind = saddle::value_kind::binary;
    $$.data = std::move($1);
  }
;

%%

void saddle::parser::error(const location_type& loc, const std::string& msg)
{
  std::cerr << msg << " at " << loc << std::endl;
}