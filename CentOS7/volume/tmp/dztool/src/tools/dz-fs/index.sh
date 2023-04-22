#!/bin/bash -i

cpDir() {
  rm -fr $2
  mkdir -p $2
  /bin/cp -fa $1/* $2
}

lnCli() {
  chmod u+x $1
  ln -fs $1 /bin/$2
}
