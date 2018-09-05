#!/bin/bash

HOST="ub64"

FLAGS="-av"
EXCLUDE=(*.o .*.swp *.vcxproj* *.dbg)
for ex in ${EXCLUDE[@]}
do
  FLAGS="$FLAGS --exclude=$ex"
done

src="$HOME/Desktop/"
dest="${HOST}:/source/"
#item="hawkeye/apps/vtap/src/server/os/linux"
item="hawkeye/apps"

src+="$item"
dest+="`dirname $item`"

echo "rsync   $FLAGS"
echo "FROM:   ${src}"
echo "TO:     ${dest}"

rsync $FLAGS ${src} ${dest}
