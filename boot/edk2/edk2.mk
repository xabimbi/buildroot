################################################################################
#
# edk2
#
################################################################################

EDK2_VERSION = edk2-stable202011
EDK2_SITE = https://github.com/tianocore/edk2
EDK2_SITE_METHOD = git
EDK2_LICENSE = BSD-2-Clause
EDK2_LICENSE_FILE = License.txt
EDK2_DEPENDENCIES = host-python3 host-acpica

# The EDK2 build system is rather special, so we're resorting to using its
# own Git submodules in order to include certain build dependencies.
EDK2_GIT_SUBMODULES = YES

EDK2_INSTALL_IMAGES = YES

ifeq ($(BR2_x86_64),y)
EDK2_ARCH = X64
else ifeq ($(BR2_aarch64),y)
EDK2_ARCH = AARCH64
endif

ifeq ($(BR2_TARGET_EDK2_DEBUG),y)
EDK2_BUILD_TYPE = DEBUG
else
EDK2_BUILD_TYPE = RELEASE
endif

# Packages path.
#
# The EDK2 build system will, for some platforms, depend on binary outputs
# from other bootloader packages. Those dependencies need to be in the path
# for the EDK2 build system, so we define this special directory here.
EDK2_OUTPUT_BASE = $(BINARIES_DIR)/edk2

ifeq ($(BR2_PACKAGE_HOST_EDK2_PLATFORMS),y)
EDK2_PACKAGES_PATH = $(@D):$(EDK2_OUTPUT_BASE):$(HOST_DIR)/share/edk2-platforms
else
EDK2_PACKAGES_PATH = $(@D):$(EDK2_OUTPUT_BASE)
endif

# Platform configuration.
#
# We set the variable EDK_EL2_NAME for platforms that may load EDK2 as part of
# the EL2 processor context, like ARM Trusted Firmware (ATF). This way, other
# bootloaders know what binary to include in their firmware package.
#
# However, the QEMU SBSA platform is a bit unique as there are different
# implicit assumptions on how this firmware should be packaged and run.
# The EDK2 build system itself will package the ATF binaries.

ifeq ($(BR2_TARGET_EDK2_PLATFORM_OVMF_X64),y)
EDK2_DEPENDENCIES += host-nasm
EDK2_PACKAGE_NAME = OvmfPkg
EDK2_PLATFORM_NAME = OvmfPkgX64
EDK2_BUILD_DIR = OvmfX64

else ifeq ($(BR2_TARGET_EDK2_PLATFORM_ARM_VIRT_QEMU),y)
EDK2_PACKAGE_NAME = ArmVirtPkg
EDK2_PLATFORM_NAME = ArmVirtQemu
EDK2_BUILD_DIR = $(EDK2_PLATFORM_NAME)-$(EDK2_ARCH)

else ifeq ($(BR2_TARGET_EDK2_PLATFORM_ARM_VIRT_QEMU_KERNEL),y)
EDK2_PACKAGE_NAME = ArmVirtPkg
EDK2_PLATFORM_NAME = ArmVirtQemuKernel
EDK2_BUILD_DIR = $(EDK2_PLATFORM_NAME)-$(EDK2_ARCH)
EDK2_EL2_NAME = QEMU_EFI

else ifeq ($(BR2_TARGET_EDK2_PLATFORM_ARM_VEXPRESS_FVP_AARCH64),y)
EDK2_DEPENDENCIES += host-edk2-platforms
EDK2_PACKAGE_NAME = Platform/ARM/VExpressPkg
EDK2_PLATFORM_NAME = ArmVExpress-FVP-AArch64
EDK2_BUILD_DIR = $(EDK2_PLATFORM_NAME)
EDK2_EL2_NAME = FVP_AARCH64_EFI

else ifeq ($(BR2_TARGET_EDK2_PLATFORM_QEMU_SBSA),y)
EDK2_DEPENDENCIES += host-edk2-platforms arm-trusted-firmware
EDK2_PACKAGE_NAME = Platform/Qemu/SbsaQemu
EDK2_PLATFORM_NAME = SbsaQemu
EDK2_BUILD_DIR = $(EDK2_PLATFORM_NAME)
EDK2_PRE_CONFIGURE_HOOKS += EDK2_OUTPUT_QEMU_SBSA
endif

# For QEMU SBSA we use EDK2_OUTPUT_BASE (which is already in the EDK2 path) to
# build the package structure that EDK2 expects for this specific platform.
define EDK2_OUTPUT_QEMU_SBSA
	mkdir -p $(EDK2_OUTPUT_BASE)/Platform/Qemu/Sbsa
	ln -srf $(BINARIES_DIR)/{bl1.bin,fip.bin} $(EDK2_OUTPUT_BASE)/Platform/Qemu/Sbsa/
endef

# Build commands.
#
# Due to the uniquely scripted build system for EDK2 we need to export all
# build environment variables so that they are available across edksetup.sh,
# make, the build command, and other subordinate build scripts within EDK2.

EDK2_BUILD_ENV += \
WORKSPACE=$(@D) \
PACKAGES_PATH=$(EDK2_PACKAGES_PATH) \
PYTHON_COMMAND=$(HOST_DIR)/bin/python3 \
IASL_PREFIX=$(HOST_DIR)/bin/ \
NASM_PREFIX=$(HOST_DIR)/bin/ \
GCC5_$(EDK2_ARCH)_PREFIX=$(TARGET_CROSS)

EDK2_BUILD_OPTS += -a $(EDK2_ARCH) -t GCC5 -b $(EDK2_BUILD_TYPE) -p $(EDK2_PACKAGE_NAME)/$(EDK2_PLATFORM_NAME).dsc
EDK2_BUILD_TARGETS += all

define EDK2_BUILD_CMDS
	mkdir -p $(EDK2_OUTPUT_BASE)
	export $(EDK2_BUILD_ENV) && \
	source $(@D)/edksetup.sh && \
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/BaseTools && \
	build $(EDK2_BUILD_OPTS) $(EDK2_BUILD_TARGETS)
endef

define EDK2_INSTALL_IMAGES_CMDS
	cp -f $(@D)/Build/$(EDK2_BUILD_DIR)/$(EDK2_BUILD_TYPE)_GCC5/FV/*.fd $(BINARIES_DIR)
endef

$(eval $(generic-package))
