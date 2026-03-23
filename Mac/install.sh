# 安裝 Xcode Command Line Tools 與個人開發環境設定。
# 若腳本中使用到未定義變數，立即中止，避免在錯誤狀態下繼續執行。
set -u

# 終端機彩色輸出工具：
# 只有在互動式 TTY 下才輸出 ANSI 顏色，避免在非互動環境出現雜訊字元。
if [[ -t 1 ]]
then
  # 將 ANSI 顏色碼包成可重用函式，輸入數字代碼輸出轉義字串。
  tty_escape() { printf "\033[%sm" "$1"; }
else
  # 非 TTY（例如 pipe/CI）時停用顏色輸出，避免污染日誌。
  tty_escape() { :; }
fi
# 產生粗體+顏色樣式字串，供後續訊息函式使用。
tty_mkbold() { tty_escape "1;$1"; }
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

TOUCH=("/usr/bin/touch")

# 致命錯誤處理：任何不可恢復的步驟失敗時，印出錯誤並結束腳本。
abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

shell_join() {
  # 將多個參數組成「可閱讀的命令字串」供日誌輸出使用。
  # 注意：這不是完整 shell escaping，只是把空白轉成 \ 以提升可讀性。
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"
  do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

chomp() {
  # 移除字串中的換行，避免警告/錯誤訊息在終端輸出時斷行。
  printf "%s" "${1/"$'\n'"/}"
}

ohai() {
  # 以統一格式輸出流程訊息（藍色前綴），方便追蹤目前步驟。
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

warn() {
  # 以警告樣式輸出非致命訊息到 stderr。
  printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")" >&2
}

have_sudo_access() {
  # 驗證目前使用者是否具備 sudo 權限。
  # 本腳本後續包含系統層級操作（softwareupdate/xcode-select 等），
  # 若無管理員權限，提早中止可避免做到一半才失敗。
  if [[ ! -x "/usr/bin/sudo" ]]
  then
    return 1
  fi

  local -a SUDO=("/usr/bin/sudo")

  if [[ -z "${HAVE_SUDO_ACCESS-}" ]]
  then
    "${SUDO[@]}" -v && "${SUDO[@]}" -l mkdir &>/dev/null
    HAVE_SUDO_ACCESS="$?"
  fi

  if [[ "${HAVE_SUDO_ACCESS}" -ne 0 ]]
  then
    abort "Need sudo access on macOS (e.g. the user ${USER} needs to be an Administrator)!"
  fi

  return "${HAVE_SUDO_ACCESS}"
}

execute() {
  # 統一命令執行入口：任一命令失敗就中止，避免錯誤狀態向後擴散。
  if ! "$@"
  then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

execute_sudo() {
  # 需要提權時透過 sudo 執行；同時保留一致的輸出格式，方便追蹤流程。
  local -a args=("$@")
  if have_sudo_access
  then
    ohai "/usr/bin/sudo" "${args[@]}"
    execute "/usr/bin/sudo" "${args[@]}"
  else
    ohai "${args[@]}"
    execute "${args[@]}"
  fi
}

getc() {
  # 讀取單一按鍵（不回顯），用於等待使用者在 GUI 安裝後手動確認繼續。
  # 先保存 stty 狀態，完成後還原，避免影響後續終端行為。
  local save_state
  save_state="$(/bin/stty -g)"
  /bin/stty raw -echo
  IFS='' read -r -n 1 -d '' "$@"
  /bin/stty "${save_state}"
}

should_install_command_line_tools() {
  # 以 CLT 內建 git 的存在與否作為判斷條件：
  # 不存在代表尚未安裝 Command Line Tools。
  ! [[ -e "/Library/Developer/CommandLineTools/usr/bin/git" ]]
}

# 步驟 1：先確認 sudo 權限（可能會要求輸入密碼）。
# 這是整體流程的前置門檻，失敗就不繼續。
ohai 'Checking for `sudo` access (which may request your password)...'

have_sudo_access

if should_install_command_line_tools
then
  # 步驟 2A：優先走「非 GUI」安裝路徑。
  # 透過 softwareupdate 自動找出並安裝最新 CLT，適合腳本化執行。
  ohai "The Xcode Command Line Tools will be installed."
  ohai "Searching online for the Command Line Tools"
  # 建立佔位檔，讓 softwareupdate -l 能列出 CLT 相關項目。
  clt_placeholder="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  execute_sudo "${TOUCH[@]}" "${clt_placeholder}"

  # 從 softwareupdate 清單中擷取 CLT Label，排序後取最新版本。
  # 流程：過濾 CLT -> 取 Label 欄位 -> 清理字串 -> 版本排序 -> 取最後一筆。
  clt_label_command="/usr/sbin/softwareupdate -l |
                      grep -B 1 -E 'Command Line Tools' |
                      awk -F'*' '/^ *\\*/ {print \$2}' |
                      sed -e 's/^ *Label: //' -e 's/^ *//' |
                      sort -V |
                      tail -n1"
  clt_label="$(chomp "$(/bin/bash -c "${clt_label_command}")")"

  if [[ -n "${clt_label}" ]]
  then
    ohai "Installing ${clt_label}"
    # 實際安裝 CLT，並把 active developer directory 指向 CLT 路徑，
    # 確保後續 xcode-select/git/編譯工具皆可正常使用。
    execute_sudo "/usr/sbin/softwareupdate" "-i" "${clt_label}"
    execute_sudo "/usr/bin/xcode-select" "--switch" "/Library/Developer/CommandLineTools"
  fi
  # 清理暫存佔位檔，避免殘留系統狀態。
  execute_sudo "/bin/rm" "-f" "${clt_placeholder}"
fi

if should_install_command_line_tools && test -t 0
then
  # 步驟 2B（備援）：若 CLI 路徑後仍未安裝完成，改用 GUI 安裝器。
  # 這段需要使用者互動：安裝完成後按任意鍵繼續。
  ohai "Installing the Command Line Tools (expect a GUI popup):"
  execute "/usr/bin/xcode-select" "--install"
  echo "Press any key when the installation has completed."
  getc
  execute_sudo "/usr/bin/xcode-select" "--switch" "/Library/Developer/CommandLineTools"
fi

# install dev tools and settings

# DevTools 專案路徑與遠端來源：
# 後續會把此 repo 當成 dotfiles 與安裝腳本的單一來源。
DEVTOOL_REPOSITORY=~/Documents/projects/MyDevTools
DEVTOOL_REMOTE_REPOSITORY="https://github.com/Aaron-Hung/MyDevTools"

mkdir -p $DEVTOOL_REPOSITORY

ohai "Downloading and installing Mac DevTool..."
(
  # 步驟 3：同步 repo 到「與遠端一致」的乾淨狀態。
  # 這裡是強制同步策略，目的是確保後續連結到的是可預期版本。
  cd "${DEVTOOL_REPOSITORY}" >/dev/null || return

  execute "git" "init" "-q"

  execute "git" "config" "remote.origin.url" "${DEVTOOL_REMOTE_REPOSITORY}"
  execute "git" "config" "remote.origin.fetch" "+refs/heads/*:refs/remotes/origin/*"

  execute "git" "config" "core.autocrlf" "false"

  execute "git" "fetch" "--force" "origin"
  execute "git" "fetch" "--force" "--tags" "origin"

  # 風險警告：這行會直接丟棄 DEVTOOL_REPOSITORY 內所有本機修改。
  # 若該目錄有未提交內容，執行前務必先備份或 commit。
  execute "git" "reset" "--hard" "origin/master"
  
  # 步驟 4：把家目錄下設定檔改成指向本 repo 的連結（ln / ln -s）。
  # 目的：集中管理設定，更新 repo 即可更新環境設定。
  rm -f ~/.gitalias
  ln $PWD/gitalias/gitalias.txt ~/.gitalias
  rm -f ~/.gitconfig
  ln $PWD/Mac/.gitconfig ~/.gitconfig
  rm -f ~/.zshrc
  ln $PWD/Mac/.zshrc ~/.zshrc
  # 高風險警告：會先刪除既有 ~/.ssh 目錄再重建連結。
  # 代表原本 SSH 金鑰與設定若未備份，可能遺失。
  rm -rf ~/.ssh
  ln -s $PWD/Mac/ssh ~/.ssh
  rm -rf ~/.myzsh
  ln -s $PWD/Mac/zsh ~/.myzsh
  mkdir -p ~/.aws
  rm -rf ~/.aws/config
  ln $PWD/Mac/aws/config ~/.aws/config
  
  # 步驟 5：安裝平台相依元件與套件管理工具。
  # - Rosetta：讓 Apple Silicon 可執行部分 x86_64 工具
  # - zinit：zsh plugin manager
  # - homebrew.sh：你的自訂 brew 安裝/設定流程
  softwareupdate --install-rosetta
  sh -c "$(curl -fsSL https://git.io/zinit-install)"
  sh $PWD/Mac/homebrew.sh
) || exit 1
