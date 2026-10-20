# Evolution X flags for malmo (appended to lineage_malmo.mk by scripts/build.sh)

# Ship Google apps (Pixel experience). Set to false for a vanilla build.
WITH_GMS := true

# Official-looking build tag shown in Settings > About
EVO_BUILD_TYPE := Unofficial

# Pixel features
TARGET_SUPPORTS_QUICK_TAP := true
TARGET_ENABLE_FP_OVERRIDE := true

# Boot animation sized for the G85's 1080x2400 panel
TARGET_BOOT_ANIMATION_RES := 1080

# Maintainer shown in Evolution settings
EVO_MAINTAINER := ffgamerganesh61-beep
