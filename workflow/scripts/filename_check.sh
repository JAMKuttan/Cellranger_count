#!/bin/bash
#filename_check.sh
#*
#* --------------------------------------------------------------------------
#* Licensed under MIT (https://git.biohpc.swmed.edu/BICF/Astrocyte/cellranger_count/blob/develop/LICENSE)
#* --------------------------------------------------------------------------
#*

usage() {
  echo "-r  --ref file"
  exit 1
}

OPTIND=1
while getopts :r: opt
do
  case ${opt} in
    r) ref=${OPTARG};;
  esac
done

shift $((${OPTIND} -1))

name=$(readlink -e ${ref})

if [ $(find $name -name "* *" | wc -l) -gt 0 ]; then
  echo "Error: Spaces found in Reference Files"
  echo $(find $name -name "* *")
  exit 21
fi

if [ $(echo "${ref}" | tr -d ' ') != "${ref}" ]; then
  echo "Error: Spaces found in Reference Files"
  echo ${ref}
  exit 21
fi