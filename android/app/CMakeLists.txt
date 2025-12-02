cmake_minimum_required(VERSION 3.10)  # match root project

# Use modern C++
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# JNI bridge library: only Android‑specific sources
add_library(chiaki-jni SHARED
    src/main/cpp/chiaki-jni.c
    src/main/cpp/log.c
    src/main/cpp/video-decoder.c
    src/main/cpp/audio-decoder.c
    src/main/cpp/audio-output.cpp
)

# Link against the core Chiaki library
target_link_libraries(chiaki-jni PRIVATE chiaki-lib)

# Android system libraries
find_library(ANDROID_LIB_LOG log)
find_library(ANDROID_LIB_MEDIANDK mediandk)
find_library(ANDROID_LIB_ANDROID android)

target_link_libraries(chiaki-jni PRIVATE
    ${ANDROID_LIB_LOG}
    ${ANDROID_LIB_MEDIANDK}
    ${ANDROID_LIB_ANDROID}
)

# Oboe (vendored, only once)
add_subdirectory(src/main/cpp/oboe)
target_link_libraries(chiaki-jni PRIVATE oboe)
