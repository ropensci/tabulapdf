#!/bin/bash
set -o errexit -o nounset
knitreadme(){
  ## Set up Repo parameters
  git init
  git config user.name "leeper"
  git config user.email "thosjleeper@gmail.com"
  git config --global push.default simple

  ## Get drat repo
  git remote add upstream "https://$GH_TOKEN@github.com/$TRAVIS_REPO_SLUG.git"
  git fetch upstream
  git checkout master

  Rscript -e 'library("knitr");knitr::knit("README.Rmd")'
  
  git add README.md
  git commit -m "knit README [skip ci]"
  git push
}
knitreadme
