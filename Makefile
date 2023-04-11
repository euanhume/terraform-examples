# Define targets
.PHONY: test
test: 
	terraform validate

.PHONY: lint
lint: 
	tflint --chdir=$(shell pwd)

.PHONY: format
format: 
	terraform fmt -recursive