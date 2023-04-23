#!/bin/bash -i

TextRed='\e[1;31m'
TextGreen='\e[1;32m'
TextYellow='\e[1;33m'
TextBlue='\e[1;34m'
TextPink='\e[1;35m'
TextClear='\e[0m'

Space04="    "
Space08=$Space04$Space04
Space12=$Space08$Space04
Space16=$Space08$Space08
Space20=$Space16$Space04
Space24=$Space20$Space08
Space28=$Space24$Space04
Space32=$Space28$Space04

logStage() {
  echo ""
  echo ""
  echo -e "${Space16}${TextBlue}============================================================"
  echo -e "${Space16}${TextBlue}[Stage$1] $2${TextClear}"
}

logStep() {
  echo -e "${Space16}$1"
}

logResult() {
  echo -e "${Space32}${TextGreen}[RESULT] Finish Stage Successfully!${TextClear}"
  echo ""
}

logErrorResult() {
  echo -e "${Space16}${TextRed}[Error] $1${TextClear}"
  echo ""
}

cpDir() {
  rm -fr $2
  mkdir -p $2
  /bin/cp -fa $1/* $2
}

lnCli() {
  chmod u+x $1
  ln -fs $1 /bin/$2
}
