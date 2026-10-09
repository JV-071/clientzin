otclient_add_gtest(runtime_event_tests runtime_event_test.cpp bitmapfont_test.cpp)
target_compile_definitions(runtime_event_tests PRIVATE CLIENTZIN_SOURCE_DIR="${CMAKE_SOURCE_DIR}")

# Control executable: no client headers, globals, or core/dependency libraries.
add_executable(native_exception_integrity_tests native_exception_integrity_test.cpp)
target_compile_features(native_exception_integrity_tests PRIVATE cxx_std_23)
target_link_libraries(native_exception_integrity_tests PRIVATE GTest::gtest_main)
if(MSVC)
    target_compile_options(native_exception_integrity_tests PRIVATE /EHsc /utf-8)
endif()
gtest_discover_tests(native_exception_integrity_tests DISCOVERY_MODE PRE_TEST)
