cmake_minimum_required(VERSION 3.21)
project(izshell-plugin LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Gui Qml DBus Network)
find_package(PkgConfig REQUIRED)
pkg_check_modules(WAYLAND REQUIRED IMPORTED_TARGET wayland-client)
pkg_get_variable(WAYLAND_PROTOCOLS wayland-protocols pkgdatadir)
find_program(WAYLAND_SCANNER wayland-scanner REQUIRED)

qt_standard_project_setup(REQUIRES 6.5)
set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml)

# client bindings for the data-control protocol the clipboard speaks
set(protocol ${WAYLAND_PROTOCOLS}/staging/ext-data-control/ext-data-control-v1.xml)
add_custom_command(
  OUTPUT ext-data-control-v1-client.h ext-data-control-v1.c
  COMMAND ${WAYLAND_SCANNER} client-header ${protocol} ext-data-control-v1-client.h
  COMMAND ${WAYLAND_SCANNER} private-code ${protocol} ext-data-control-v1.c
  DEPENDS ${protocol}
)

qt_add_qml_module(izshell
  URI Izshell
  VERSION 1.0
  PLUGIN_TARGET izshell
  SOURCES
    clipboard.cpp clipboard.hpp
    dbus.cpp dbus.hpp
    files.cpp files.hpp
    hyprctl.cpp hyprctl.hpp
    ${CMAKE_CURRENT_BINARY_DIR}/ext-data-control-v1.c
    ${CMAKE_CURRENT_BINARY_DIR}/ext-data-control-v1-client.h
)
target_include_directories(izshell PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
target_link_libraries(izshell PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::DBus Qt6::Network PkgConfig::WAYLAND)

install(TARGETS izshell LIBRARY DESTINATION lib/qt-6/qml/Izshell)
install(FILES
  ${QT_QML_OUTPUT_DIRECTORY}/Izshell/qmldir
  ${QT_QML_OUTPUT_DIRECTORY}/Izshell/izshell.qmltypes
  DESTINATION lib/qt-6/qml/Izshell)
