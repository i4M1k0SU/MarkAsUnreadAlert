ARCHS = armv7 armv7s arm64
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MarkasUnreadAlert
MarkasUnreadAlert_FILES = Tweak.xm
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
BUNDLE_NAME = MarkasUnreadAlertBundle
#スペースの処理わからん
#MarkasUnreadAlertBundle_INSTALL_PATH = '"/Library/Application Support/MarkasUnreadAlert"'
include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += markasunreadalertpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support/MarkasUnreadAlert$(ECHO_END)
	$(ECHO_NOTHING)cp -r Resources $(THEOS_STAGING_DIR)/Library/Application\ Support/MarkasUnreadAlert/$(BUNDLE_NAME).bundle$(ECHO_END)

before-stage::
	find . -name ".DS_STORE" -delete

after-install::
	install.exec "killall -9 SpringBoard"
