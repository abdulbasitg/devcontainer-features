#!/bin/sh
set -e

export CDS_DK_VERSION="${CDS_DK_VERSION:-"latest"}"
export INSTALL_CDS_DK="${INSTALL_CDS_DK:-"true"}"
export INSTALL_MBT="${INSTALL_MBT:-"true"}"
export INSTALL_CF_CLI="${INSTALL_CF_CLI:-"true"}"
export INSTALL_SQLITE3="${INSTALL_SQLITE3:-"true"}"
export INSTALL_CDSMCP="${INSTALL_CDSMCP:-"true"}"

install_cf() {
    wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | gpg --dearmor -o /usr/share/keyrings/cli.cloudfoundry.org.gpg
    echo "deb [signed-by=/usr/share/keyrings/cli.cloudfoundry.org.gpg] https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list
    apt-get update -y
    echo "Installing cf8-cli ..."
    apt-get install cf8-cli

    cf add-plugin-repo CF-Community https://plugins.cloudfoundry.org
    # Install the multiapps plugin; prefer the prebuilt ARM64 release when on arm64
    ARCH=$(uname -m)
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        TMP_BIN=/tmp/multiapps-plugin-non-static.linuxarm64
        echo "Downloading multiapps plugin for $ARCH to $TMP_BIN"
        curl -fsSL -o "$TMP_BIN" \
            "https://github.com/cloudfoundry/multiapps-cli-plugin/releases/latest/download/multiapps-plugin-non-static.linuxarm64"
        if [ -s "$TMP_BIN" ]; then
            chmod +x "$TMP_BIN"
            cf install-plugin "$TMP_BIN" -f || cf install-plugin -r CF-Community "multiapps"
            rm -f "$TMP_BIN"
        else
            echo "ARM64 binary download failed or empty; falling back to repo install"
            cf install-plugin -r CF-Community "multiapps"
        fi
    else
        # Non-ARM64 -> install from CF-Community repo
        cf install-plugin -f -r CF-Community "multiapps"
    fi

    # Install the html5-plugin; prefer the prebuilt ARM64 release when on arm64
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        HTML_BIN=/tmp/html5-plugin.linuxarm64
        echo "Attempting to download html5-plugin for $ARCH to $HTML_BIN"
            # Download the official SAP cf-html5-apps-repo CLI plugin (ARM64)
            HTML_BIN=/tmp/cf-html5-apps-repo-cli-plugin-linux-arm64
            echo "Downloading html5-plugin for $ARCH to $HTML_BIN"
            curl -fsSL -o "$HTML_BIN" \
                "https://github.com/SAP/cf-html5-apps-repo-cli-plugin/releases/latest/download/cf-html5-apps-repo-cli-plugin-linux-arm64" || true
        if [ -s "$HTML_BIN" ]; then
            chmod +x "$HTML_BIN"
            cf install-plugin "$HTML_BIN" -f || cf install-plugin -r CF-Community "html5-plugin"
            rm -f "$HTML_BIN"
        else
            echo "html5-plugin ARM64 download failed or empty; falling back to repo install"
            cf install-plugin -r CF-Community "html5-plugin"
        fi
    else
        cf install-plugin -f -r CF-Community "html5-plugin"
    fi
}

apt-get update -y

if [ "$INSTALL_CDSMCP" = "true" ]; then
    echo "Installing cds-mcp server ..."
    npm i -g @cap-js/mcp-server
fi

if [ "$INSTALL_CDS_DK" = "true" ]; then
    echo "Installing @sap/cds-dk version ${CDS_DK_VERSION} ..."
    npm install -g @sap/cds-dk@${CDS_DK_VERSION}
fi

if [ "$INSTALL_MBT" = "true" ]; then
    echo "Installing mbt ..."
    npm install -g mbt
fi

if [ "$INSTALL_SQLITE3" = "true" ]; then
    echo "Installing sqlite3 ..."
    apt-get -y install --no-install-recommends pkg-config libsqlite3-dev sqlite3
fi

if [ "$INSTALL_CF_CLI" = "true" ]; then
    echo "Installing Cloud Foundry CLI ..."
    install_cf

fi