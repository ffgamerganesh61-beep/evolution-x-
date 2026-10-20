#!/usr/bin/env bash
# Builds Evolution X (Android 16, Material You Expressive) for Moto G85 5G (malmo).
# Run this on a Crave build server (see README) - it needs ~300 GB disk and 32+ GB RAM.
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/ffgamerganesh61-beep/evolution-x-/main"
BUILD_VARIANT="${BUILD_VARIANT:-userdebug}"

# 1. Source
repo init -u https://github.com/Evolution-X/manifest -b bka --git-lfs --depth=1
mkdir -p .repo/local_manifests
rm -f .repo/local_manifests/*.xml
curl -fsSL "$REPO_RAW/local_manifests/malmo.xml" -o .repo/local_manifests/malmo.xml

# Crave's resync helper if present, plain repo sync otherwise
if [ -x /opt/crave/resync.sh ]; then
  /opt/crave/resync.sh
else
  repo sync -c -j"$(nproc --all)" --force-sync --no-clone-bundle --no-tags
fi

# 2. Wire the sm6375-6.1 CAF tree into the build (same as LineageOS does for other SoCs)
ln -sf ../common/os_pickup_qssi.bp hardware/qcom-caf/sm6375-6.1/Android.bp || true

# 3. Add Evolution X flags to the device makefile (once)
if ! grep -q "Evolution X flags for malmo" device/motorola/malmo/lineage_malmo.mk; then
  curl -fsSL "$REPO_RAW/evolution/evolution_malmo.mk" >> device/motorola/malmo/lineage_malmo.mk
fi

# 4. Build
source build/envsetup.sh
lunch "lineage_malmo-bp4a-${BUILD_VARIANT}"
m evolution -j"$(nproc --all)"

echo "Done. Flashable zip:"
ls -1 out/target/product/malmo/EvolutionX-*.zip
