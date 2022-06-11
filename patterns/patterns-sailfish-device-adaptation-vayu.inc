# Feel free to disable non-critical HA parts during devel by commenting lines out
# Generated in hadk by executing: rpm/dhd/helpers/add_new_device.sh

%package -n patterns-sailfish-device-adaptation-vayu
Summary: Jolla HW Adaptation vayu
Requires: droid-hal-vayu
Requires: droid-hal-vayu-img-boot
Requires: droid-hal-vayu-kernel-modules
Requires: droid-config-vayu-sailfish
Requires: droid-config-vayu-pulseaudio-settings
Requires: droid-config-vayu-policy-settings
Requires: droid-config-vayu-preinit-plugin
Requires: droid-config-vayu-flashing
Requires: droid-config-vayu-bluez5
Requires: droid-hal-version-vayu

# Hybris packages
Requires: libhybris-libEGL
Requires: libhybris-libGLESv2
Requires: libhybris-libwayland-egl

# Bluetooth
Requires: bluebinder

# Telephony
Requires: ofono-binder-plugin
Requires: dummy_netd
Requires: modem_auto_config
Requires: ofono-vendor-qti-radio-plugin

# Sensors
Requires: hybris-libsensorfw-qt5

# Vibra
Requires: ngfd-plugin-native-vibrator
Requires: libngf-qt5-qtfeedback
Requires: ngfd >= 1.4.0

# Needed for /dev/touchscreen symlink
Requires: qt5-plugin-generic-evdev

Requires: pulseaudio-modules-droid
Requires: pulseaudio-modules-droid-hidl

# The -dummy-af is needed for newer devices that run the main
# audiosystem-passthrough in qti mode (e.g. >=Android 9 Qualcomm),
# to fix non-responding Camera app and/or voice during a phone call:
Requires: audiosystem-passthrough-dummy-af

# for audio recording to work:
Requires: qt5-qtmultimedia-plugin-mediaservice-gstmediacapture

# These need to be per-device due to differing backends (fbdev, eglfs, hwc, ..?)
Requires: qt5-qtwayland-wayland_egl
Requires: qt5-qpa-hwcomposer-plugin
Requires: qtscenegraph-adaptation

# For hybris devices with droidmedia, see HADK pdf for more information
Requires: gstreamer1.0-droid
Requires: gmp-droid

# This is needed for notification LEDs
Requires: mce-plugin-libhybris

# USB mode controller
Requires: usb-moded

# hammerhead, grouper, and maguro use this in scripts, so include for all
Requires: rfkill

#Add FP support
Requires: sailfish-fpd-community
Requires: sailfish-devicelock-fpd
Requires: droid-fake-crypt

# Enable home encryption
#Requires: sailfish-device-encryption

# For GPS
Requires: geoclue-provider-hybris

# For FM radio on some QCOM devices
#Requires: qt5-qtmultimedia-plugin-mediaservice-irisradio
#Requires: jolla-mediaplayer-radio

# NFC support
Requires: nfcd-binder-plugin
Requires: jolla-settings-system-nfc

# For torch
Requires: jolla-settings-system-flashlight

# For suspend to work with enabled Wi-Fi on newer Qualcomm devices
Requires: sailfish-connman-plugin-suspend

%description -n patterns-sailfish-device-adaptation-vayu
Pattern with packages for vayu HW Adaptation

%files -n patterns-sailfish-device-adaptation-vayu
