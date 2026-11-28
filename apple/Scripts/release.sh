#!/usr/bin/env bash
# Builds a release: GitWolf-<version>.zip (what the in-app updater downloads), GitWolf-<version>.dmg (first
# install), checksums, and an updated appcast.xml signed with your update key. Output: build/release/.
#
#   Scripts/release.sh 1.0.0
#
# Environment:
#   SIGN_IDENTITY     default "GitWolf Release", the self-signed certificate from Scripts/make-signing-cert.sh.
#                     A Developer ID Application identity (used for the published releases) works too.
#   NOTARY_PROFILE    optional: also notarise (needs a Developer ID; sets the hardened runtime). A profile made with
#                     `xcrun notarytool store-credentials <name>`. Published releases use it.
#   GITWOLF_UPDATE_KEY  private update-signing key; defaults to the one in your login Keychain
#   PREVIOUS_APPCAST  existing appcast.xml to add this release to (so earlier releases stay listed)
#   RELEASE_NOTES     file with this release's notes (Markdown/plain text), shown in the update window
#   DOWNLOAD_BASE     default https://github.com/ipuppyyt/GitWolf/releases/download
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${1:?usage: release.sh <version>, e.g. 1.0.0}"
export SIGN_IDENTITY="${SIGN_IDENTITY:-GitWolf Release}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
BASE="${DOWNLOAD_BASE:-https://github.com/ipuppyyt/GitWolf/releases/download}"

OUT="build/release"
rm -rf "$OUT"; mkdir -p "$OUT"

if [ -n "${NOTARY_PROFILE:-}" ]; then export HARDENED=1; fi
VERSION="$VERSION" Scripts/bundle.sh release

if [ -n "${NOTARY_PROFILE:-}" ]; then
  ditto -c -k --keepParent build/GitWolf.app "$OUT/GitWolf-notarize.zip"
  xcrun notarytool submit "$OUT/GitWolf-notarize.zip" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple build/GitWolf.app
  rm "$OUT/GitWolf-notarize.zip"
fi

# The archive the updater downloads. ditto keeps the bundle's symlinks and attributes intact.
ZIP="$OUT/GitWolf-$VERSION.zip"
ditto -c -k --sequesterRsrc --keepParent build/GitWolf.app "$ZIP"

# Disk image for the first install. Without notarisation it carries a note on opening an app Apple hasn't checked.
STAGE="$(mktemp -d)"
cp -R build/GitWolf.app "$STAGE/"
ln -s /Applications "$STAGE/Applications"
if [ -z "${NOTARY_PROFILE:-}" ]; then
cat > "$STAGE/Read Me First.txt" <<'TXT'
Drag GitWolf to Applications.

The first time you open it, macOS may say it can't verify the app (GitWolf is free and open source and
isn't notarised by Apple). To open it once:
  1. Try to open GitWolf, then click Done.
  2. Open System Settings > Privacy & Security, scroll down, and click "Open Anyway" next to GitWolf.
Or run this in Terminal:  xattr -dr com.apple.quarantine /Applications/GitWolf.app

You only do this once. Updates arrive inside the app and don't ask again.
TXT
fi
DMG="$OUT/GitWolf-$VERSION.dmg"
hdiutil create -volname "GitWolf" -srcfolder "$STAGE" -ov -format UDZO "$DMG"
rm -rf "$STAGE"
if [ -n "${NOTARY_PROFILE:-}" ]; then
  codesign --force --timestamp --sign "$SIGN_IDENTITY" "$DMG"
  xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple "$DMG"
fi

( cd "$OUT" && shasum -a 256 "GitWolf-$VERSION.zip" "GitWolf-$VERSION.dmg" > "GitWolf-$VERSION.sha256" )

# Sign the archive with the update key and add it to the feed.
ARGS=(appcast --version "$VERSION" --archive "$ZIP" --url "$BASE/v$VERSION/GitWolf-$VERSION.zip" --out "$OUT/appcast.xml")
[ -n "${PREVIOUS_APPCAST:-}" ] && [ -s "$PREVIOUS_APPCAST" ] && ARGS+=(--feed "$PREVIOUS_APPCAST")
[ -n "${RELEASE_NOTES:-}" ] && [ -s "$RELEASE_NOTES" ] && ARGS+=(--notes "$RELEASE_NOTES")
swift run -c release gitwolf-release "${ARGS[@]}"

echo "Done. Upload GitWolf-$VERSION.zip, .dmg and .sha256 to the GitHub release, and publish appcast.xml."
