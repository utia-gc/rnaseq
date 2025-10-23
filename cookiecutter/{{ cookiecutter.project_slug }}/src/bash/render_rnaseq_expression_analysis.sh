#!/usr/bin/env bash


################
# Configure
################
# quarto container in which `quarto render` is run
readonly quarto_image="oras://ghcr.io/trev-f/rstudio_4.5:v0.2.0"
# profile(s) to use for rendering the report
readonly quarto_profile="production"
# directory of quarto project or document to render
readonly quarto_input="src/quarto/rnaseq-expression-analysis"
# trackable resources
readonly time="00-04:00:00"
readonly cpu="8"
readonly mem="32GB"


################
# Main
################
# make sure packages are installed in the environment with renv
apptainer exec --cleanenv "${quarto_image}" Rscript -e 'renv::restore()'

# build quarto command to run using `apptainer exec`
readonly render_command="apptainer exec --cleanenv ${quarto_image} quarto render --profile ${quarto_profile} ${quarto_input}"

# run sbatch job if on ISAAC
if [[ -d "/lustre/isaac" ]]; then
    sbatch \
		--job-name="render-rnaseq-expression-analysis-report" \
		--verbose \
		--wait \
		--tres-per-task="cpu=${cpu}" \
		--mem="${mem}" \
		--time="${time}" \
		--wrap="${render_command}"
else
    eval "${render_command}"
fi

