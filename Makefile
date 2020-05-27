TARGET = iphone:13.0:13.0
ARCHS = arm64 arm64e

FINALPACKAGE = 1

DEBUG = 0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PMreally
PMreally_FILES = PMreally.xm
PMreally_CFLAGS = -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileTimer"
