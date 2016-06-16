happy-shark
===========
Happy Shark is the regression test framework for Wireshark consisting of a tool
and a collection of capture files.

Running tests
-------------
Simply invoke `make` or `make -j4` for more parallelism.

Adding a new test
-----------------
Create a new subdirectory under `tests/` with the following files:

 - FOO.pdml - the expected processed output (e.g. `dns.pcapng.pdml`).
 - FOO - the source capture file (e.g. `dns.pcapng`).
 - filter.xsl - the post-processor.

When proposing a new test, please include the source of the packet capture file
in the commit message. The source could be a link to https://bugs.wireshark.org/
or https://wiki.wireshark.org/SampleCaptures for example. Try to keep capture
files small and specific to a small number of protocols.

Architecture
------------
The initial desired features were:

 - Matching fields (the displayed text, byte offsets and length).
 - Take a packet capture file and produce the expected "output".
 - Have a filter that strips layers or just keeps a single layer.
 - Allow preferences to be applied (SSL keys, port numbers, ...).
 - Maybe check both single and second pass mode (tshark -2) to catch issues
   related to maintained state within a dissector.

License
-------
This project including the tools and capture files are provided under the terms
of version 2 of the GPL or any later version.
