happy-shark
===========
Happy Shark is the regression test framework for Wireshark consisting of a tool
and a collection of capture files.

Running tests
-------------
Simply invoke `make test` or `make test -j4` for more parallelism.

Adding a new test
-----------------
Create a new subdirectory under `tests/<protocol>/`. <protocol> is name of protocol
subjected to test (e.g. 'dns' or 'rtp.ed137a'). Use same name as display filter in wireshark.
Directory populate with the following files:

 - FOO.pcap.gz or FOO.pcapng.gz - the source file (noncompressed files shall not be used, e.g. 'dns-1.pcapng.gz')
 - FOO.description - description of purpose the file is included (e.g. basic DNS query, RTP header with ED-137A header extension, packet missing in sequence)
 - FOO.requirements - requirements, how tshark/wireshark should process the file (e.g. packet should be decoded by specification of ED-137B, PTT and SQL bits should be shown in packet info column). Requirements can describe non dissector related staff too (e.g. RTP Stream Analysis window should show warning about bad packet sequence, warning should be shown in yellow color).
 - FOO.args - optional file, contains options for tshark to process file as expected (e.g. 'decode as' parameters)
 - FOO_<version>.pdml1 - the expected processed output from <version> of tshark in PDML format for first pass (e.g. `dns-1_2.0.pcapng.pdml1`). Only first two levels of version number are used.
 - FOO_<version>.pdml2 - the expected processed output from <version> of tshark in PDML format for second pass (e.g. `dns-1_2.0.pcapng.pdml1`). Only first two levels of version number are used.
 - FOO_<version>.text - the expected processed output from <version> of tshark in TEXT format (e.g. `dns-1_2.0.pcapng.text`). Only first two levels of version number are used.
 - FOO.no_pdml - optional file expressing that PDML output should not be checked (requirements probably describe GUI related requiremens only)
 - FOO.no_text - optional file expressing that TEXT output should not be checked (requirements probably describe GUI related requiremens only)
 - filter.xsl - the post-processor.

Run make outputs to generate .pdml and .text and make verify_repository to check all required files before commit.

When proposing a new test, please include the source of the packet capture file
in the commit message. The source could be a link to https://bugs.wireshark.org/
or https://wiki.wireshark.org/SampleCaptures for example. Try to keep capture
files small and specific to a small number of protocols.

Options and variables to run framework
--------------------------------------

SUPPORTED_VERSIONS - list of versions checked during make or make outputs, when not specified, default in Makefile is used
VERSION - version used for make or make outputs, when not specified, tshark version is used
TSHARK_EXECUTABLE - path to tshark, when not specified, tshark in PATH is used

make test - run tests, compare output of latest stored .pdml and .text
make VERSION=2.0 test - same as above, compare output with version 2.0 or previous
make test_pdml or make test_text - run tests for PDML or TEXT output only
make verify_repository - check whether each sample contains required files for at least one of checked versions
make verify_repository VERSION=2.0 - same above, check is made for specified version only
make outputs - generate .pdml and .text output for samples where files are missing, version is derived from version of used tshark
make outputs TSHARK_EXECUTABLE=path/tshark - same as above, but you can determine used tshark
make clean - removes temporary files after make test

Architecture
------------
The initial desired features were:

 - Matching fields (the displayed text, byte offsets and length).
 - Take a packet capture file and produce the expected "output".
 - Have a filter that strips layers or just keeps a single layer.
 - Allow preferences to be applied (SSL keys, port numbers, ...).
 - Check both single and second pass mode (tshark -2) to catch issues
   related to maintained state within a dissector.

License
-------
This project including the tools and capture files are provided under the terms
of version 2 of the GPL or any later version.

