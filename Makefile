
# Test tshark's dissectors on small test files

.DEFAULT_GOAL := help
.SECONDEXPANSION:

# Set home dir to empty dir
ifneq ("$(wildcard /tmp)","")
  HOME=/tmp
 else
  HOME?=$(mktemp -d)
endif

# List all available test directories
TEST_CASE_DIRS=$(wildcard tests/*/*)

# Convert directories to test case names
TEST_CASES=$(foreach test,$(TEST_CASE_DIRS), $(test)/$(notdir $(test)))

# Convert directories to test case names with output dir
TEST_CASES_OUTPUT=$(foreach test,$(TEST_CASE_DIRS), $(test)/output/$(notdir $(test)))

# Editor backup files
EDITOR_BACKUP_FILES=$(wildcard *~) $(wildcard */*~) $(wildcard */*/*~) $(wildcard */*/*/*~) $(wildcard */*/*/*/*~)

# List of versions for which we check and store different outputs
# When output is verified, current wireshark version's output is compared to same version's stored output or to the latest previous version
# - list should be ordered from the oldest to the newest version
SUPPORTED_VERSIONS?=2.0 2.2 2.3 2.4 2.5
VERSION?=
SELECTED_VERSIONS=$(if $(VERSION),$(VERSION),$(SUPPORTED_VERSIONS))

TSHARK_EXECUTABLE?=tshark
TSHARK_VERSION=$(shell $(TSHARK_EXECUTABLE) --version | head -1 | cut -d' ' -f 3 | cut -d'.' -f1,2)

VERBOSE?=no
TEST_FAIL_ON_ERROR?=yes

%.pdml1.current: TESTDIR = $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $*))))
%.pdml1.current: TESTNAME = $(notdir $*)
%.pdml1.current: $$(dir $$(subst /output,,$$@))/filter.xsl $$(wildcard $$(dir $$(subst /output,,$$@))/*.pcap*.gz)
	@./scripts/sample_test.sh "$(TSHARK_EXECUTABLE)" "$(TESTDIR)/$(TESTNAME)" pdml1 $(VERBOSE) $(TEST_FAIL_ON_ERROR) $(SELECTED_VERSIONS)

%.pdml2.current: TESTDIR = $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $*))))
%.pdml2.current: TESTNAME = $(notdir $*)
%.pdml2.current: $$(dir $$(subst /output,,$$@))/filter.xsl $$(wildcard $$(dir $$(subst /output,,$$@))/*.pcap*.gz)
	@./scripts/sample_test.sh "$(TSHARK_EXECUTABLE)" "$(TESTDIR)/$(TESTNAME)" pdml2 $(VERBOSE) $(TEST_FAIL_ON_ERROR) $(SELECTED_VERSIONS)

%.text.current: TESTDIR = $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $*))))
%.text.current: TESTNAME = $(notdir $*)
%.text.current: $$(dir $$(subst /output,,$$@))/filter.xsl $$(wildcard $$(dir $$(subst /output,,$$@))/*.pcap*.gz)
	@./scripts/sample_test.sh "$(TSHARK_EXECUTABLE)" "$(TESTDIR)/$(TESTNAME)" text $(VERBOSE) $(TEST_FAIL_ON_ERROR) $(SELECTED_VERSIONS)

%.pdml1: TESTDIR = $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $*))))
%.pdml1: $$(dir $$(subst /output,,$$@))/filter.xsl $$(wildcard $$(dir $$(subst /output,,$$@))/*.pcap*.gz)
	@./scripts/sample_make_output.sh "$(TSHARK_EXECUTABLE)" "$(TESTDIR)" pdml1 $(VERBOSE)

%.pdml2: TESTDIR = $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $*))))
%.pdml2: $$(dir $$(subst /output,,$$@))/filter.xsl $$(wildcard $$(dir $$(subst /output,,$$@))/*.pcap*.gz)
	@./scripts/sample_make_output.sh "$(TSHARK_EXECUTABLE)" "$(TESTDIR)" pdml2 $(VERBOSE)

%.text: TESTDIR = $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $*))))
%.text: $$(dir $$(subst /output,,$$@))/filter.xsl $$(wildcard $$(dir $$(subst /output,,$$@))/*.pcap*.gz)
	@./scripts/sample_make_output.sh "$(TSHARK_EXECUTABLE)" "$(TESTDIR)" text $(VERBOSE)

tests_pdml1: $(foreach test, $(TEST_CASE_DIRS), $(test)/output/$(notdir $(test)).pdml1.current)

tests_pdml2: $(foreach test, $(TEST_CASE_DIRS), $(test)/output/$(notdir $(test)).pdml2.current)

tests_text: $(foreach test, $(TEST_CASE_DIRS), $(test)/output/$(notdir $(test)).text.current)

%/output: %/output/$$(notdir $$*).pdml1.current %/output/$$(notdir $$*).pdml2.current %/output/$$(notdir $$*).text.current
	@

tests: $(foreach test, $(TEST_CASE_DIRS), $(test)/output)

make_outputs_pdml1: $(foreach test_case, $(TEST_CASE_DIRS), $(test_case)/output/$(notdir $(test_case))_$(TSHARK_VERSION).pdml1)
	@

make_outputs_pdml2: $(foreach test_case, $(TEST_CASE_DIRS), $(test_case)/output/$(notdir $(test_case))_$(TSHARK_VERSION).pdml2)
	@

make_outputs_text: $(foreach test_case, $(TEST_CASE_DIRS), $(test_case)/output/$(notdir $(test_case))_$(TSHARK_VERSION).text)
	@

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

clean-backups: $(EDITOR_BACKUP_FILES)
	@rm -f $(EDITOR_BACKUP_FILES)

maintainer-clean: clean clean-backups

help:
	@echo "Usage:"
	@echo "make outputs            create missing output files (.test, .pdml1, .pdml2)"
	@echo "make verify_repository  verifies whether each test is equipped with required files"
	@echo "make tests              test each sample output with current wireshark"
	@echo "make all                do verify_repository outputs tests in row"
	@echo ""
	@echo "you can use variables:"
	@echo "TSHARK_EXECUTABLE=/path/to/tshark"
	@echo "VERSION=2.0"
	@echo "VERBOSE=yes"
	@echo "TEST_FAIL_ON_ERROR=no"
	@echo "e.g. make outputs TSHARK_EXECUTABLE=/path/to/tshark  creates outputs with specified tshark and with its version"
	@echo "e.g. make tests VERSION=2.0  test samples with current tshark, but compares its outputs with specified version"

all: verify_repository outputs tests

.PHONY: all maintainer-clean clean outputs verify_repository tests

