cmake_minimum_required(VERSION 3.16.3) # version on Ubuntu Focal
project(behaviortree_cpp)

set(BTCPP_LIBRARY ${PROJECT_NAME})

#---- Enable C++17 ----
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS -DWIN32_LEAN_AND_MEAN)
else()
    add_definitions(-Wpedantic)
endif()

#---- project configuration ----
option(BTCPP_SHARED_LIBS "Build shared libraries" ON)
option(BTCPP_MANUAL_SELECTOR "Build manual selector node" ON)
option(BTCPP_BUILD_TOOLS "Build commandline tools" ON)
option(BTCPP_EXAMPLES   "Build tutorials and examples" ON)
option(BTCPP_UNIT_TESTS "Build the unit tests" ON)

option(USE_V3_COMPATIBLE_NAMES  "Use some alias to compile more easily old 3.x code" OFF)

if(USE_V3_COMPATIBLE_NAMES)
    add_definitions(-DUSE_BTCPP3_OLD_NAMES)
endif()


# Update the policy setting to avoid an error when loading the ament_cmake package
# at the current cmake version level
if(POLICY CMP0057)
    cmake_policy(SET CMP0057 NEW)
endif()

find_package(ament_cmake QUIET)
if ( ament_cmake_FOUND )

    add_definitions( -DUSING_ROS2 )
    message(STATUS "------------------------------------------")
    message(STATUS "BehaviourTree is being built using AMENT.")
    message(STATUS "------------------------------------------")
    include(cmake/colcon_build.cmake)

elseif( CATKIN_DEVEL_PREFIX OR CATKIN_BUILD_BINARY_PACKAGE)

    add_definitions( -DUSING_ROS )
    message(STATUS "------------------------------------------")
    message(STATUS "BehaviourTree is being built using CATKIN.")
    message(STATUS "------------------------------------------")
    include(cmake/catkin_build.cmake)

else()
    message(STATUS "------------------------------------------")
    message(STATUS "BehaviourTree is being built with conan.")
    message(STATUS "------------------------------------------")
    include(cmake/conan_build.cmake)
endif()


#############################################################
# LIBRARY

add_subdirectory(3rdparty/lexy)

list(APPEND BT_SOURCE
    src/action_node.cpp
    src/basic_types.cpp
    src/behavior_tree.cpp
    src/blackboard.cpp
    src/bt_factory.cpp
    src/decorator_node.cpp
    src/condition_node.cpp
    src/control_node.cpp
    src/shared_library.cpp
    src/tree_node.cpp
    src/script_parser.cpp
    src/json_export.cpp
    src/xml_parsing.cpp

    src/actions/test_node.cpp

    src/decorators/inverter_node.cpp
    src/decorators/repeat_node.cpp
    src/decorators/retry_node.cpp
    src/decorators/subtree_node.cpp
    src/decorators/delay_node.cpp

    src/controls/if_then_else_node.cpp
    src/controls/fallback_node.cpp
    src/controls/parallel_node.cpp
    src/controls/reactive_sequence.cpp
    src/controls/reactive_fallback.cpp
    src/controls/sequence_node.cpp
    src/controls/sequence_star_node.cpp
    src/controls/switch_node.cpp
    src/controls/while_do_else_node.cpp

    src/loggers/bt_cout_logger.cpp
    src/loggers/bt_file_logger.cpp
    src/loggers/bt_minitrace_logger.cpp
    src/loggers/bt_observer.cpp
    src/loggers/groot2_publisher.cpp

    src/controls/manual_node.cpp

    3rdparty/tinyxml2/tinyxml2.cpp
    3rdparty/minitrace/minitrace.cpp
    )


######################################################

if (UNIX)
    list(APPEND BT_SOURCE src/shared_library_UNIX.cpp )
endif()

if (WIN32)
    set(CMAKE_DEBUG_POSTFIX "d")
    list(APPEND BT_SOURCE src/shared_library_WIN.cpp )
endif()

if (BTCPP_SHARED_LIBS)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
    add_library(${BTCPP_LIBRARY} SHARED ${BT_SOURCE})
else()
    add_library(${BTCPP_LIBRARY} STATIC ${BT_SOURCE})
endif()

message(STATUS "BTCPP_EXTRA_LIBRARIES: ${BTCPP_EXTRA_LIBRARIES}")

target_link_libraries(${BTCPP_LIBRARY}
    PRIVATE
        ${CMAKE_DL_LIBS}
        $<BUILD_INTERFACE:foonathan::lexy>
        ${BTCPP_EXTRA_LIBRARIES}
)

target_include_directories(${BTCPP_LIBRARY}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/3rdparty>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/lexy/include>
        $<BUILD_INTERFACE:${BTCPP_EXTRA_INCLUDE_DIRS}>
    )

target_compile_definitions(${BTCPP_LIBRARY} PRIVATE $<$<CONFIG:Debug>:TINYXML2_DEBUG>)

if(MSVC)
else()
    target_compile_options(${BTCPP_LIBRARY} PRIVATE -Wall -Wextra)
endif()

#############################################################
message( STATUS "BTCPP_LIB_DESTINATION:   ${BTCPP_LIB_DESTINATION} " )
message( STATUS "BTCPP_INCLUDE_DESTINATION: ${BTCPP_INCLUDE_DESTINATION} " )
message( STATUS "BTCPP_UNIT_TESTS:   ${BTCPP_UNIT_TESTS} " )

add_subdirectory(sample_nodes)

######################################################
# Test
if (BTCPP_UNIT_TESTS)
    add_subdirectory(tests)
endif()

######################################################
# INSTALL

INSTALL(TARGETS ${BTCPP_LIBRARY}
    EXPORT ${PROJECT_NAME}Targets
    ARCHIVE DESTINATION ${BTCPP_LIB_DESTINATION}
    LIBRARY DESTINATION ${BTCPP_LIB_DESTINATION}
    RUNTIME DESTINATION ${BTCPP_BIN_DESTINATION}
    )

INSTALL( DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
    DESTINATION ${BTCPP_INCLUDE_DESTINATION}
    FILES_MATCHING PATTERN "*.h*")

install(EXPORT ${PROJECT_NAME}Targets
    FILE "${PROJECT_NAME}Targets.cmake"
    DESTINATION "${BTCPP_LIB_DESTINATION}/cmake/${PROJECT_NAME}"
    NAMESPACE BT::
    )

export(PACKAGE ${PROJECT_NAME})

include(CMakePackageConfigHelpers)

configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Config.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
  INSTALL_DESTINATION "${BTCPP_LIB_DESTINATION}/cmake/${PROJECT_NAME}"
)

install(
  FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
    #    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    DESTINATION "${BTCPP_LIB_DESTINATION}/cmake/${PROJECT_NAME}"
)

######################################################
# EXAMPLES and TOOLS
if(BTCPP_BUILD_TOOLS)
    add_subdirectory(tools)
endif()

if(BTCPP_EXAMPLES)
    add_subdirectory(examples)
endif()
