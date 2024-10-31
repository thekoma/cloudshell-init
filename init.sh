#!/bin/bash

bashrc() {
  cat /etc/bash.bashrc > ~/.bashrc
  cat << EOF >> ~/.bashrc
eval "$(~/.local/bin/mise activate bash)"
export PATH="$HOME/.krew/bin:$PATH"
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
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  fzf
  debian
  vim
  golang
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
source \$ZSH/oh-my-zsh.sh

source \$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source <(fzf --zsh)
eval "\$(~/.local/bin/mise activate zsh)"'
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "\$(mise activate zsh)"
EOF
}

utils() {
  TMPDIR=$(mktemp -d)
  cd $TMPDIR
  DEBIAN_FRONTEND=noninteractive
  sudo apt -qq update
  sudo apt -qq install -y fzf zsh
  complete -o default -F __start_kubectl k
  curl -qfsSLO https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz
  tar zxvf "krew-linux_amd64.tar.gz"
  ./krew-linux_amd64 install krew ns ctx tail
  curl https://mise.run | sh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  cd
  rm -fr $TMPDIR
}


utils
bashrc
zshrc
echo -e "Done.\nNow load bash again with 'source ~/.bashrc' or switch to zsh running 'zsh'."
echo -e "To install terraform  or other tools use mise.\nI.E. \nmise plugin install terraform\nmise install terraform\nmise use --global terraform@latest"