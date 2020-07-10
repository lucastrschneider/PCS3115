# Name: description.mk
# Author: Lucas Schneider
# 07/2020

# Name of all components in priority order
CPNT_LIST := littlesort_fd littlesort_uc ram16x4 littlesort

# Name of the component to be tested
CPNT ?= littlesort

# Commands to prepare test files
PREPARE_TEST :=