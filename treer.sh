selectedpath=`find ~/ -print | fzf`
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
