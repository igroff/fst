#! /usr/bin/env bash
# vim: set ft=sh

REPO=${FST_REPOSITORY?You must set FST_REPOSITORY or there is nothing I can do!}
REPO_DIR=${FST_REPO_DIR:-~/.fst}

# ******************************************************************************
# utils
debug() { [ -n "${DEBUG}" ] && write_log ${FUNCNAME^^} $@; }
info() { echo "$@"; }
error() { echo "$@" >&2; }
#
# ******************************************************************************

which git &> /dev/null || $(echo 'You must have git, or I can do nothing!' && exit 1)

debug Working directory: ${REPO_DIR}
if [ ! -d ${REPO_DIR} ]; then
  info "going to get your repository for the first time, gimme a sec."
  CLONE_OUTPUT=$(git clone ${REPO} ${REPO_DIR} 2>&1)
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

# for use in subshells and such
CURRENT_DIR=`pwd`

if [ -n "${TEMPLATE_DIR}" ]; then
  # if the template dir starts with / then it's absolute, otherwise 
  # relative to our current location
  [[ "${TEMPLATE_DIR}" == \/* ]] || TEMPLATE_DIR=${CURRENT_DIR}/${TEMPLATE_DIR}
  ACTION=create
  # if the user has provided a template name via -n, it will be the 4th parameter 
  # because -d <dir> get's us here and to specify a template name it'll be like
  # -d <dir> -n <name>
  TEMPLATE_NAME=${4:-$(basename ${TEMPLATE_DIR})}
elif [ -n "${TEMPLATE_NAME}" ]; then
  ACTION=unpack
else
  ACTION=list
fi


if [ "${ACTION}" = "create" ]; then
(
  cd ${REPO_DIR}
  CO_OUTPUT=$(
    git checkout $TEMPLATE_NAME  || git checkout -b origin/${TEMPLATE_NAME} || git checkout -b origin/master;
  )
  CO_RESULT=$?
  if [ $CO_RESULT -ne 0 ]; then
    error "We seem to have encountered a problem checking out the template branch?"
    #keep in mind, I'm a subshell
    exit 1
  fi
)
fi

echo Action: $ACTION
echo Template Dir: $TEMPLATE_DIR
echo Template Name: $TEMPLATE_NAME

