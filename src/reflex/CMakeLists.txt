project(saddle-reflex)

add_executable(saddle-reflex reflex.cpp reflex.h)
add_library(saddle-reflex-runtime STATIC
    runtime/convert.cpp
    runtime/debug.cpp
    runtime/error.cpp
    runtime/input.cpp
    runtime/matcher_avx2.cpp
    runtime/matcher_avx512bw.cpp
    runtime/matcher.cpp
    runtime/pattern.cpp
    runtime/posix.cpp
    runtime/simd_avx2.cpp
    runtime/simd_avx512bw.cpp
    runtime/unicode.cpp
    runtime/utf8.cpp
    unicode/block_scripts.cpp
    unicode/language_scripts.cpp
    unicode/letter_scripts.cpp)

target_include_directories(saddle-reflex-runtime PUBLIC include)

target_link_libraries(saddle-reflex PRIVATE saddle-reflex-runtime)