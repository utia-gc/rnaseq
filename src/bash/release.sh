#!/usr/bin/env bash
#
# release.sh
# This script prepares for release.

################
# Configure
################
# revision
readonly revision="${1}"


################
# Main
################
# change main to release version
sed -i -E "s/(-revision )main/\1$revision/" README.md 
sed -i -E "s/(revision: )main/\1$revision/" mkdocs.yml
sed -i -E "s/(version[[:space:]]+= )'main'/\1'$revision'/" nextflow.config
sed -i -E "s/(\"pipeline_revision\": )\[/\1\[\"$revision\", /" cookiecutter/cookiecutter.json

# make git commit
git add README.md mkdocs.yml nextflow.config cookiecutter/cookiecutter.json
git commit -m "chore(release): ${revision}"
git tag -a "${revision}" -m "tag: ${revision}"

# change release version back to main
sed -i -E "s/(-revision )$revision/\1main/" README.md 
sed -i -E "s/(revision: )$revision/\1main/" mkdocs.yml
sed -i -E "s/(version[[:space:]]+= )'$revision'/\1'main'/" nextflow.config
