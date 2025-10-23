# Project setup
## Setup pipeline files
nf_setup_config := config/nextflow/setup.config
nf_setup_params := config/nextflow/params_setup.yaml
nf_setup_script := src/sbatch/nf_run_setup.sh
## Setup input file(s)
sample_decode := config/samplesheets/sample-name-decode.csv
## Setup output samplesheet
samplesheet := config/samplesheets/samplesheet.csv
# Process data
## Data processing pipeline files
nf_rnaseq_config := config/nextflow/rnaseq.config
nf_rnaseq_params := config/nextflow/params_rnaseq.yaml
nf_rnaseq_script := src/sbatch/nf_run_rnaseq.sh
## RNA-seq pipeline output counts files
counts := data/counts/{{ cookiecutter.project_slug }}_counts.csv
# RNA-seq expression analysis report files
## path(s) to file(s) that contain sample (meta)data used in the RNA-seq expression analysis
samples_data :=
## source files for the RNA-seq expression analysis
rnaseq_report_sources := $(wildcard \
	src/quarto/rnaseq-expression-analysis/*.yml \
	src/quarto/rnaseq-expression-analysis/*.qmd \
	src/quarto/rnaseq-expression-analysis/references* \
)
rnaseq_report_sentinel := reports/rnaseq-expression-analysis/references/references.html


.PHONY: all
all: setup process analyze

.PHONY: setup
setup: $(samplesheet)
	@echo "Finished project setup"

$(samplesheet): .cache/nf_logs/setup.log
	@touch $(samplesheet)

.cache/nf_logs/setup.log: $(sample_decode) $(nf_setup_config) $(nf_setup_params) $(nf_setup_script)
	@echo "Run project setup pipeline"
	@sbatch --wait --verbose $(nf_setup_script)

.PHONY: process
process: $(counts)
	@echo "Finished data processing"

$(counts): .cache/nf_logs/rnaseq.log
	@touch $(counts)

.cache/nf_logs/rnaseq.log: $(samplesheet) $(nf_rnaseq_config) $(nf_rnaseq_params) $(nf_rnaseq_script)
	@echo "Run data processing pipeline"
	@sbatch --wait --verbose $(nf_rnaseq_script)

.PHONY: analyze
analyze: $(rnaseq_report_sentinel)
	@echo "Finished RNA-seq expression analysis."

$(rnaseq_report_sentinel): src/bash/render_rnaseq_expression_analysis.sh $(counts) $(samples_data) $(rnaseq_report_source)
	@echo "Render RNA-seq expression analysis report."
	@bash src/bash/render_rnaseq_expression_analysis.sh

.PHONY: publish
publish: .cache/quarto-publish/.sentinel
	@echo "Finished publishing."

.cache/quarto-publish/.sentinel: src/bash/publish_rnaseq_expression_analysis.sh $(rnaseq_report_sentinel)
	@echo "Publish quarto report to gh-pages"
	@mkdir -p $(@D)
	@src/bash/publish_rnaseq_expression_analysis.sh 2>&1 | tee $@

