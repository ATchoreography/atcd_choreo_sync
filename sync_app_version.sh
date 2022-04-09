#!/bin/bash

set -o pipefail
set -o errexit
set -o nounset

pubspec_version="$(grep '^version:' < pubspec.yaml | grep -o '[0-9]*\.[0-9]*\.[0-9]*+[0-9]*')"

version_name="${pubspec_version%+*}"
version_code="${pubspec_version#*+}"

echo "Setting version to $version_name+$version_code"

cat > lib/version.dart << EOF
const String versionName = "$version_name";
const int versionCode = $version_code;
EOF