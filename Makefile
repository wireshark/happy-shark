
# Test tshark's dissectors on small test files

# List all available test directories
TEST_CASE_DIRS=$(wildcard tests/*/*)

# Convert directories to test case names
TEST_CASES=$(foreach test,$(TEST_CASE_DIRS), $(test)/$(notdir $(test)))

# Convert directories to test case names with output dir
TEST_CASES_OUTPUT=$(foreach test,$(TEST_CASE_DIRS), $(test)/output/$(notdir $(test)))

# List of versions for which we check and store different outputs
# When output is verified, current wireshark version's output is compared to same version's stored output or to the latest previous version
# - list should be ordered from the oldest to the newest version
SUPPORTED_VERSIONS?=2.0 2.2 2.3
VERSION?=
SELECTED_VERSIONS=$(if $(VERSION),$(VERSION),$(SUPPORTED_VERSIONS))

TSHARK_EXECUTABLE?=tshark
TSHARK_VERSION=$(shell $(TSHARK_EXECUTABLE) --version | head -1 | cut -d' ' -f 3 | cut -d'.' -f1,2)

VERBOSE?=no
TEST_FAIL_FIRST?=yes

%.pdml1.current:
	@./scripts/sample_test.sh "$(TSHARK_EXECUTABLE)" "$(basename $(basename $@))" pdml1 $(VERBOSE) $(TEST_FAIL_FIRST) $(SELECTED_VERSIONS)

%.pdml2.current:
	@./scripts/sample_test.sh "$(TSHARK_EXECUTABLE)" "$(basename $(basename $@))" pdml2 $(VERBOSE) $(TEST_FAIL_FIRST) $(SELECTED_VERSIONS)

%.text.current:
	@./scripts/sample_test.sh "$(TSHARK_EXECUTABLE)" "$(basename $(basename $@))" text $(VERBOSE) $(TEST_FAIL_FIRST) $(SELECTED_VERSIONS)

all:
	@echo "Usage:"
	@echo "make outputs            create missing output files (.test, .pdml1, .pdml2)"
	@echo "make verify_repository  verifies whether each test is equipped with required files"
	@echo "make test               test each sample output with current wireshark"
	@echo ""
	@echo "you can use variables:"
	@echo "TSHARK_EXECUTABLE=/path/to/tshark"
	@echo "VERSION=2.0"
	@echo "VERBOSE=yes"
	@echo "TEST_FAIL_FIRST=no"
	@echo "e.g. make outputs TSHARK_EXECUTABLE=/path/to/tshark  creates outputs with specified tshark and with its version"
	@echo "e.g. make test VERSION=2.0  test samples with current tshark, but compares its outputs with specified version"

test_pdml1: $(foreach test, $(TEST_CASE_DIRS), $(test)/$(notdir $(test)).pdml1.current)

test_pdml2: $(foreach test, $(TEST_CASE_DIRS), $(test)/$(notdir $(test)).pdml2.current)

test_text: $(foreach test, $(TEST_CASE_DIRS), $(test)/$(notdir $(test)).text.current)

test: test_pdml1 test_pdml2 test_text

make_outputs_pdml1:
	@$(foreach test_case, $(TEST_CASE_DIRS), ./scripts/sample_make_output.sh "$(TSHARK_EXECUTABLE)" "$(test_case)" pdml1 $(VERBOSE);)

make_outputs_pdml2:
	@$(foreach test_case, $(TEST_CASE_DIRS), ./scripts/sample_make_output.sh "$(TSHARK_EXECUTABLE)" "$(test_case)" pdml2 $(VERBOSE);)

make_outputs_text:
	@$(foreach test_case, $(TEST_CASE_DIRS), ./scripts/sample_make_output.sh "$(TSHARK_EXECUTABLE)" "$(test_case)" text $(VERBOSE);)

outputs: make_outputs_pdml1 make_outputs_pdml2 make_outputs_text

verify_repository:
	@$(foreach test_case, $(TEST_CASE_DIRS), ./scripts/sample_verify.sh "$(test_case)" $(VERBOSE) $(SELECTED_VERSIONS);)

clean:
	@rm -f $(TEST_CASES_OUTPUT:=.pdml1.current)
	@rm -f $(TEST_CASES_OUTPUT:=.pdml1.current.tmp)
	@rm -f $(TEST_CASES_OUTPUT:=.pdml1.current.tmp2)
	@rm -f $(TEST_CASES_OUTPUT:=.pdml2.current)
	@rm -f $(TEST_CASES_OUTPUT:=.pdml2.current.tmp)
	@rm -f $(TEST_CASES_OUTPUT:=.pdml2.current.tmp2)
	@rm -f $(TEST_CASES_OUTPUT:=.text.current)
	@rm -f $(TEST_CASES_OUTPUT:=.text.current.tmp)
	@rm -f $(TEST_CASES_OUTPUT:=.text.current.tmp2)

#.PHONY: clean

