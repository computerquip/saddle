find_package(Catch2 3 REQUIRED)

add_executable(saddle-tests saddle-tests.cpp)

target_link_libraries(saddle-tests
    PRIVATE
        Catch2::Catch2WithMain
        saddle::headers
        saddle)

