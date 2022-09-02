selectedpath=`find ~/dev -print | fzf`
if [ $selectedpath != '' ]; then
  windowname=${selectedpath##*/}
  tmux neww -c "$selectedpath" -n "$windowname"
else
  echo "Selected directory not valid"
fi
