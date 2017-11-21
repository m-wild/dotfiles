#!/bin/bash

## dotfiles.sh
## michael@mwild.me


data="$(dirname $0)/data"
config="$data/dotfiles.json"

num_symlinks=$(jq -r ".symlink[].name" $config | wc -l)
# echo "symlinks: $num_symlinks"
for (( i=0; i<$num_symlinks; i++ )); do
    enabled="$(jq -r ".symlink[$i].enabled.linux" $config)"
    
    if [[ $enabled != 'true' ]]; then
        continue
    fi
    
    target_path="$data/$(jq -r ".symlink[$i].target" $config)"
    link_path=$(jq -r ".symlink[$i].link.linux" $config)

    echo "will link $link_path to target $target_path"

    link_dir=$(dirname $link_path)
    echo $link_dir

    # why the hell does this not work with variables...
    realpath -m $(eval $link_dir)


    # if [[ ! -a $link_dir ]]
    # then
    #     echo "link dir does not exist"
    #     echo "mkdir -p $link_dir"
    # fi

    # realpath 


done

