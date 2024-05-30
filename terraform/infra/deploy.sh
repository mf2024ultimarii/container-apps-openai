#!/bin/bash

CMD="tofu"
# CMD="terraform"

# Terraform Init
${CMD} init

# Terraform validate
${CMD} validate -compact-warnings

# Terraform plan
${CMD} plan -compact-warnings

# Terraform apply
${CMD} apply -compact-warnings