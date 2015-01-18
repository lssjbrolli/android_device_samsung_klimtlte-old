# # #
# Copyright (C) 2013 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_PATH := device/samsung/klimtlte

$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_small.mk)

PRODUCT_CHARACTERISTICS := tablet
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# Device uses high-density artwork where available
PRODUCT_AAPT_CONFIG := normal hdpi xhdpi xxhdpi
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

#insecure adbd
RODUCT_BUILD_PROP_OVERRIDES += \
    ro.secure=0 \
    ro.adb.secure=0
    
# CPU producer to CPU consumer not supported 
PRODUCT_PROPERTY_OVERRIDES += \
    ro.bq.gpu_to_cpu_unsupported=1

# Audio
PRODUCT_PACKAGES += \
    audio.primary.universal5420 \
    audio.a2dp.default \
    audio.usb.default \
    audio.r_submix.default \
    libtinyxml \
    mixer_paths.xml

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/audio_policy.conf:system/etc/audio_policy.conf \
    $(LOCAL_PATH)/configs/audio_effects.conf:system/etc/audio_effects.conf

# Boot animation
TARGET_SCREEN_HEIGHT := 2560
TARGET_SCREEN_WIDTH := 1600
PRODUCT_COPY_FILES += \
        vendor/cm/prebuilt/common/bootanimation/1600.zip:system/media/bootanimation.zip
    
# Camera
PRODUCT_PACKAGES += \
    camera.universal5420 \
    libexynoscamera \
    libhwjpeg
    
# Torch
PRODUCT_PACKAGES += \
    Torch

# Filesystem management tools
PRODUCT_PACKAGES += \
    make_ext4fs \
    e2fsck \
    setup_fs
    
# GPS    
$(call inherit-product, device/common/gps/gps_eu_supl.mk) 
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/gps.xml:system/etc/gps.xml
    
# Display
PRODUCT_PACKAGES += \
    libExynosHWCService \
    libfimg

# HW composer
PRODUCT_PACKAGES += \
    libion \
    hwcomposer.exynos5 \
    gralloc.exynos5

# IR
PRODUCT_PACKAGES += \
    consumerir.universal5420

# Keylayouts
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/sec_touchkey.kl:system/usr/keylayout/sec_touchkey.kl \
    $(LOCAL_PATH)/configs/gpio-keys.kl:system/usr/keylayout/gpio-keys.kl

# Keystore
PRODUCT_PACKAGES += \
    keystore.exynos5

# Media profile
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/media_codecs.xml:system/etc/media_codecs.xml \
    $(LOCAL_PATH)/configs/media_profiles.xml:system/etc/media_profiles.xml

# Misc
PRODUCT_PACKAGES += \
    com.android.future.usb.accessory

# MobiCore setup
PRODUCT_PACKAGES += \
    mcDriverDaemon

# Network tools
PRODUCT_PACKAGES += \
    libpcap \
    tcpdump

# OMX
PRODUCT_PACKAGES += \
    libcsc \
    libExynosOMX_Core \
    libOMX.Exynos.MP3.Decoder \
    libOMX.Exynos.AVC.Decoder \
    libOMX.Exynos.AVC.Encoder \
    libOMX.Exynos.MPEG4.Decoder \
    libOMX.Exynos.MPEG4.Encoder \
    libOMX.Exynos.VP8.Decoder \
    libOMX.Exynos.VP8.Encoder \
    libstagefrighthw
    
# System properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.opengles.version=131072 \
    wifi.interface=wlan0

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml \
    frameworks/native/data/etc/android.hardware.consumerir.xml:system/etc/permissions/android.hardware.consumerir.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:system/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:system/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.barometer.xml:system/etc/permissions/android.hardware.sensor.barometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:system/etc/permissions/android.hardware.sensor.stepdetector.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:system/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:system/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.software.sip.xml:system/etc/permissions/android.software.sip.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:system/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
    frameworks/native/data/etc/com.nxp.mifare.xml:system/etc/permissions/com.nxp.mifare.xml \
    frameworks/native/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml

# Ramdisk
PRODUCT_PACKAGES += \
    fstab.universal5420 \
    init.rc \
    init.universal5420.rc \
    init.universal5420.usb.rc \
    init.universal5420.wifi.rc \
    ueventd.universal5420.rc \
    cbd

# Radio (needed for audio controls even on wifi-only)
PRODUCT_PACKAGES += \
    libsecril-client \
    libsecril-client-sap \
    cbd
    
# Samsung
PRODUCT_PACKAGES += \
    SamsungServiceMode \
    libkeyutils \
    libexifa \
    libjpega 
 
# ProfessionalAudio
PRODUCT_PACKAGES += \
    libjackshm \
    libjackserver \
    libjack \
    androidshmservice \
    jackd \
    jack_dummy \
    jack_alsa \
    jack_goldfish \
    jack_opensles \
    jack_loopback \
    jack_connect \
    jack_disconnect \
    jack_lsp \
    jack_showtime \
    jack_simple_client \
    jack_transport \
    libasound \
    libglib-2.0 \
    libgthread-2.0 \
    libfluidsynth

# Recovery
PRODUCT_PACKAGES += \
    init.recovery.universal5420.rc

# Sensors
PRODUCT_PACKAGES += \
    sensors.universal5420

# Wifi
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/wpa_supplicant.conf:system/etc/wifi/wpa_supplicant.conf \
    $(LOCAL_PATH)/configs/wpa_supplicant_overlay.conf:system/etc/wifi/wpa_supplicant_overlay.conf \
    $(LOCAL_PATH)/configs/p2p_supplicant_overlay.conf:system/etc/wifi/p2p_supplicant_overlay.conf

PRODUCT_PACKAGES += \
    libnetcmdiface \
    macloader

# call dalvik heap config
$(call inherit-product-if-exists, frameworks/native/build/phone-xxhdpi-2048-dalvik-heap.mk)

# call hwui memory config
$(call inherit-product-if-exists, frameworks/native/build/phone-xxhdpi-2048-hwui-memory.mk)

# call the proprietary setup
$(call inherit-product-if-exists, vendor/samsung/klimtlte/klimtlte-vendor.mk)
