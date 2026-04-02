#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

export CDS_DK_VERSION="${CDS_DK_VERSION:-"latest"}"
export INSTALL_CDS_DK="${INSTALL_CDS_DK:-"true"}"
export INSTALL_MBT="${INSTALL_MBT:-"true"}"
export INSTALL_CF_CLI="${INSTALL_CF_CLI:-"true"}"
export INSTALL_SQLITE3="${INSTALL_SQLITE3:-"true"}"
export INSTALL_UV="${INSTALL_UV:-"true"}"
export INSTALL_CDSMCP="${INSTALL_CDSMCP:-"true"}"

install_cf() {
    export CF_PLUGIN_HOME="/home/node"
    wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | gpg --dearmor -o /usr/share/keyrings/cli.cloudfoundry.org.gpg
    echo "deb [signed-by=/usr/share/keyrings/cli.cloudfoundry.org.gpg] https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list
    apt-get update -y
    echo "[cap-tools] Installing cf8-cli ..."
    apt-get install cf8-cli

    cf add-plugin-repo CF-Community https://plugins.cloudfoundry.org
    
    ARCH=$(uname -m)
    echo "[cap-tools] Starting installation of CF CLI plugins for architecture: $ARCH"
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        cf install-plugin -f https://github.com/cloudfoundry-incubator/multiapps-cli-plugin/releases/latest/download/multiapps-plugin.linuxarm64
        echo "[cap-tools] CF CLI multiapps plugin (ARM64) installation completed for architecture: $ARCH"
    else
    # Non-ARM64 -> install from CF-Community repo
        cf install-plugin -f -r CF-Community "multiapps"
        echo "[cap-tools] CF CLI multiapps plugin (Non-ARM64) installation completed for architecture: $ARCH"
    fi
    
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        cf install-plugin -f https://github.com/SAP/cf-html5-apps-repo-cli-plugin/releases/latest/download/cf-html5-apps-repo-cli-plugin-linux-arm64
        echo "[cap-tools] CF CLI html5 plugin (ARM64) installation completed for architecture: $ARCH"
    else
    # Non-ARM64 -> install from CF-Community repo
        cf install-plugin -f -r CF-Community "html5-plugin"
        echo "[cap-tools] CF CLI html5 plugin (Non-ARM64) installation completed for architecture: $ARCH"
    fi
    chown -R node:node /home/node/.cf
}

apt-get update -y

if [ "$INSTALL_CDS_DK" = "true" ]; then
    echo "[cap-tools] Installing @sap/cds-dk version ${CDS_DK_VERSION} ..."
    npm install -g @sap/cds-dk@${CDS_DK_VERSION}
fi

if [ "$INSTALL_MBT" = "true" ]; then
    echo "[cap-tools] Installing mbt ..."
    npm install -g mbt
fi

if [ "$INSTALL_SQLITE3" = "true" ]; then
    echo "[cap-tools] Installing sqlite3 ..."
    apt-get -y install --no-install-recommends pkg-config libsqlite3-dev sqlite3
fi

if [ "$INSTALL_CF_CLI" = "true" ]; then
    echo "[cap-tools] Installing Cloud Foundry CLI ..."
    install_cf
fi

if [ "$INSTALL_UV" = "true" ]; then
    echo "[cap-tools] Installing uv, uvx ..."
    curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh
fi

if [ "$INSTALL_CDSMCP" = "true" ]; then
    echo "[cap-tools] Installing cds-mcp server ..."
    npm i -g @cap-js/mcp-server
    #cds-mcp requires write access to the npm-global folder
    chown -R node:node /usr/local/share/npm-global/lib/node_modules/@cap-js/mcp-server/
    #add @cap-js/mcp-server and @ui5/mcp-server configurati 
    echo "[cap-tools] Seeding cds-mcp VS Code config ..."
    install -d "/home/node/.vscode-server/data/User"
    cp "$SCRIPT_DIR/mcp.json" "/home/node/.vscode-server/data/User/mcp.json"
    chown -R node:node "/home/node/.vscode-server"
fi