################################################################################
#
# rpi-vc-log
#
################################################################################

RPI_VC_LOG_VERSION = 933641a986dc53030b24150b742c88be9048b229
RPI_VC_LOG_SITE = $(call github,paralin,rpi-vc-log,$(RPI_VC_LOG_VERSION))

RPI_VC_LOG_MAKE_OPTS = \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)"

define RPI_VC_LOG_BUILD_CMDS
	$(MAKE) -C $(@D) $(RPI_VC_LOG_MAKE_OPTS) vc-log
endef

$(eval $(generic-package))
