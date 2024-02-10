const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const flags = &.{};
    const lib = b.addSharedLibrary(.{
        .name = "ffi",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();

    const fficonfig = b.addConfigHeader(
        .{
            .style = .{ .autoconf = .{ .path = "fficonfig.h.in" } },
        },
        .{
            .AC_APPLE_UNIVERSAL_BUILD = null,
            .EH_FRAME_FLAGS = "a",
            .FFI_DEBUG = if (optimize == .Debug) "1" else null,
            .FFI_EXEC_STATIC_TRAMP = 1,
            .FFI_EXEC_TRAMPOLINE_TABLE = null,
            .FFI_MMAP_EXEC_EMUTRAMP_PAX = null,
            .FFI_MMAP_EXEC_WRIT = null,
            .FFI_NO_RAW_API = null,
            .FFI_NO_STRUCTS = null,
            .HAVE_ALLOCA_H = 1,
            .HAVE_AS_CFI_PSEUDO_OP = 1,
            .HAVE_AS_REGISTER_PSEUDO_OP = null,
            .HAVE_AS_S390_ZARCH = null,
            .HAVE_AS_SPARC_UA_PCREL = null,
            .HAVE_AS_X86_64_UNWIND_SECTION_TYPE = "1",
            .HAVE_AS_X86_PCREL = "1",
            .HAVE_DLFCN_H = "1",
            .HAVE_HIDDEN_VISIBILITY_ATTRIBUTE = "1",
            .HAVE_INTTYPES_H = "1",
            .HAVE_LONG_DOUBLE = "1",
            .HAVE_LONG_DOUBLE_VARIANT = null,
            .HAVE_MEMCPY = "1",
            .HAVE_MEMFD_CREATE = "1",
            .HAVE_PTRAUTH = null,
            .HAVE_RO_EH_FRAME = "1",
            .HAVE_STDINT_H = "1",
            .HAVE_STDIO_H = "1",
            .HAVE_STDLIB_H = "1",
            .HAVE_STRINGS_H = "1",
            .HAVE_STRING_H = "1",
            .HAVE_SYS_MEMFD_H = null,
            .HAVE_SYS_STAT_H = "1",
            .HAVE_SYS_TYPES_H = "1",
            .HAVE_UNISTD_H = "1",
            .LIBFFI_GNU_SYMBOL_VERSIONING = "1",
            .PACKAGE = "libffi",
            .PACKAGE_NAME = "libffi",
            .PACKAGE_STRING = "libffi 3.4.4",
            .PACKAGE_TARNAME = "libffi",
            .PACKAGE_URL = "",
            .PACKAGE_VERSION = "3.4.4",
            .PACKAGE_BUGREPORT = "http://github.com/libffi/libffi/issues",
            .SIZEOF_DOUBLE = target.result.c_type_byte_size(.double),
            .SIZEOF_LONG_DOUBLE = target.result.c_type_byte_size(.longdouble),
            .SIZEOF_SIZE_T = @divExact(target.result.ptrBitWidth(), 8),
            .STDC_HEADERS = 1,
            .VERSION = "3.4.4",
            .LT_OBJDIR = ".libs/",
            .SYMBOL_UNDERSCORE = null,
            .USING_PURIFY = null,
            .WORDS_BIGENDIAN = null,
        },
    );

    lib.addConfigHeader(fficonfig);
    lib.addIncludePath(.{ .path = "include/" });
    lib.addIncludePath(.{ .path = "src/x86/" });

    lib.addCSourceFiles(.{ .files = la_sources, .flags = flags });
    lib.addCSourceFiles(.{ .files = x86_sources, .flags = flags });
    inline for (x86_asm_sources) |asm_source| {
        lib.addAssemblyFile(.{ .path = asm_source });
    }

    b.installArtifact(lib);
}

const la_sources = &.{
    "src/prep_cif.c",
    "src/types.c",
    "src/raw_api.c",
    "src/java_raw_api.c",
    "src/closures.c",
    "src/tramp.c",
};

const x86_sources = &.{
    "src/x86/ffi.c",
    "src/x86/ffi64.c",
    "src/x86/ffiw64.c",
};

const x86_asm_sources = &.{
    "src/x86/sysv.S",
    "src/x86/sysv_intel.S",
    "src/x86/unix64.S",
    "src/x86/win64_intel.S",
    "src/x86/win64.S",
};
