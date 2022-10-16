selectedpath=`~/stribog -u -i -r ~/dev -r  ~/.config/nvim -r /mnt/c/Dev -f asset  -f resource -f test -f conf -f logs -f .git -f .next -f .swc -f node_modules -f e2e -f build -f target -f dist | fzf`
if [ $selectedpath != '' ]; then
  windowname=${selectedpath##*/}
  if [ -d $selectedpath ]; then
    tmux neww -c "$selectedpath" -n "$windowname"
  else
    code $selectedpath
  fi
else
  echo "Selected directory not valid"
fi
