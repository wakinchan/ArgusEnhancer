ARCHS = armv7 armv7s arm64
THEOS_DEVICE_IP = 192.168.1.109
TARGET = iphone:clang::7.0
GO_EASY_ON_ME=1

include /opt/theos/makefiles/common.mk

TWEAK_NAME = ArgusEnhancer
ArgusEnhancer_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = ArgusEnhancerSettings
ArgusEnhancerSettings_FILES = Preference.m
ArgusEnhancerSettings_INSTALL_PATH = /Library/PreferenceBundles
ArgusEnhancerSettings_FRAMEWORKS = UIKit Accounts Social
ArgusEnhancerSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ArgusEnhancer.plist$(ECHO_END)
