
# Test tshark's dissectors on small test files

TEST_CASES = $(wildcard tests/*/*.pdml)

TSHARK_EXECUTABLE?=tshark

check_output = @(echo -n "Processing $(notdir $1)" && cd $(dir $1) && \
		$(TSHARK_EXECUTABLE) -T pdml -r $(subst .pdml,,$(notdir $1)) > $(notdir $2) 2>&1 && \
		xsltproc filter.xsl $(notdir $2)  | diff $(notdir $1) - ) && echo " [OK]"

all: test

%.pdml.current: %.pdml %
	$(call check_output, $<, $@)

test: $(TEST_CASES:.pdml=.pdml.current)

clean:
	@rm -f $(TEST_CASES:.pdml=.pdml.current)

.PHONY: clean
