#!/usr/bin/env bash

function usage {
    echo "Usage: $0 [-d] <directory> <label_file>"
    exit 1
}

function rename {
    echo 'Rename process initiated...'

    files=$(find "$1" -maxdepth 1 -type f)
    mapfile -t labels < "$2"

    readarray -t sorted_files < <(printf "%s\n" "${files[@]}" | sort -V) 

    if [ ${#sorted_files[@]} -ne ${#labels[@]} ]; then
    	echo "Number of files (${#sorted_files[@]}) in target directory and labels (${#labels[@]}) do not match."
    	exit 1
    fi    

    for idx in $(seq 0 ${#sorted_files[@]}); do
	path=$(dirname "${sorted_files[idx]}%")
	filename=$(basename "${sorted_files[idx]}")
	ext="${filename##*.}"
	name="${filename%.*}"

	if [[ ! -z "${filename}" ]]; then
	    if [ $dry = true ]; then
		echo "mv ${sorted_files[idx]} $path/${labels[idx]}.${ext}"
	    else
		mv "${sorted_files[idx]}" "$path/${labels[idx]}.${ext}"
	    fi
	fi
    done

    echo 'Rename process complete.'
}

dry=false

while getopts ":d" opt; do
    case "${opt}" in
	d)
	    dry=true
	    dir="$2"
	    lbls="$3"
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    ;;
    esac    
done

if [ $# -lt 2 ]; then
    echo 'lt 2'
    echo $#
    usage
else
    if [ $dry = false ]; then
	dir="$1"
	lbls="$2"
    fi
    
    if [ -d "$dir" ] && [ -f "$lbls" ]; then
	rename "$dir" "$lbls"
    else
	echo "$dir"
	echo "$lbls"
	usage
    fi    
fi
