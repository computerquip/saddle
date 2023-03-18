cmake_minimum_required(VERSION 3.25.1)
project(saddle)

add_library(saddle::headers IMPORTED INTERFACE)
target_include_directories(saddle::headers INTERFACE include)
target_compile_features(saddle::headers INTERFACE cxx_std_20)

add_subdirectory(src)