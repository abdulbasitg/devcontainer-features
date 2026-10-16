#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

export CDS_DK_VERSION="${CDS_DK_VERSION:-"latest"}"
export MBT_VERSION="${MBT_VERSION:-"latest"}"
export INSTALL_CDS_DK="${INSTALL_CDS_DK:-"true"}"
export INSTALL_MBT="${INSTALL_MBT:-"true"}"
export INSTALL_CF_CLI="${INSTALL_CF_CLI:-"true"}"
export CF_CLI_VERSION="${CF_CLI_VERSION:-"v8"}"
export INSTALL_SQLITE3="${INSTALL_SQLITE3:-"true"}"
export INSTALL_RIPGREP="${INSTALL_RIPGREP:-"true"}"
export INSTALL_JQ="${INSTALL_JQ:-"true"}"
export INSTALL_SHELLCHECK="${INSTALL_SHELLCHECK:-"false"}"
export INSTALL_PYTHON="${INSTALL_PYTHON:-"false"}"
export UV_VERSION="${UV_VERSION:-"latest"}"
export INSTALL_UV="${INSTALL_UV:-"true"}"
export CDSMCP_VERSION="${CDSMCP_VERSION:-"latest"}"
export INSTALL_CDSMCP="${INSTALL_CDSMCP:-"true"}"

install_cf() {
    export CF_PLUGIN_HOME="/home/node"
    echo "[cap-tools] Installing cf8-cli ..."
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64|arm64)
            CF_CLI_ARCH="linuxarm64"
            CF_CLI_RELEASE_ARCH="arm64"
            ;;
        x86_64|amd64)
            CF_CLI_ARCH="linux64"
            CF_CLI_RELEASE_ARCH="x86-64"
            ;;
        *) echo "Unsupported architecture for Cloud Foundry CLI: $ARCH" >&2; exit 1 ;;
    esac

    if [ "$CF_CLI_VERSION" = "v8" ]; then
        CF_CLI_URL="https://packages.cloudfoundry.org/stable?release=${CF_CLI_ARCH}-binary&version=v8&source=github"
    else
        CF_CLI_RELEASE_VERSION=${CF_CLI_VERSION#v}
        CF_CLI_URL="https://github.com/cloudfoundry/cli/releases/download/${CF_CLI_VERSION}/cf8-cli_${CF_CLI_RELEASE_VERSION}_linux_${CF_CLI_RELEASE_ARCH}.tgz"
    fi

    CF_CLI_TMP=$(mktemp -d)
    trap 'rm -rf "$CF_CLI_TMP"' 0
    curl -fsSL -o "$CF_CLI_TMP/cf-cli.tgz" "$CF_CLI_URL"
    tar -xzf "$CF_CLI_TMP/cf-cli.tgz" -C "$CF_CLI_TMP"
    install -m 0755 "$CF_CLI_TMP/cf8" /usr/local/bin/cf8
    ln -sfn cf8 /usr/local/bin/cf
    rm -rf "$CF_CLI_TMP"
    trap - 0

    cf add-plugin-repo CF-Community https://plugins.cloudfoundry.org
    
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

if [ "$INSTALL_CDS_DK" = "true" ]; then
    echo "[cap-tools] Installing @sap/cds-dk version ${CDS_DK_VERSION} ..."
    npm install -g "@sap/cds-dk@${CDS_DK_VERSION}"
fi

if [ "$INSTALL_MBT" = "true" ]; then
    echo "[cap-tools] Installing mbt version ${MBT_VERSION} ..."
    npm install -g "mbt@${MBT_VERSION}"
fi

if [ "$INSTALL_SQLITE3" = "true" ] || [ "$INSTALL_RIPGREP" = "true" ] || [ "$INSTALL_JQ" = "true" ] || [ "$INSTALL_SHELLCHECK" = "true" ] || [ "$INSTALL_PYTHON" = "true" ]; then
    apt-get update -y
fi

if [ "$INSTALL_SQLITE3" = "true" ]; then
    echo "[cap-tools] Installing sqlite3 ..."
    apt-get -y install --no-install-recommends pkg-config libsqlite3-dev sqlite3
fi

if [ "$INSTALL_RIPGREP" = "true" ]; then
    echo "[cap-tools] Installing ripgrep ..."
    apt-get -y install --no-install-recommends ripgrep
fi

if [ "$INSTALL_JQ" = "true" ]; then
    echo "[cap-tools] Installing jq ..."
    apt-get -y install --no-install-recommends jq
fi

if [ "$INSTALL_SHELLCHECK" = "true" ]; then
    echo "[cap-tools] Installing ShellCheck ..."
    apt-get -y install --no-install-recommends shellcheck
fi

if [ "$INSTALL_PYTHON" = "true" ]; then
    echo "[cap-tools] Installing Python 3 with pip and venv support ..."
    apt-get -y install --no-install-recommends python3 python3-pip python3-venv
fi

if [ "$INSTALL_CF_CLI" = "true" ]; then
    echo "[cap-tools] Installing Cloud Foundry CLI ..."
    install_cf
fi

if [ "$INSTALL_UV" = "true" ]; then
    echo "[cap-tools] Installing uv, uvx version ${UV_VERSION} ..."
    if [ "$UV_VERSION" = "latest" ]; then
        UV_INSTALL_URL="https://astral.sh/uv/install.sh"
    else
        UV_INSTALL_URL="https://astral.sh/uv/${UV_VERSION}/install.sh"
    fi
    UV_INSTALLER=$(mktemp)
    trap 'rm -f "$UV_INSTALLER"' 0
    curl -fsSL -o "$UV_INSTALLER" "$UV_INSTALL_URL"
    env UV_INSTALL_DIR="/usr/local/bin" sh "$UV_INSTALLER"
    rm -f "$UV_INSTALLER"
    trap - 0
fi

if [ "$INSTALL_CDSMCP" = "true" ]; then
    echo "[cap-tools] Installing cds-mcp server version ${CDSMCP_VERSION} ..."
    npm install -g "@cap-js/mcp-server@${CDSMCP_VERSION}"
    #cds-mcp requires write access to the npm-global folder
    NPM_GLOBAL_ROOT=$(npm root -g)
    chown -R node:node "${NPM_GLOBAL_ROOT}/@cap-js/mcp-server"
    #add @cap-js/mcp-server and @ui5/mcp-server configurati 
    echo "[cap-tools] Seeding cds-mcp VS Code config ..."
    install -d "/home/node/.vscode-server/data/User"
    cp "$SCRIPT_DIR/mcp.json" "/home/node/.vscode-server/data/User/mcp.json"
    chown -R node:node "/home/node/.vscode-server"
fi