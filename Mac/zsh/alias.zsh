alias g="git"
alias c="pbcopy"
alias k="kubectl"
alias dbt="docker build -t"
alias d="docker"
alias tf="terraform"
alias ap="aws --profile"
alias av="aws-vault"
alias avm='av exec -t $(op item get "[aws] [going-cloud-iam-management] [aaronhung]" --otp)'
alias ave='av export -t $(op item get "[aws] [going-cloud-iam-management] [aaronhung]" --otp)'
alias uav="unset AWS_VAULT"
alias dc="docker compose"
alias dcud="docker compose up -d"
alias dcd="docker compose down"
alias awslocal="aws --profile=local --endpoint-url=http://localhost:4566"

# 基本取代 ls
alias ls='eza --icons --group-directories-first'
# 詳細清單 (包含 Git 狀態、標頭)
alias ll='eza -lgh --icons --git --group-directories-first'
# 顯示隱藏檔
alias la='eza -lagh --icons --git'
# 樹狀顯示
alias lt='eza --tree --icons'
alias cat='bat'
alias find='fd'
alias grep='rg'