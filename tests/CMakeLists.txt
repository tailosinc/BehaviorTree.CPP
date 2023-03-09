
find_package(GTest REQUIRED)

set(TESTS_SRC
  src/action_test_node.cpp
  src/condition_test_node.cpp
  gtest_tree.cpp
  gtest_sequence.cpp
  gtest_parallel.cpp
  gtest_fallback.cpp
  gtest_factory.cpp
  gtest_decorator.cpp
  gtest_blackboard.cpp
  gtest_preconditions.cpp
  gtest_postconditions.cpp
  gtest_match.cpp
  gtest_ports.cpp
  gtest_skipping.cpp
  gtest_subtree.cpp
  gtest_switch.cpp
  gtest_wakeup.cpp
  gtest_coroutines.cpp
  test_helper.hpp
  gtest_json.cpp
  script_parser_test.cpp
)

enable_testing()

add_executable(${PROJECT_NAME}_test ${TESTS_SRC})
target_link_libraries(${PROJECT_NAME}_test
    ${BTCPP_LIBRARY}
    bt_sample_nodes
    foonathan::lexy
    GTest::gtest_main)

target_include_directories(${PROJECT_NAME}_test PRIVATE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/3rdparty>
)

target_compile_definitions(${PROJECT_NAME}_test PRIVATE
    BT_TEST_FOLDER="${CMAKE_CURRENT_SOURCE_DIR}")

add_test(BehaviorTreeCoreTest ${PROJECT_NAME}_test)

