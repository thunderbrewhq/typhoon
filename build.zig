const std = @import("std");
const system = @import("system");

pub fn build(b: *std.Build) void {
  const target = b.standardTargetOptions(.{});
  const optimize = b.standardOptimizeOption(.{});

  // Typhoon library
  const tempest = b.addStaticLibrary(.{
    .name = "tempest",
    .target = target,
    .optimize = optimize
  });
  // Link C++ standard library
  tempest.linkLibCpp();
  // Add system detection defines
  system.add_defines(tempest);

  // Get dependencies
  const squall = b.dependency("squall", .{});
  // Link storm
  tempest.addIncludePath(squall.path("."));
  tempest.linkLibrary(squall.artifact("storm"));

  // Include Typhoon project directory
  tempest.addIncludePath(b.path("."));

  const tempest_compiler_flags = [_][]const u8 {
    "-std=c++11",
  };

  const tempest_sources = [_][]const u8 {
    "tempest/matrix/C44Matrix.cpp",

    "tempest/quaternion/C4Quaternion.cpp",

    "tempest/rect/CRect.cpp",

    "tempest/vector/C2Vector.cpp",
    "tempest/vector/C3Vector.cpp",
    "tempest/vector/CImVector.cpp"
  };

  tempest.addCSourceFiles(.{
    .files = &tempest_sources,
    .flags = &tempest_compiler_flags
  });

  // TempestTest executable
  const tempest_test_exe = b.addExecutable(.{
    .name = "TempestTest",
    .target = target,
    .optimize = optimize
  });
  // Link C++ standard library
  tempest_test_exe.linkLibCpp();
  // Add system detection defines
  system.add_defines(tempest_test_exe);

  tempest_test_exe.linkLibrary(tempest);
  tempest_test_exe.addIncludePath(squall.path("."));
  tempest_test_exe.addIncludePath(b.path("."));

  tempest_test_exe.addCSourceFiles(.{
    .files = &.{
      "test/Math.cpp",
      "test/Matrix.cpp",
      "test/Rect.cpp",
      "test/Test.cpp",
      "test/Vector.cpp"
    },

    .flags = &tempest_compiler_flags
  });

  b.installArtifact(tempest_test_exe);
  b.installArtifact(tempest);
}
