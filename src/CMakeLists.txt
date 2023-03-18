add_subdirectory(reflex)
add_subdirectory(parser)

option(SADDLE_BUILD_TESTS "Build tests for the things" ON)
if (SADDLE_BUILD_TESTS)
    #add_subdirectory(tests)
endif()