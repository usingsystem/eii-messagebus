# Copyright (c) 2019 Intel Corporation.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
set(CMAKE_CXX_STANDARD 11)
configure_file(${PROJECT_SOURCE_DIR}/cmake/GoogleTestCMakeLists.txt.in googletest-download/CMakeLists.txt)
execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
                RESULT_VARIABLE result
                WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/googletest-download)
if(result)
    message(FATAL_ERROR "CMake step for googletest failed: ${result}")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} --build .
                RESULT_VARIABLE result
                WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/googletest-download)
if(result)
    message(FATAL_ERROR "Build step for googletest failed: ${result}")
endif()

# Prevent overriding the parent project's compiler/linker
# settings on Windows
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

# Add googletest directly to our build. This defines
# the gtest and gtest_main targets.
add_subdirectory(${CMAKE_CURRENT_BINARY_DIR}/googletest-src
                 ${CMAKE_CURRENT_BINARY_DIR}/googletest-build
                 EXCLUDE_FROM_ALL)

# The gtest/gtest_main targets carry header search path
# dependencies automatically when using CMake 2.8.11 or
# later. Otherwise we have to add them here ourselves.
if (CMAKE_VERSION VERSION_LESS 2.8.11)
    include_directories("${gtest_SOURCE_DIR}/include")
endif()

# Now simply link against gtest or gtest_main as needed. Eg
add_executable(msgbus-tests "msgbus_tests.cpp")
target_link_libraries(msgbus-tests eiimsgbus gtest_main)
add_test(NAME msgbus-tests COMMAND msgbus-tests)

# Make temporary IPC socket file directory
file(MAKE_DIRECTORY "/tmp/socks")

# Copy JSON configuration for msgbus-tests
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/ipc_unittest_config.json"
     DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/tcp_unittest_config.json"
     DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/dyn_unittest_config.json"
     DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")

# Compile test protocol plugin library
add_library(test-proto SHARED "test_proto_plugin.c")
target_link_libraries(test-proto eiimsgbus ${EIIUtils_LIBRARIES})

# Compile tests for message envelopes and the supporting utilities
add_executable(msg-envelope-tests "msg_envelope_tests.cpp")
target_link_libraries(msg-envelope-tests eiimsgenv gtest_main)
add_test(NAME msg-envelope-tests COMMAND msg-envelope-tests)

add_executable(crc32-tests "crc32_tests.cpp")
target_link_libraries(crc32-tests eiimsgenv gtest_main)
add_test(NAME crc32-tests COMMAND crc32-tests)

add_executable(hashmap-tests "hashmap_tests.cpp")
target_link_libraries(hashmap-tests eiimsgenv gtest_main)
add_test(NAME hashmap-tests COMMAND hashmap-tests)

add_executable(linkedlist-tests "linkedlist_tests.cpp")
target_link_libraries(linkedlist-tests eiimsgenv gtest_main)
add_test(NAME linkedlist-tests COMMAND linkedlist-tests)
