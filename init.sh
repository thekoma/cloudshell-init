#!/bin/bash

bashrc() {
  cat /etc/bash.bashrc > ~/.bashrc
  cat << EOF >> ~/.bashrc
export PATH="$HOME/.krew/bin:$PATH"
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
EOF
}

zshrc() {
  cat << EOF > ~/.zshrc
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  fzf
  debian
  vim
  golang
  iterm2
  gcloud
  sudo
  vscode
  ssh-agent
  docker
  docker-compose
  brew
  themes
  kubectl
  kube-ps1
  kubectx
  terraform
  tmux
  cp
  autoenv
  gnu-utils
  mise
)

zstyle :omz:plugins:ssh-agent quiet yes
zstyle :omz:plugins:ssh-agent agent-forwarding on
source $ZSH/oh-my-zsh.sh

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source <(fzf --zsh)

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$(mise activate zsh)"
EOF
}

utils() {
  TMPDIR=$(mktemp -d)
  cd $TMPDIR
  apt -qq update
  apt -qq install fzf zsh bzt
  complete -o default -F __start_kubectl k
  curl -fsSLO https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz
  tar zxvf "krew-linux_amd64.tar.gz"
  ./krew-linux_amd64 install krew ns ctx tail
  curl https://mise.run | sh
  echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
  echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  cd
  rm -fr $TMPDIR
}


utils
bashrc
zshrc
echo -e "Done.\nNow load bash again with 'source ~/.bashrc' or switch to zsh running 'zsh'."
echo -e "To install terraform  or other tools use mise.\nI.E. \nmize plugin install terraform\nmize install terraform\nmise use --global terraform@latest"