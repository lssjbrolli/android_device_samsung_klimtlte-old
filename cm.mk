# Boot animation
TARGET_SCREEN_HEIGHT := 2560
TARGET_SCREEN_WIDTH := 1600

$(call inherit-product, device/samsung/klimtlte/full_klimtlte.mk)

## Specify phone tech before including full_phone
#$(call inherit-product, vendor/cm/config/gsm.mk)

# Inherit some common CM stuff.
$(call inherit-product, vendor/cm/config/common_full_tablet_wifionly.mk)

PRODUCT_NAME := cm_klimtlte
PRODUCT_DEVICE := klimtlte
PRODUCT_RELEASE_NAME := Galaxy Tab S 8.4 LTE
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-T705
PRODUCT_MANUFACTURER := samsung

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_MODEL=SM-T705 \
    PRODUCT_NAME=klimtlte \
    PRODUCT_DEVICE=klimtlte \
    TARGET_DEVICE=klimtlte \
