option(SADDLE_USE_BUILTIN_REFLEX "Use in-source version of RE/flex" ON)

if (SADDLE_USE_BUILTIN_REFLEX)
    set(SADDLE_REFLEX_EXE saddle-reflex)
else()
    find_package(Reflex REQUIRED)
    set(SADDLE_REFLEX_EXE Reflex::Reflex)
endif()

option(SADDLE_GENERATE_LEXER "Regenerate lexer with Genivia RE/flex" ON)
if (SADDLE_GENERATE_LEXER)
    add_custom_command(
        OUTPUT
            ${CMAKE_CURRENT_SOURCE_DIR}/lexer.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/lexer.hpp
        COMMAND
            ${SADDLE_REFLEX_EXE}
            --header-file=${CMAKE_CURRENT_SOURCE_DIR}/lexer.hpp
            # --debug
            ${CMAKE_CURRENT_SOURCE_DIR}/lexer.l
            -o ${CMAKE_CURRENT_SOURCE_DIR}/lexer.cpp
        WORKING_DIRECTORY
            ${CMAKE_CURRENT_SOURCE_DIR}
        DEPENDS
            ${CMAKE_CURRENT_SOURCE_DIR}/lexer.l
        COMMENT
            "Generating lexical analyzer"
    )
endif()

option(SADDLE_GENERATE_PARSER "Regenerate parser with GNU Bison" ON)
if (SADDLE_GENERATE_PARSER)
    find_package(BISON 3.8 REQUIRED)
    add_custom_command(
        OUTPUT
            ${CMAKE_CURRENT_SOURCE_DIR}/parser.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/parser.hpp
            ${CMAKE_CURRENT_SOURCE_DIR}/location.hpp
        COMMAND ${BISON_EXECUTABLE}
            --color=yes
            # --report=all
            # -Dparse.trace
            ${CMAKE_CURRENT_SOURCE_DIR}/parser.yy
        WORKING_DIRECTORY
            ${CMAKE_CURRENT_SOURCE_DIR}
        DEPENDS
            ${CMAKE_CURRENT_SOURCE_DIR}/parser.yy
        COMMENT
            "Generating parser"
    )
endif()

add_executable(saddle
    lexer.cpp
    lexer.hpp
    parser.cpp
    parser.hpp
    location.hpp
    main.cpp)

target_link_libraries(saddle
    PUBLIC
        saddle::headers
        saddle-reflex-runtime)

target_include_directories(saddle
    PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR})

target_compile_features(saddle
    PRIVATE
        cxx_std_17)