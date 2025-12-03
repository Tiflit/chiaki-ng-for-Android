cmake_minimum_required(VERSION 3.10)

project(chiaki)

# tri_option: like option(), but allows AUTO/ON/OFF values
macro(tri_option name desc default)
    set("${name}" "${default}" CACHE STRING "${desc}")
    set_property(CACHE "${name}" PROPERTY STRINGS AUTO ON OFF)
endmacro()

# ---- Feature toggles ----
option(CHIAKI_ENABLE_TESTS "Enable tests for Chiaki" ON)
option(CHIAKI_ENABLE_CLI "Enable CLI for Chiaki" ON)
option(CHIAKI_ENABLE_GUI "Enable Qt GUI" ON)
option(CHIAKI_ENABLE_ANDROID "Enable Android (used only via Gradle project)" OFF)
option(CHIAKI_ENABLE_BOREALIS "Enable Borealis GUI (Switch/PC)" OFF)
tri_option(CHIAKI_ENABLE_SETSU "Enable libsetsu for touchpad input (Linux only)" AUTO)
tri_option(CHIAKI_ENABLE_STEAMDECK_NATIVE "Enable Steam Deck native gyro/haptics" ON)
option(CHIAKI_LIB_ENABLE_OPUS "Use Opus codec in Chiaki Lib" ON)
tri_option(CHIAKI_ENABLE_SPEEX "Use speex for echo cancelling mic playback" AUTO)
tri_option(CHIAKI_ENABLE_RUDP "Enable Remote Play over Internet" AUTO)

# Default ffmpeg decoder setting depends on GUI/Borealis
if(CHIAKI_ENABLE_GUI OR CHIAKI_ENABLE_BOREALIS)
    set(CHIAKI_FFMPEG_DEFAULT ON)
else()
    set(CHIAKI_FFMPEG_DEFAULT AUTO)
endif()
tri_option(CHIAKI_ENABLE_FFMPEG_DECODER "Enable FFMPEG video decoder" ${CHIAKI_FFMPEG_DEFAULT})
tri_option(CHIAKI_ENABLE_PI_DECODER "Enable Raspberry Pi-specific decoder" AUTO)

# Crypto library options
option(CHIAKI_LIB_ENABLE_MBEDTLS "Use mbedtls instead of OpenSSL" OFF)
option(CHIAKI_LIB_MBEDTLS_EXTERNAL_PROJECT "Fetch Mbed TLS via CMake external project" OFF)
option(CHIAKI_LIB_OPENSSL_EXTERNAL_PROJECT "Use OpenSSL as CMake external project" OFF)

# ---- Android-specific overrides ----
if(CHIAKI_ENABLE_ANDROID)
    # On Android we link against prebuilt OpenSSL (cross-compiled separately).
    set(CHIAKI_LIB_OPENSSL_EXTERNAL_PROJECT OFF CACHE BOOL "" FORCE)

    # Disable all desktop-only modules/features
    set(CHIAKI_ENABLE_STEAMDECK_NATIVE OFF CACHE BOOL "" FORCE)
    set(CHIAKI_ENABLE_STEAM_SHORTCUT OFF CACHE BOOL "" FORCE)
    set(CHIAKI_ENABLE_FFMPEG_DECODER OFF CACHE BOOL "" FORCE)
    set(CHIAKI_ENABLE_PI_DECODER OFF CACHE BOOL "" FORCE)
    set(CHIAKI_ENABLE_SETSU OFF CACHE BOOL "" FORCE)
    set(CHIAKI_ENABLE_GUI OFF CACHE BOOL "" FORCE)
    set(CHIAKI_ENABLE_CLI OFF CACHE BOOL "" FORCE)
    set(CHIAKI_ENABLE_TESTS OFF CACHE BOOL "" FORCE)

    # Force curl to build lib-only, no tool/examples/tests
    set(CHIAKI_USE_SYSTEM_CURL OFF CACHE BOOL "" FORCE)
    set(BUILD_CURL_EXE OFF CACHE BOOL "" FORCE)
    set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
    set(CURL_DISABLE_TESTS ON CACHE BOOL "" FORCE)
    set(CURL_DISABLE_EXAMPLES ON CACHE BOOL "" FORCE)

    # Disable optional curl deps not needed on Android
    set(CURL_DISABLE_NGHTTP2 ON CACHE BOOL "" FORCE)
    set(CURL_DISABLE_LIBSSH2 ON CACHE BOOL "" FORCE)
    set(CURL_DISABLE_LIBPSL ON CACHE BOOL "" FORCE)
    set(CURL_DISABLE_LIBIDN2 ON CACHE BOOL "" FORCE)
    set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)

    # NOTE: Do NOT disable OpenSSL here — we want curl to use it.
