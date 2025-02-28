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


.PHONY: all
all: setup process

.PHONY: setup
setup: $(samplesheet)
	@echo "Ran project setup"

$(samplesheet): .cache/nf_logs/setup.log
	@touch $(samplesheet)

.cache/nf_logs/setup.log: $(sample_decode) $(nf_setup_config) $(nf_setup_params) $(nf_setup_script)
	@echo "Run project setup pipeline"
	@sbatch --wait --verbose $(nf_setup_script)

.PHONY: process
process: $(counts)
	@echo "Ran data processing"

$(counts): .cache/nf_logs/rnaseq.log
	@touch $(counts)

.cache/nf_logs/rnaseq.log: $(samplesheet) $(nf_rnaseq_config) $(nf_rnaseq_params) $(nf_rnaseq_script)
	@echo "Run data processing pipeline"
	@sbatch --wait --verbose $(nf_rnaseq_script)
