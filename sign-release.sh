#!/bin/bash

PROJECT_NAME="terraform-provider-juice"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <release tag>"
    exit 1
fi

GIT_TAG=$1
if [[ "$GIT_TAG" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
    VERSION=${BASH_REMATCH[1]}
else
    echo "Invalid semantic version tag format: $GIT_TAG."
    exit 2
fi

CHECKSUM_FILE="${PROJECT_NAME}_${VERSION}_SHA256SUMS"

echo "Tag: $GIT_TAG, Version: $VERSION, Checksum file: ${CHECKSUM_FILE}"
mkdir -p dist

echo "Downloading checksum file from release..."
gh release download $GIT_TAG -D dist -p "${CHECKSUM_FILE}"
if [ "$?" -ne 0 ]; then
    echo "Download failed."
    exit 3
fi

echo "Signing the checksum file..."
gpg --local-user "${GPG_FINGERPRINT}" --output dist/${CHECKSUM_FILE}.sig --detach-sign dist/${CHECKSUM_FILE}
if [ "$?" -ne 0 ]; then
    echo "Signing failed."
    exit 4
fi

echo "Uploading checksum signature file to release..."
gh release upload $GIT_TAG dist/${CHECKSUM_FILE}.sig
if [ "$?" -ne 0 ]; then
    echo "Upload failed."
    exit 5
fi
