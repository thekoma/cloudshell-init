#!/bin/bash
set -e
set -u
set -o pipefail
bashrc() {
  cat /etc/bash.bashrc > ~/.bashrc
  cat << EOF >> ~/.bashrc
export PATH="\$HOME/.local/share/mise/shims:\$PATH"
export PATH="\$HOME/.krew/bin:\$PATH"
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
EOF
}

zshrc() {
  cat << EOF > ~/.zshrc
if [[ -r "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh" ]]; then
  source "\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh"
fi
export PATH="\$HOME/.local/share/mise/shims:\$PATH"
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
plugins=(
  git
  fzf
  debian
  golang
  gcloud
  sudo
  vscode
  docker
  docker-compose
  themes
  kubectl
  kubectx
  terraform
  cp
  mise
  zsh-autosuggestions
)
zstyle :omz:plugins:ssh-agent quiet yes
zstyle :omz:plugins:ssh-agent agent-forwarding on

source \$ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
}

utils() {
  TMPDIR=$(mktemp -d)
  cd "${TMPDIR}"
  export DEBIAN_FRONTEND=noninteractive
  sudo apt -qq update
  sudo apt -qq install -y zsh unzip vim gpg ncdu htop bash-completion netcat-openbsd dnsutils
  complete -o default -F __start_kubectl k
  curl -qfsSLO https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz
  tar zxvf "krew-linux_amd64.tar.gz"
  ./krew-linux_amd64 install krew ns ctx tail
  curl https://mise.run | sh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  cd "${HOME}"
  rm -fr "${TMPDIR}"
  eval "$(~/.local/bin/mise activate bash)"
  mise_install="terraform node fzf kubectl"
  # Mise failing to install something depend on connnection.
  # We can survive that
  set +e
  for pkg in $mise_install; do
    mise install "${pkg}" -y
    mise use --global "${pkg}@latest"
  done
  set -e
}


utils
bashrc
zshrc
echo -e "Done.\nNow load bash again with 'source ~/.bashrc' or switch to zsh running 'zsh'."
echo -e "To install terraform  or other tools use mise.\nI.E. \nmise plugin install terraform\nmise install terraform\nmise use --global terraform@latest"