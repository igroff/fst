#! /usr/bin/env bash
# vim: set ft=sh

REPO=${FST_REPOSITORY?You must set FST_REPOSITORY or there is nothing I can do!}
WORKING_DIR=${FST_WORKING_DIR:-~/.fst}

if [ ! -d ${WORKING_DIR} ]; then
  # we need to do our setup
  git clone ${REPO} ${WORKING_DIR}
fi

COMMAND=
