include(vcpkg_common_functions)

# Glib uses winapi functions not available in WindowsStore
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are currently not supported.")
endif()

# Glib relies on DllMain on Windows
if (NOT VCPKG_CMAKE_SYSTEM_NAME)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)
endif()

set(GLIB_VERSION 2.60.4)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/glib
    REF ${GLIB_VERSION}
    SHA512 433d9e476fdf5db8cb3a8740227e91da4b9d23bfe233e18df983a5089a77e810b1458e2d7e2cba4a4f5b2b6ec7ccd56fde1660b024268b66f03f67d6e1edf3ed
    HEAD_REF glib-2-60
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --backend=ninja
)

vcpkg_install_meson()
vcpkg_copy_pdbs()

# Move executables from bin to tools/glib
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/glib)

set(BINTOOLS
    gdbus
    gio
    gio-querymodules
    glib-compile-resources
    glib-compile-schemas
    gobject-query
    gresource
    gsettings
    gspawn-win64-helper
    gspawn-win64-helper-console
)
foreach(bintool ${BINTOOLS})
    if(CMAKE_HOST_WIN32)
        file(RENAME ${CURRENT_PACKAGES_DIR}/bin/${bintool}.exe ${CURRENT_PACKAGES_DIR}/tools/glib/${bintool}.exe)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/${bintool}.pdb)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/${bintool}.exe)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/${bintool}.pdb)
    else()
        file(RENAME ${CURRENT_PACKAGES_DIR}/bin/${bintool} ${CURRENT_PACKAGES_DIR}/tools/glib/${bintool})
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/${bintool})
    endif()
endforeach()

set(PYTOOLS
    gdbus-codegen
    glib-genmarshal
    glib-mkenums
    gtester-report
)
foreach(pytool ${PYTOOLS})
    if(CMAKE_HOST_WIN32)
        set(pytool ${pytool}.py)
    endif()

    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/${pytool} ${CURRENT_PACKAGES_DIR}/tools/glib/${pytool})
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/${pytool})
endforeach()

# Move include files one level higher up as customary for vcpkg installation
file(COPY ${CURRENT_PACKAGES_DIR}/include/glib-2.0/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/glib-2.0)
if(CMAKE_HOST_WIN32)
    file(COPY ${CURRENT_PACKAGES_DIR}/include/gio-win32-2.0/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/gio-win32-2.0)
else()
    file(COPY ${CURRENT_PACKAGES_DIR}/include/gio-unix-2.0/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/gio-unix-2.0)
endif()
file(COPY ${CURRENT_PACKAGES_DIR}/lib/glib-2.0/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/glib-2.0)

# Remove bin directory
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Remove debug/share directory
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/glib RENAME copyright)
