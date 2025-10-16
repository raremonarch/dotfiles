cd $HOME
git init
git branch -m main
git remote add origin https://github.com/daevski/dotfiles.git
git branch --set-upstream-to=origin/main main
git pull origin main