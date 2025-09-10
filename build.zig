const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sdl_dep = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(sdl_dep.artifact("SDL3"));

    const freetype_dep = b.dependency("freetype", .{
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(freetype_dep.artifact("freetype"));

    const sdl_ttf_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    sdl_ttf_mod.addCMacro("BUILD_SDL", "1");
    sdl_ttf_mod.addCMacro("DLL_EXPORT", "1");
    sdl_ttf_mod.addCMacro("SDL_BUILD_MAJOR_VERSION", "3");
    sdl_ttf_mod.addCMacro("SDL_BUILD_MICRO_VERSION", "2");
    sdl_ttf_mod.addCMacro("SDL_BUILD_MINOR_VERSION", "2");

    const sdl_ttf_lib = b.addLibrary(.{
        .name = "sdl_ttf",
        .root_module = sdl_ttf_mod,
    });

    sdl_ttf_lib.addCSourceFiles(.{
        .files = &.{
            "src/SDL_hashtable.c",
            "src/SDL_hashtable_ttf.c",
            "src/SDL_gpu_textengine.c",
            "src/SDL_renderer_textengine.c",
            "src/SDL_surface_textengine.c",
            "src/SDL_ttf.c",
        },
        .flags = &.{
            "-Wall",
            "-Wundef",
            "-Wfloat-conversion",
            "-fno-strict-aliasing",
            "-Wshadow",
            "-Wno-unused-local-typedefs",
            "-Wimplicit-fallthrough",
        },
    });

    sdl_ttf_lib.addIncludePath(b.path("include/"));
    sdl_ttf_lib.addSystemIncludePath(sdl_dep.path("include/"));
    sdl_ttf_lib.addSystemIncludePath(freetype_dep.path("include/"));

    sdl_ttf_lib.linkLibrary(sdl_dep.artifact("SDL3"));
    sdl_ttf_lib.linkLibrary(freetype_dep.artifact("freetype"));
    // sdl_ttf_lib.installHeadersDirectory(b.path("include/SDL3_ttf/"), "SDL3_ttf/", .{
    //     .exclude_extensions = &.{},
    // });
    sdl_ttf_lib.installHeader(b.path("include/SDL3_ttf/SDL_ttf.h"), "SDL3_ttf/SSDL_ttf.h");
    sdl_ttf_lib.installHeader(b.path("include/SDL3_ttf/SDL_textengine.h"), "SDL3_ttf/SDL_textengine.h");
    b.installArtifact(sdl_ttf_lib);
}
