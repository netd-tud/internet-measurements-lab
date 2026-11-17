#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_NAME = internet-measurement-lab
PYTHON_VERSION = 3.14
PYTHON_INTERPRETER = python

#################################################################################
# COMMANDS                                                                      #
#################################################################################


## Install Python dependencies
.PHONY: requirements
requirements:
	uv pip install -r requirements.txt
	



## Delete all compiled Python files
.PHONY: clean
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete


## Lint using flake8, black, and isort (use `make format` to do formatting)
.PHONY: lint
lint:
	flake8 internet_measurement_lab
	isort --check --diff internet_measurement_lab
	black --check internet_measurement_lab

## Format source code with black
.PHONY: format
format:
	isort internet_measurement_lab
	black internet_measurement_lab





## Set up Python interpreter environment
.PHONY: create_environment
create_environment:
	uv venv --python $(PYTHON_VERSION)
	@echo ">>> New uv virtual environment created. Activate with:"
	@echo ">>> Windows: .\\\\.venv\\\\Scripts\\\\activate"
	@echo ">>> Unix/macOS: source ./.venv/bin/activate"
	



#################################################################################
# PROJECT RULES                                                                 #
#################################################################################


S3_BASE_URL = https://s3.zih.tu-dresden.de/netds3o:public-teaching-internet-measurements/2026

DATA_01 = \
	data/raw/01/2026-01-01-tud-ribs.csv.zst \
	data/raw/01/2026-01-01T00_00_00Z-ribs.csv.zst

DATA_02 = \
	data/raw/02/ribs.ris.2011-08-01.csv.zst \
	data/raw/02/ribs.ris.2019-01-31.csv.zst

## Download raw datasets (data/raw/01 and data/raw/02)
.PHONY: data
data: $(DATA_01) $(DATA_02)

data/raw/01/%:
	@mkdir -p $(@D)
	curl -fL --retry 3 -C - -o $@.part $(S3_BASE_URL)/01/$* && mv $@.part $@

data/raw/02/%:
	@mkdir -p $(@D)
	curl -fL --retry 3 -C - -o $@.part $(S3_BASE_URL)/02/$* && mv $@.part $@


#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys; \
lines = '\n'.join([line for line in sys.stdin]); \
matches = re.findall(r'\n## (.*)\n[\s\S]+?\n([a-zA-Z_-]+):', lines); \
print('Available rules:\n'); \
print('\n'.join(['{:25}{}'.format(*reversed(match)) for match in matches]))
endef
export PRINT_HELP_PYSCRIPT

help:
	@$(PYTHON_INTERPRETER) -c "${PRINT_HELP_PYSCRIPT}" < $(MAKEFILE_LIST)
