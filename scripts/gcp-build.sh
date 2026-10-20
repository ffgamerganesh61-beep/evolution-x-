#!/usr/bin/env bash
# Paste-and-run in Google Cloud Shell (works from a phone browser).
# Creates a 8 vCPU / 64 GB build VM in Mumbai, builds Evolution X for malmo, uploads the zip to a bucket, then shuts down.
set -euo pipefail
REPO_RAW="https://raw.githubusercontent.com/ffgamerganesh61-beep/evolution-x-/main"
ZONE="${ZONE:-asia-south1-a}"
VM="evox-builder"
PROJECT=$(gcloud config get-value project 2>/dev/null)
BUCKET="evox-malmo-${PROJECT}"

echo "Project: $PROJECT  Zone: $ZONE"
gcloud services enable compute.googleapis.com storage.googleapis.com
gsutil ls -b "gs://$BUCKET" >/dev/null 2>&1 || gsutil mb -l asia-south1 "gs://$BUCKET"
curl -fsSL "$REPO_RAW/scripts/vm-setup.sh" -o /tmp/vm-setup.sh

create() {
  gcloud compute instances create "$VM" --zone "$ZONE" \
    --machine-type e2-highmem-8 \
    --image-family ubuntu-2204-lts --image-project ubuntu-os-cloud \
    --boot-disk-size 400GB --boot-disk-type "$1" \
    --scopes storage-rw \
    --metadata bucket="$BUCKET",repo_raw="$REPO_RAW",variant="${BUILD_VARIANT:-userdebug}" \
    --metadata-from-file startup-script=/tmp/vm-setup.sh
}
create pd-balanced || { echo "SSD quota too low, retrying with a standard disk (slower)"; create pd-standard; }

cat <<MSG

Build started. It takes about 6-10 hours and the VM powers itself off when done.
Check progress:   gcloud compute ssh $VM --zone $ZONE -- tail -f /var/log/evox-build.log
Results:          https://console.cloud.google.com/storage/browser/$BUCKET
When finished, delete the VM so the disk stops using credit:
                  gcloud compute instances delete $VM --zone $ZONE --quiet
MSG
