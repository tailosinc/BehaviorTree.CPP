from conan import ConanFile
from conan.tools.cmake import CMake

class BehaviortreeCppRecipe(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "cmake_find_package", "cmake_paths", "cmake"

    def requirements(self):
#       self.requires("ncurses/6.3") #  broken on conan 2.0
        self.requires("gtest/1.12.1")
        self.requires("zeromq/4.3.4")
        self.requires("sqlite3/3.40.1")

    def build_requirements(self):
        self.tool_requires("cmake/3.16.3")

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
