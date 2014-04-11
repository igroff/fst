#! /usr/bin/env bash
# vim: set ft=sh

REPO=${FST_REPOSITORY?You must set FST_REPOSITORY or there is nothing I can do!}
REPO_DIR=${FST_REPO_DIR:-~/.fst}

# ******************************************************************************
# utils
debug() { [ -n "${DEBUG}" ] && echo ${FUNCNAME^^} $@; }
export -f debug
info() { echo "$@"; }
export -f info
error() { echo "$@" >&2; }
export -f error
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


debug "Action: ${ACTION}"
if [ "${ACTION}" = "create" ]; then
  (
    cd ${REPO_DIR}
    CO_OUTPUT=$(
      git checkout $TEMPLATE_NAME  2>&1 || git checkout -b origin/${TEMPLATE_NAME} 2>&1 || git checkout -b ${TEMPLATE_NAME} origin/master 2>&1;
    )
    CO_RESULT=$?
    if [ $CO_RESULT -ne 0 ]; then
      error 'We seem to have encountered a problem checking out the template branch!'
      debug "exit code $CO_RESULT"
      error "$CO_OUTPUT"
      exit 4
    fi

    CP_OUTPUT=$(debug "Copying template contents from ${TEMPLATE_DIR}" && cp -R ${TEMPLATE_DIR}/* .;)
    CP_RESULT=$?
    if [ $CP_RESULT -ne 0 ]; then 
      error 'We had some trouble copying the contents of your template into the repo for checkin'
      debug "exit code $CP_RESULT"
      error "The problem looked like: ${CP_OUTPUT}"
      exit 5
    fi

    COMMIT_OUTPUT=$(
      git add . && git commit -m "no message here";
    )
    COMMIT_RESULT=$?
    if [ $COMMIT_RESULT -ne 0 -a $COMMIT_RESULT -ne 1 ]; then
      error 'We seem to have had an error checking in your template'
      debug "exit code $COMMIT_RESULT"
      error "Here's what happend: ${COMMIT_OUTPUT}"
      exit 6
    fi
    
    PUSH_OUTPUT=$(
      git push origin ${TEMPLATE_NAME} 2>&1;
    )
    PUSH_RESULT=$?
    if [ $PUSH_RESULT -ne 0 ]; then
      error 'We had some trouble pushing the template changes back to origin'
      error "See: \n${PUSH_OUTPUT}"
      exit 7
    fi
  )
  CREATE_RESULT=$?
  if [ $CREATE_RESULT -ne 0 ]; then
    error 'Looks like we had some problems creating the template for you, you work that out and try again ya hear?'
    exit $CREATE_RESULT
  fi
elif [ "$ACTION" = "list" ]; then
  # so, git will put * into the branch listing which is kind of a bitch as the shell
  # sure wants to expand that, so we tell it NO GLOBBIN' KITTY!
  set -f
  LIST_OUTPUT=$(
   cd "${REPO_DIR}" && git branch 2>&1;
  )
  LIST_RESULT=$?
  if [ $LIST_RESULT -ne 0 ]; then
    error 'Hmm, something went wrong while listing your templates..'
    debug $LIST_RESULT
    error $LIST_OUTPUT
    exit $LIST_RESULT
  fi
  echo "Here are the templates I know about:"
  for template in $(echo $LIST_OUTPUT | sed -e s[\*[[g )
  do
    if [ 'origin/master' != "$template" -a 'master' != "$template" ]; then
      echo "  $template"
    fi
  done
  # undo the noglob from before
  set +f
elif [ "$ACTION" = "unpack" ]; then
  echo Im totally unpacking your templates
fi
