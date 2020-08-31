################################################################################
#
# tailscale
#
################################################################################

TAILSCALE_VERSION = 1.0.3
TAILSCALE_SITE = $(call github,tailscale,tailscale,v$(TAILSCALE_VERSION))

TAILSCALE_LICENSE = BSD-3-Clause
TAILSCALE_LICENSE_FILES = LICENSE

TAILSCALE_DEPENDENCIES = host-pkgconf

TAILSCALE_LDFLAGS = -X version.LONG=$(TAILSCALE_VERSION)
TAILSCALE_TAGS = cgo

TAILSCALE_BUILD_TARGETS = \
	tailscale.com/cmd/tailscale \
	tailscale.com/cmd/tailscaled

TAILSCALE_INSTALL_BINS = $(notdir $(TAILSCALE_BUILD_TARGETS))

define TAILSCALE_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_TUN)
endef

$(eval $(golang-package))