endif()

option(CHIAKI_GUI_ENABLE_SDL_GAMECONTROLLER "Use SDL Gamecontroller for Input" ON)
option(CHIAKI_CLI_ARGP_STANDALONE "Search for standalone argp lib for CLI" OFF)
option(CHIAKI_ENABLE_STEAM_SHORTCUT "Add ability to create Steam shortcut" ON)
tri_option(CHIAKI_USE_SYSTEM_JERASURE "Use system-provided jerasure" AUTO)
tri_option(CHIAKI_USE_SYSTEM_NANOPB "Use system-provided nanopb" AUTO)
tri_option(CHIAKI_USE_SYSTEM_CURL "Use system-provided curl (must support WebSocket)" OFF)

# ---- Versioning ----
set(CHIAKI_VERSION_MAJOR 1)
set(CHIAKI_VERSION_MINOR 9)
set(CHIAKI_VERSION_PATCH 9)
set(CHIAKI_VERSION ${CHIAKI_VERSION_MAJOR}.${CHIAKI_VERSION_MINOR}.${CHIAKI_VERSION_PATCH})

# Packaging metadata
set(CPACK_PACKAGE_NAME "chiaki-ng")
set(CPACK_PACKAGE_DESCRIPTION "Open Source PlayStation Remote Play client")
set(CPACK_PACKAGE_VERSION_MAJOR ${CHIAKI_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${CHIAKI_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${CHIAKI_VERSION_PATCH})
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
set(CPACK_DEBIAN_PACKAGE_DESCRIPTION ${CPACK_PACKAGE_DESCRIPTION})
set(CPACK_DEBIAN_PACKAGE_SECTION "games")
include(CPack)

# ---- Platform-specific tweaks ----
set(CHIAKI_IS_SWITCH ${NSWITCH})

if(APPLE)
    if(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "arm64")
        set(CMAKE_OSX_DEPLOYMENT_TARGET 13.0 CACHE STRING "Minimum macOS deployment version" FORCE)
    else()
        set(CMAKE_OSX_DEPLOYMENT_TARGET 12.0 CACHE STRING "Minimum macOS deployment version" FORCE)
    endif()
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake;${CMAKE_CURRENT_SOURCE_DIR}/setsu/cmake")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake;${CMAKE_CURRENT_SOURCE_DIR}/steamdeck_native/cmake")
set(CMAKE_CXX_STANDARD 11)

if(CHIAKI_IS_SWITCH)
    set(CHIAKI_LIB_ENABLE_MBEDTLS ON)
    add_definitions(-D__SWITCH__)
endif()

# ---- Optional dependencies (desktop only) ----
if(CHIAKI_USE_SYSTEM_JERASURE)
    if(CHIAKI_USE_SYSTEM_JERASURE STREQUAL AUTO)
        find_package(Jerasure QUIET)
        set(CHIAKI_USE_SYSTEM_JERASURE ${Jerasure_FOUND})
    else()
        find_package(Jerasure REQUIRED)
        set(CHIAKI_USE_SYSTEM_JERASURE ON)
    endif()
endif()

if(CHIAKI_ENABLE_GUI)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(LIBPLACEBO REQUIRED libplacebo IMPORTED_TARGET)
endif()

if(CHIAKI_USE_SYSTEM_CURL)
    if (CHIAKI_USE_SYSTEM_CURL STREQUAL AUTO)
        find_package(CURL COMPONENTS HTTP HTTPS WS WSS QUIET)
        set(CHIAKI_USE_SYSTEM_CURL ${CURL_FOUND})
    else()
        find_package(CURL REQUIRED COMPONENTS HTTP HTTPS WS WSS)
        set(CHIAKI_USE_SYSTEM_CURL ON)
    endif()
endif()

if(CHIAKI_ENABLE_SPEEX)
    set(SpeexDSP_FOUND FALSE)
    find_package(SpeexDSP QUIET)
    pkg_check_modules(SpeexDSP speexdsp IMPORTED_TARGET)
    if(SpeexDSP_FOUND)
        set(CHIAKI_ENABLE_SPEEX ON)
        message(STATUS "Speex DSP enabled (echo cancelling, noise suppression)")
    else()
        set(CHIAKI_ENABLE_SPEEX OFF)
        message(STATUS "Speex DSP not found, disabled")
    endif()
endif()

find_package(PythonInterp 3 REQUIRED) # nanopb requires Python3

if(CHIAKI_USE_SYSTEM_NANOPB)
    if(CHIAKI_USE_SYSTEM_NANOPB STREQUAL AUTO)
        find_package(Nanopb QUIET)
        set(CHIAKI_USE_SYSTEM_NANOPB ${Nanopb_FOUND})
    else()
        find_package(Nanopb REQUIRED)
        set(CHIAKI_USE_SYSTEM_NANOPB ON)
    endif()
endif()

# ---- Subdirectories ----
add_subdirectory(third-party)

add_definitions(-DCHIAKI_VERSION_MAJOR=${CHIAKI_VERSION_MAJOR}
                -DCHIAKI_VERSION_MINOR=${CHIAKI_VERSION_MINOR}
                -DCHIAKI_VERSION_PATCH=${CHIAKI_VERSION_PATCH}
                -DCHIAKI_VERSION=\"${CHIAKI_VERSION}\")

if(CHIAKI_LIB_OPENSSL_EXTERNAL_PROJECT)
    include(OpenSSLExternalProject)
endif()

if(CHIAKI_LIB_ENABLE_MBEDTLS)
    add_definitions(-DCHIAKI_LIB_ENABLE_MBEDTLS)
    if(CHIAKI_LIB_MBEDTLS_EXTERNAL_PROJECT)
        set(FETCHCONTENT_QUIET CACHE BOOL FALSE)
        include(FetchContent)
        set(ENABLE_TESTING CACHE INTERNAL OFF)
        set(ENABLE_PROGRAMS CACHE INTERNAL OFF)
        set(USE_SHARED_MBEDTLS_LIBRARY CACHE INTERNAL OFF)
        FetchContent_Declare(
            mbedtls
            GIT_REPOSITORY https://github.com/Mbed-TLS/mbedtls.git
            GIT_TAG 8b3f26a5ac38d4fdccbc5c5366229f3e01dafcc0 # v2.28.0
            GIT_PROGRESS TRUE
        )
        FetchContent_MakeAvailable(mbedtls)
    endif()
endif()

# ---- Feature-specific subdirs (desktop only) ----
if(NOT CHIAKI_ENABLE_ANDROID)

    if(CHIAKI_ENABLE_STEAM_SHORTCUT)
        message(STATUS "Steam shortcut enabled")
    else()
        message(STATUS "Steam shortcut disabled")
    endif()

    if(CHIAKI_ENABLE_FFMPEG_DECODER)
        find_package(FFMPEG COMPONENTS avcodec avutil avformat)
        if(FFMPEG_FOUND)
            set(CHIAKI_ENABLE_FFMPEG_DECODER ON)
        else()
            if(NOT CHIAKI_ENABLE_FFMPEG_DECODER STREQUAL AUTO)
                message(FATAL_ERROR "CHIAKI_ENABLE_FFMPEG_DECODER is set to ON, but ffmpeg could not be found.")
            endif()
            set(CHIAKI_ENABLE_FFMPEG_DECODER OFF)
        endif()
    endif()

    if(CHIAKI_ENABLE_FFMPEG_DECODER)
        message(STATUS "FFMPEG Decoder enabled")
    else()
        message(STATUS "FFMPEG Decoder disabled")
    endif()

    if(CHIAKI_ENABLE_PI_DECODER)
        find_package(ILClient)
        if(ILClient_FOUND)
            set(CHIAKI_ENABLE_PI_DECODER ON)
        else()
            if(NOT CHIAKI_ENABLE_PI_DECODER STREQUAL AUTO)
                message(FATAL_ERROR "CHIAKI_ENABLE_PI_DECODER is set to ON, but its dependencies could not be resolved.")
            endif()
            set(CHIAKI_ENABLE_PI_DECODER OFF)
        endif()
    endif()

    if(CHIAKI_ENABLE_PI_DECODER)
        message(STATUS "Pi Decoder enabled")
    else()
        message(STATUS "Pi Decoder disabled")
    endif()

    if(CHIAKI_ENABLE_CLI)
        add_subdirectory(cli)
    endif()

    if(CHIAKI_ENABLE_STEAMDECK_NATIVE)
        find_package(HIDAPI QUIET)
        find_package(PkgConfig REQUIRED)
        pkg_search_module(FFTW REQUIRED fftw3 IMPORTED_TARGET)
        if(HIDAPI_FOUND AND FFTW_FOUND)
            set(CHIAKI_ENABLE_STEAMDECK_NATIVE ON)
        else()
            if(NOT CHIAKI_ENABLE_STEAMDECK_NATIVE STREQUAL AUTO)
                message(FATAL_ERROR "CHIAKI_ENABLE_STEAMDECK_NATIVE is set to ON, but dependencies could not be resolved.")
            endif()
            set(CHIAKI_ENABLE_STEAMDECK_NATIVE OFF)
        endif()
        if(CHIAKI_ENABLE_STEAMDECK_NATIVE)
            add_subdirectory(steamdeck_native)
        endif()
    endif()

    if(CHIAKI_ENABLE_STEAMDECK_NATIVE)
        message(STATUS "Steamdeck native gyro and haptics enabled")
    else()
        message(STATUS "Steamdeck native gyro and haptics disabled")
    endif()

    if(CHIAKI_ENABLE_GUI)
        find_package(SDL2 MODULE REQUIRED)
        add_subdirectory(gui)
    endif()

    if(CHIAKI_ENABLE_SETSU)
        # Setsu is Linux-only, requires udev/evdev
        find_package(Udev QUIET)
        find_package(Evdev QUIET)
        if(Udev_FOUND AND Evdev_FOUND)
            set(CHIAKI_ENABLE_SETSU ON)
            add_subdirectory(setsu)
        else()
            set(CHIAKI_ENABLE_SETSU OFF)
        endif()
    endif()

    if(CHIAKI_ENABLE_SETSU)
        message(STATUS "Setsu enabled")
    else()
        message(STATUS "Setsu disabled")
    endif()

    if(CHIAKI_ENABLE_TESTS)
        enable_testing()
        add_subdirectory(test)
    endif()

endif() # NOT CHIAKI_ENABLE_ANDROID

# ---- Android subdir ----
if(CHIAKI_ENABLE_ANDROID)
    add_subdirectory(android/app)
endif()

# ---- Borealis (Switch) ----
if(CHIAKI_ENABLE_BOREALIS)
    add_subdirectory(switch)
endif()
