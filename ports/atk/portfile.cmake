include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

set(ATK_VERSION 2.32.0)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/atk
    REF ATK_2_33_3
    SHA512 4dc29d2f795763b6be3c7b4038566f7603945f3e91b3c1791a4ad350ec484ad672c495836d5e6e9b9633c0c768a2ac1dd8793a3e381ce0e26364ef115a770c86
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --backend=ninja
)

vcpkg_install_meson()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/atk RENAME copyright)
