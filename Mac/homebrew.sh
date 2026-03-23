# 透過 Homebrew 官方安裝腳本安裝 brew（若已安裝，依官方腳本行為處理）。
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# 載入 Apple Silicon 常見路徑下的 brew 環境變數，讓目前 shell 立即可用 brew 指令。
eval "$(/opt/homebrew/bin/brew shellenv)"
# 啟用常用 cask 倉庫（GUI 應用與版本變體）。
brew tap homebrew/cask
brew tap homebrew/cask-versions

# 先更新 git 到最新版本，避免後續工具鏈因舊版 git 出現相容性問題。
brew upgrade git

# Python
# 安裝 Python 與升級 pip，提供後續 Python 工具與套件管理能力。
brew install python3
pip install --upgrade pip

# 安裝 pyenv，便於多版本 Python 管理與專案隔離。
brew install pyenv

# library

# 基礎開發工具鏈與語言工具：
# - rustup-init: Rust toolchain 管理
# - go: Go 語言環境
# - flutter: 跨平台 App SDK
# - tfenv: Terraform 版本管理
# - nvm: Node.js 版本管理
brew install rustup-init
brew install go
brew install flutter
brew install tfenv
brew install nvm

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
brew install --cask jetbrains-toolbox   #backup settings
brew install --cask visual-studio-code  #backup settings and plugin
brew install --cask warp        
brew install --cask insomnia
brew install --cask gitkraken

# Containers
# 容器與雲原生工具：k8s CLI、helm、Docker Desktop。
brew install kubectl
brew install helm      
brew install --cask docker

# Misc

# 日常工作與生產力工具（通訊、筆記、視窗管理、瀏覽器、同步工具等）。
brew install --cask appcleaner
brew install --cask deepl
brew install --cask 1password
brew install --cask 1password/tap/1password-cli
brew install --cask alfred              
brew install --cask eul
brew install --cask cleanshot
brew install --cask brave-browser
brew install --cask slack
brew install --cask obsidian
brew install --cask mos
brew install --cask rectangle
brew install --cask todoist
brew install --cask dropbox
brew install --cask google-drive
brew install --cask hiddenbar
brew install --cask arc
brew install --cask notion
brew install --cask discord
brew install --cask miro
brew install --cask daisydisk
brew install --cask alt-tab
brew install --cask http-toolkit
brew install --cask zoom
brew install --cask dropzone

# Command line tools

# 終端機常用工具集合（系統監控、JSON、搜尋、GitLab CLI、加密、壓測等）。
brew install htop
brew install bottom
brew install tmux
brew install jq
brew install fd
brew install exa
brew install dog
brew install mysql-client
brew install glab
brew install gpg2
brew install k6
brew install gnupg
