#! /usr/bin/env bash
# vim: set ft=sh

REPO=${FST_REPOSITORY?You must set FST_REPOSITORY or there is nothing I can do!}
WORKING_DIR=${FST_WORKING_DIR:-~/.fst}

# ******************************************************************************
# utils
debug() { [ -n "${DEBUG}" ] && write_log ${FUNCNAME^^} $@; }
info() { echo "$@"; }
error() { echo "$@" >&2; }
#
# ******************************************************************************

which git &> /dev/null || $(echo 'You must have git, or I can do nothing!' && exit 1)

debug Working directory: ${WORKING_DIR}
if [ ! -d ${WORKING_DIR} ]; then
  info "going to get your repository for the first time, gimme a sec."
  CLONE_OUTPUT=$(git clone ${REPO} ${WORKING_DIR} 2>&1)
  if [ $? -ne 0 ]; then
    error "error cloning your template repo, is it set correctly?  Here's what I think it is: ${REPO}"
    error "And the error from the git was: ${CLONE_OUTPUT}"
    exit 3
  fi
fi

while getopts ":d:n:" opt; do
  case $opt in
    d)
      TEMPLATE_DIR=${OPTARG}
      ;;
    n)
      TEMPLATE_NAME=${OPTARG}
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      [ $OPTARG == d ] && echo "You'll need to give me a directory to create template from." >&2
      [ $OPTARG == n ] && echo "To use -${OPTARG} you need to provide a name" >&2
      exit 1
      ;;
  esac
done

[ -n "$1" ] && TEMPLATE_NAME=$1
# if we have a template dir, we're creating a template
# if we have just a template name, we're unpacking a template
# if we got nothing, we're listing our templates

([ -n "${TEMPLATE_DIR}" ] && ACTION=create) || ([ -n "${TEMPLATE_NAME}" ] && ACTION=unpack)

if [ -n "${TEMPLATE_DIR}" ]; then
  ACTION=create
elif [ -n "${TEMPLATE_NAME}" ]; then
  ACTION=unpack
else
  ACTION=list
fi

echo $ACTION
