# Cerebrum

> OpenWolf's learning memory. Updated automatically as the AI learns from interactions.
> Do not edit manually unless correcting an error.
> Last updated: 2026-05-11

## User Preferences

<!-- How the user likes things done. Code style, tools, patterns, communication. -->

## Key Learnings

- **Project:** durra-alaseel-user (Carbo - Flutter Car Rental App)
- **Android 16 KB Page Size Alignment:** Critical for Google Play Store compliance (Android 15+). Always include `android.mPageSize64K=true` in gradle.properties for new Flutter Android projects.
- **Firebase Dependency Versions:** Firebase Messaging 21.1.0 does NOT include 16 KB page size support. Must upgrade to 24.0.0+.
- **Google Services Gradle Plugin:** Version 4.3.8 is outdated. Always use 4.4.1+ for modern Android/Gradle compatibility.
- **ProGuard/R8 Configuration:** Must create proguard-rules.pro with explicit keep rules for Firebase, Pusher, ML Kit, and Google Play Services. Default R8 is insufficient.
- **Release buildType Configuration:** Must enable `minifyEnabled true` and `shrinkResources true` in release buildType for optimal APK size and 16 KB alignment support.
- **Kotlin Compilation Cache Errors:** Kotlin incremental compilation can fail when plugin sources are on different drives (e.g., C:\ vs L:\). These are non-fatal; build still succeeds. `flutter clean` resolves if needed.
- **NDK Version Pinning:** Don't explicitly pin NDK version in build.gradle unless a specific version is required. Let system default manage it to avoid version mismatches.
- **16 KB Bundle Verification:** A Gradle flag or dependency versions alone do not prove the release artifact is compliant. Inspect every arm64-v8a and x86_64 .so in the generated AAB and confirm every ELF LOAD segment has p_align >= 0x4000; production compliance still requires uploading the verified AAB and checking Play Console.

## Do-Not-Repeat

<!-- Mistakes made and corrected. Each entry prevents the same mistake recurring. -->
<!-- Format: [YYYY-MM-DD] Description of what went wrong and what to do instead. -->
- [2026-07-09] Do not forget `android.mPageSize64K=true` when fixing Google Play 16 KB page size warnings. This is the single most critical flag for modern Google Play compliance.
- [2026-07-09] Do not upgrade Pusher to 1.10.0 without testing push notifications thoroughly. Version 1.10.0 is stable, but breaking changes are possible—test booking confirmations, payment alerts, and user notifications after upgrade.
- [2026-07-09] Do not use explicit NDK version like `ndkVersion "27.0.12"` if it doesn't exist on the system. Let system default NDK handle it, or the build will fail. Instead, check NDK availability first or document the required NDK version in README.

## Decision Log

<!-- Significant technical decisions with rationale. Why X was chosen over Y. -->
- **[2026-07-09] Firebase Messaging 21.1.0 → 24.0.0 upgrade:** Chose upgrade over keeping old version because Firebase 24.0.0 includes critical 16 KB page size alignment fixes required by Google Play Store. The 3-version jump is conservative for Firebase (stable releases).
- **[2026-07-09] Google Services Plugin 4.3.8 → 4.4.1:** Chose minor version bump (not major) to avoid breaking changes while still gaining 16 KB page size support. 4.4.x is stable and production-ready.
- **[2026-07-09] Created proguard-rules.pro instead of using default R8:** Chose comprehensive custom rules because default R8 does not preserve Firebase, Pusher, and ML Kit internal APIs. Custom rules ensure no runtime crashes from obfuscation.
- **[2026-07-09] Conservative upgrade strategy:** Chose not to upgrade Kotlin, Gradle, or AGP versions because they were already stable (Kotlin 11, Gradle 8.11.1, AGP implied 8.3.x). Only upgraded dependencies directly tied to 16 KB compatibility issue.
