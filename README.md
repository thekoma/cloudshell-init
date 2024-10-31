# I don't like vanilla shells.


## How to install:

### curl
```bash
gcloud cloud-shell ssh --authorize-session
bash <(curl -fsSL https://raw.githubusercontent.com/thekoma/cloudshell-init/main/init.sh)
zsh
```

### wget
```bash
gcloud cloud-shell ssh --authorize-session
bash <(wget -O - https://raw.githubusercontent.com/thekoma/cloudshell-init/main/init.sh)
zsh
```

### git
```bash
gcloud cloud-shell ssh --authorize-session
git clone https://github.com/thekoma/cloudshell-init.git
bash cloudshell-init/init.sh
zsh
```

### ToDo:
- Shorten Url
- Use TAGS
- Check if env already exists
- Auto refresh?