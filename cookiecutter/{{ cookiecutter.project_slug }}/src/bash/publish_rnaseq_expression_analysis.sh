#!/usr/bin/env bash


################
# Configure
################
# quarto container in which `quarto render` is run
readonly quarto_image="oras://ghcr.io/trev-f/rstudio_4.5:v0.2.0"


################
# Main
################
# publishing to GitHub pages requires that a remote branch named 'gh-pages' exists for the repository
# see: https://quarto.org/docs/publishing/github-pages.html#source-branch
# do not run if 'gh-pages' branch does not exist in remote repo
echo "Check that 'gh-pages' branch exists in remote repo"
git ls-remote --exit-code --heads origin gh-pages
if [[ $? -ne 0]]; then
    echo "Error: 'gh-pages' branch not found in remote repository"
    exit 1
fi

# no heavy computation is performed, so don't use sbatch
apptainer exec --cleanenv "${quarto_image}" quarto publish gh-pages \
    --no-browser \
    --no-prompt \
    --no-render \
    --profile production \
    src/quarto/rnaseq-expression-analysis

