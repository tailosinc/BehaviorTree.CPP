
include(${PROJECT_SOURCE_DIR}/cmake/conan.cmake)

conan_cmake_autodetect(CONAN_SETTINGS)
conan_cmake_install(PATH_OR_REFERENCE ${PROJECT_SOURCE_DIR}/conanfile.py
                    BUILD missing
                    REMOTE conancenter
                    SETTINGS ${CONAN_SETTINGS})

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()


set( BTCPP_EXTRA_LIBRARIES ${CONAN_LIBS})
set( BTCPP_LIB_DESTINATION     lib )
set( BTCPP_INCLUDE_DESTINATION include )
set( BTCPP_BIN_DESTINATION bin )

mark_as_advanced(
    BTCPP_EXTRA_LIBRARIES
    BTCPP_LIB_DESTINATION
    BTCPP_INCLUDE_DESTINATION
    BTCPP_BIN_DESTINATION )
