cmake_minimum_required(VERSION 3.16)
project(yoe-kiosk-browser LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick WebView)

qt_add_executable(yoe-kiosk-browser
    main.cpp
)

target_link_libraries(yoe-kiosk-browser PUBLIC
    Qt::Core
    Qt::Gui
    Qt::Qml
    Qt::Quick
    Qt::WebView
)

# Resources:
set(qml_resource_files
    "main.qml"
)

qt6_add_resources(yoe-kiosk-browser "qml"
    PREFIX
        "/"
    BASE
        "images"
    FILES
        ${qml_resource_files}
)

install(TARGETS yoe-kiosk-browser
    RUNTIME DESTINATION bin
)
