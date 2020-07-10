# Name: description.mk
# Author: Lucas Schneider
# 07/2020

# Name of all components in priority order
CPNT_LIST := turbo

# Name of the component to be tested
CPNT ?= turbo

# Commands to prepare test files
PREPARE_TEST := python EP3/turbo_tb.py > EP3/turbo_tb.dat