### Added by Zinit's installer
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}Zinit%F{220} (zdharma-continuum)…%f"
    command mkdir -p "$(dirname $ZINIT_HOME)"
    
    # 執行 clone 並根據結果輸出
    if command git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME"; then
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b"
    else
        print -P "%F{160}▓▒░ The clone has failed. Please check your internet connection.%f%b"
        # 如果失敗，不應該繼續 source，直接回傳防止報錯
        return 1
    fi
fi

# 只有在檔案存在時才 source
source "$ZINIT_HOME/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

### End of Zinit's installer chunk

zinit ice depth=1; zinit light romkatv/powerlevel10k

zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

zinit ice lucid wait='0' atinit='zpcompinit' cache
zinit light zdharma/fast-syntax-highlighting

zinit ice lucid wait="0" atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

zinit ice lucid wait='0'
zinit light zsh-users/zsh-completions

zinit ice lucid wait="0" atload='eval "$(aws-vault --completion-script-zsh)" cache'
zinit ice lucid wait="0" atload='complete -C "/opt/homebrew/bin/aws_completer" aws cache'
zinit ice lucid wait="0" atload='source <(kubectl completion zsh) cache'

zinit snippet OMZ::lib/completion.zsh
zinit snippet OMZ::lib/history.zsh
zinit snippet OMZ::plugins/command-not-found/command-not-found.plugin.zsh
zinit snippet OMZ::plugins/aws

zinit ice lucid wait='0'
zinit light djui/alias-tips

zinit ice lucid wait='0'
zinit light agkozak/zsh-z

zinit ice lucid wait='0'
zinit light Aloxaf/fzf-tab

zstyle ':completion:*:*:aws' fzf-search-display true
