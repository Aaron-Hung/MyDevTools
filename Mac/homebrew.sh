# 透過 Homebrew 官方安裝腳本安裝 brew（若已安裝，依官方腳本行為處理）。
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# 載入 Apple Silicon 常見路徑下的 brew 環境變數，讓目前 shell 立即可用 brew 指令。
eval "$(/opt/homebrew/bin/brew shellenv)"

# 確保 git 已安裝且更新到最新版本，避免後續工具鏈因舊版 git 出現相容性問題。
brew install git
brew upgrade git

# Python
# 安裝 Python 與升級 pip，提供後續 Python 工具與套件管理能力。
brew install python3
pip install --upgrade pip

# library

# 基礎開發工具鏈與語言工具：
brew install go
brew install tfenv
brew install nvm

# 使用 nvm 安裝 Node.js (避免與 brew install node 衝突)
export NVM_DIR="$HOME/.nvm"
[ -d "$NVM_DIR" ] || mkdir -p "$NVM_DIR"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'

# aws

# 安裝 AWS CLI。
brew install awscli

# session manager

# 安裝 AWS Session Manager Plugin（從 AWS 官方 S3 下載安裝包）。
# 流程：下載 zip -> 解壓 -> 以 sudo 安裝到系統路徑 -> 清理暫存檔。
# 注意：此段會要求管理員權限，且依賴網路可連線到 AWS S3。
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
unzip sessionmanager-bundle.zip
sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
rm ./sessionmanager-bundle.zip
rm -rf ./sessionmanager-bundle

# aws-vault 與 macOS Keychain 整合：
# 1) 安裝 aws-vault cask
# 2) 將 aws-vault keychain 加入可搜尋 keychain 清單
# 3) 套用 keychain 設定，避免每次使用都出現不必要提示
brew install --cask aws-vault
# let keychains knows the aws-vault
security list-keychains -s `security list-keychains | xargs` ~/Library/Keychains/aws-vault.keychain-db
security set-keychain-settings ~/Library/Keychains/aws-vault.keychain-db

# IDE

# 安裝常用 IDE/開發工具（註解提示可先行備份設定與外掛）。
brew install --cask cursor
brew install --cask sublime-text

# Containers
# 容器與雲原生工具：k8s CLI、helm、Docker Desktop。
brew install kubectl
brew install helm
brew install --cask docker

# Misc

# 日常工作與生產力工具（通訊、筆記、視窗管理、瀏覽器、同步工具等）。
brew install --cask iterm2
brew install --cask appcleaner
brew install --cask deepl
brew install --cask 1password
brew install --cask 1password/tap/1password-cli
brew install --cask slack
brew install --cask google-chrome
brew install --cask arc
brew install --cask notion
brew install --cask discord
brew install --cask miro
brew install --cask rectangle
brew install --cask hiddenbar
brew install --cask daisydisk
brew install --cask alt-tab
brew install --cask dropzone
brew install --cask middleclick
brew install --cask karabiner-elements
brew install --cask monitorcontrol
brew install --cask fork

# Yahoo KeyKey!（ykk_installer：Yahoo 輸入法現代化安裝器）
if [[ -d "/Library/Input Methods/Yahoo! KeyKey.app" ]]; then
  echo "Yahoo KeyKey is already installed. Skipping..."
else
  YKK_URL="https://github.com/zonble/ykk_installer/releases/download/v3/YahooKeyKey.pkg.zip"
  tmp_dir="$(/usr/bin/mktemp -d)"
  curl -L "${YKK_URL}" -o "${tmp_dir}/YahooKeyKey.pkg.zip"
  unzip -o "${tmp_dir}/YahooKeyKey.pkg.zip" -d "${tmp_dir}"
  ykk_pkg_candidates=( "${tmp_dir}"/*.pkg )
  if [[ ! -e "${ykk_pkg_candidates[0]}" ]]
  then
    echo "Yahoo KeyKey pkg not found under: ${tmp_dir}" >&2
    rm -rf "${tmp_dir}"
    exit 1
  fi
  sudo installer -pkg "${ykk_pkg_candidates[0]}" -target /
  rm -f "${tmp_dir}/YahooKeyKey.pkg.zip"
  rm -rf "${tmp_dir}"
fi

# Command line tools

# 終端機常用工具集合
brew install htop
brew install bottom
brew install tmux
brew install cmux
brew install fzf
brew install jq
brew install fd
brew install eza
brew install rg
brew install bat
brew install gemini-cli
