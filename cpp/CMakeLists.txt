cmake_minimum_required(VERSION 3.0.0)
project(LetterPuzzle VERSION 0.1.0)

include(CTest)
enable_testing()

add_executable(LetterPuzzle main.cpp rules.cpp utils.cpp dicLogic.cpp letterPuzzle.cpp)
target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -Wpedantic)

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)