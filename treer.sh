selectedpath=`/root/stribog -r /root -f . -f node_modules -f e2e -f build -f target -f dist | fzf`
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
