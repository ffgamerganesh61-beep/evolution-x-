#!/usr/bin/env bash
# Runs automatically on the Google Cloud build VM (startup script). Builds the ROM, uploads it, powers off.
set -uo pipefail
MARK=/var/lib/evox-started
[ -f "$MARK" ] && exit 0          # only run once, not on every boot
touch "$MARK"
LOG=/var/log/evox-build.log
exec > >(tee -a "$LOG") 2>&1
echo "=== Evolution X malmo build started $(date -u) ==="

BUCKET=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/bucket)
REPO_RAW=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/repo_raw)
VARIANT=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/variant || echo userdebug)

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y git-core git-lfs gnupg flex bison build-essential zip unzip curl zlib1g-dev \
  libc6-dev-i386 x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc \
  fontconfig python3 python-is-python3 rsync bc lz4 ccache libssl-dev libncurses5 tmux
curl -s https://storage.googleapis.com/git-repo-downloads/repo -o /usr/local/bin/repo && chmod a+x /usr/local/bin/repo

# extra swap so the 64 GB VM survives the link steps
fallocate -l 32G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile

useradd -m builder || true
sudo -u builder git config --global user.name "evox-builder"
sudo -u builder git config --global user.email "builder@localhost"
sudo -u builder git config --global color.ui false
mkdir -p /src && chown builder /src

if sudo -u builder -H bash -c "cd /src && export BUILD_VARIANT=$VARIANT USE_CCACHE=1 && curl -fsSL $REPO_RAW/scripts/build.sh | bash"; then
  ZIP=$(ls /src/out/target/product/malmo/EvolutionX-*.zip | head -1)
  gsutil cp "$ZIP" /src/out/target/product/malmo/{boot,vendor_boot,dtbo,vbmeta,recovery}.img "gs://$BUCKET/" 2>/dev/null || gsutil cp "$ZIP" "gs://$BUCKET/"
  echo "=== BUILD OK: $ZIP uploaded to gs://$BUCKET ==="
else
  echo "=== BUILD FAILED ==="
  [ -f /src/out/error.log ] && gsutil cp /src/out/error.log "gs://$BUCKET/error.log"
fi
gsutil cp "$LOG" "gs://$BUCKET/build.log"
echo "Powering off to save credit."
poweroff
