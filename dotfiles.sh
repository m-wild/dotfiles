#!/bin/bash

## dotfiles.sh
## michael@mwild.me

if [[ -z ${1+x} ]]; then
  echo 'usage: ./dotfiles.sh command'
  echo ''
  echo 'commands:'
  echo '    build  create symlinks'
  echo '    clean  delete symlinks'
  exit 0
fi

old_cwd=$(pwd)

data_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/data"

dotfiles=(
  .bashrc
  .psqlrc
  .inputrc
  .gitconfig
  .bash_profile
  .vimrc
)

cd ~

if [[ $1 == 'clean' ]]; then
  for file in ${dotfiles[@]}; do

    if [[ -L $file ]]; then
      echo "removing symlink at $file"
      rm $file
    fi

  done
fi

if [[ $1 == 'build' ]]; then
  for file in ${dotfiles[@]}; do

    if [[ -f $file ]]; then
      echo "file already exists at $file"
    else
      echo "create link $data_dir/$file <==> $file"

      ln -s "$data_dir/$file" $file
    fi

  done
fi

cd $old_cwd
