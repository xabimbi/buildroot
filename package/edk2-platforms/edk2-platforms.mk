################################################################################
#
# edk2-platforms
#
################################################################################

EDK2_PLATFORMS_VERSION = 608d71ec939692eace78e6b4b2a44ea7b6e75927
EDK2_PLATFORMS_SITE = $(call github,tianocore,edk2-platforms,$(EDK2_PLATFORMS_VERSION))
EDK2_PLATFORMS_LICENSE = BSD-2-Clause
EDK2_PLATFORMS_LICENSE_FILE = License.txt

# There is nothing to build for edk2-platforms. All we need to do is to copy
# all description files to the host directory for other packages to build with.
define HOST_EDK2_PLATFORMS_INSTALL_CMDS
	cp -rf $(@D) $(HOST_DIR)/share/edk2-platforms
endef

$(eval $(host-generic-package))
