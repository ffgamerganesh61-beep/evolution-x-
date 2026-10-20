# Evolution X for Moto G85 5G (malmo)

Custom ROM project: **Evolution X `bka` (Android 16, LineageOS 23.2 base)** with Pixel UI and **Material You Expressive**, built for the **Motorola Moto G85 5G (codename `malmo`)**.

> Status: **Experimental / first build.** The G85 has no official ROM support yet; this uses community device sources. Expect the first builds to need fixes before they boot.

## What's in this repo
| Path | What it does |
| --- | --- |
| `local_manifests/malmo.xml` | Pulls the malmo device tree, prebuilt kernel, vendor blobs, Motorola hardware and the sm6375-6.1 CAF HALs on top of Evolution X |
| `evolution/evolution_malmo.mk` | Evolution X feature flags (GApps, Pixel features, boot animation, maintainer) |
| `scripts/build.sh` | One-shot sync + build script (run on a build server) |

## Sources used
- ROM: [Evolution-X/manifest](https://github.com/Evolution-X/manifest) branch `bka`
- Device tree: [tmhakim/android_device_motorola_malmo](https://github.com/tmhakim/android_device_motorola_malmo) (`rebase4`)
- Kernel (prebuilt): [tmhakim-alt/kernel_prebuilt_motorola_malmo](https://github.com/tmhakim-alt/kernel_prebuilt_motorola_malmo)
- Vendor blobs: [blair-development/vendor_motorola_malmo](https://github.com/blair-development/vendor_motorola_malmo)
- CAF HALs (sm6375-6.1): [spring4ever](https://github.com/spring4ever)
- Motorola hardware: [LineageOS/android_hardware_motorola](https://github.com/LineageOS/android_hardware_motorola)

## Build without a PC (Crave, free for ROM devs)
1. Apply for free build access at https://foss.crave.io (sign in with GitHub).
2. On your phone, install **Termux** (from F-Droid), then install the Crave CLI and put your `crave.conf` from the Crave dashboard in Termux's home folder.
3. Start a build:
   ```bash
   crave run --no-patch -- "curl -fsSL https://raw.githubusercontent.com/ffgamerganesh61-beep/evolution-x-/main/scripts/build.sh | bash"
   ```
4. Download the zip from `out/target/product/malmo/` with `crave pull`.

## Flashing (at your own risk)
- Unlock the bootloader through Motorola's official unlock page (this wipes the phone).
- Back up everything first. Keep the stock firmware for your exact model (XT2427-x) to recover.
- Flash the ROM's recovery/boot images, then sideload the zip: `adb sideload EvolutionX-*.zip`.

## Known risks / TODO
- Vendor blobs come from a `lineage-22.2` tree; if they don't match the device tree, re-extract them from stock firmware with `device/motorola/malmo/extract-files.py`.
- `device/qcom/sepolicy_vndr` may need an sm6375-6.1 branch.
- Camera, VoLTE/IMS and fingerprint usually need tuning on first builds.

## Credits
Evolution X team, LineageOS, tmhakim, blair-development, spring4ever and the malmo community.
