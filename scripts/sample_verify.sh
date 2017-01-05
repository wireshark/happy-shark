#!/bin/bash

SAMPLE_DIR="$1"
shift
CHECKED_VERSIONS=$@

if [ $# -gt 1 ]; then
        ONE_VERSION=0
    else
        ONE_VERSION=1
fi

CHECK_ERROR=0

echo -n "Checking ${SAMPLE_DIR}: "
FILE=`basename "${SAMPLE_DIR}"`
if [ ! -f ""${SAMPLE_DIR}"/"${FILE}".pcap.gz" -a ! -f ""${SAMPLE_DIR}"/"${FILE}".pcapng.gz" ]; then
    echo -e "\n  PCAP sample is missing in ${SAMPLE_DIR} (${SAMPLE_DIR}/${FILE}.pcap.gz or ${SAMPLE_DIR}/${FILE}.pcapng.gz)"
    CHECK_ERROR=1
fi
if [ ! -f ""${SAMPLE_DIR}"/"${FILE}".description.txt" ]; then
    echo -e "\n  PCAP description is missing in ${SAMPLE_DIR} (${SAMPLE_DIR}/${FILE}.description.txt)"
    CHECK_ERROR=1
fi
if [ ! -f ""${SAMPLE_DIR}"/"${FILE}".requirements.txt" ]; then
    echo -e "\n  PCAP requirements are missing in ${SAMPLE_DIR} (${SAMPLE_DIR}/${FILE}.requirements.txt)"
    CHECK_ERROR=1
fi

# Check for TXT
FOUND=0
for v in ${CHECKED_VERSIONS}; do
    if [ -f ""${SAMPLE_DIR}"/${FILE}_${v}.text" ]; then
        FOUND=1
    fi
done
if [ ! -f ""${SAMPLE_DIR}"/"${FILE}".no_txt" -a $FOUND == 0 ]; then
    if [ "${ONE_VERSION}" == "1" ]; then
        echo -e "\n  TXT output ${SAMPLE_DIR}/${FILE}_${CHECKED_VERSIONS}.text is missing in ${SAMPLE_DIR}"
        CHECK_ERROR=1
    else
        echo -e "\n  TXT output ${SAMPLE_DIR}/${FILE}_<VERSION>.text for any version of ${CHECKED_VERSIONS} is missing in ${SAMPLE_DIR}"
        CHECK_ERROR=1
    fi
fi

# Check for PDML1
FOUND=0
for v in ${CHECKED_VERSIONS}; do
    if [ -f ""${SAMPLE_DIR}"/${FILE}_${v}.pdml1" ]; then
        FOUND=1
    fi
done
if [ ! -f ""${SAMPLE_DIR}"/"${FILE}".no_pdml1" -a $FOUND == 0 ]; then
    if [ "${ONE_VERSION}" == "1" ]; then
        echo -e "\n  PDML1 output ${SAMPLE_DIR}/${FILE}_${CHECKED_VERSIONS}.pdml1 is missing in ${SAMPLE_DIR}"
        CHECK_ERROR=1
    else
        echo -e "\n  PDML1 output ${SAMPLE_DIR}/${FILE}_<VERSION>.pdml1 for any version of ${CHECKED_VERSIONS} is missing in ${SAMPLE_DIR}"
        CHECK_ERROR=1
    fi
fi

# Check for PDML2
FOUND=0
for v in ${CHECKED_VERSIONS}; do
    if [ -f ""${SAMPLE_DIR}"/${FILE}_${v}.pdml2" ]; then
        FOUND=1
    fi
done
if [ ! -f ""${SAMPLE_DIR}"/"${FILE}".no_pdml2" -a $FOUND == 0 ]; then
    if [ "${ONE_VERSION}" == "1" ]; then
        echo -e "\n  PDML2 output ${SAMPLE_DIR}/${FILE}_${CHECKED_VERSIONS}.pdml2 is missing in ${SAMPLE_DIR}"
        CHECK_ERROR=1
    else
        echo -e "\n  PDML2 output ${SAMPLE_DIR}/${FILE}_<VERSION>.pdml2 for any version of ${CHECKED_VERSIONS} is missing in ${SAMPLE_DIR}"
        CHECK_ERROR=1
    fi
fi

if [ "${CHECK_ERROR}" == "1" ]; then
        echo -e "  Check failed"
    else
        echo -e "  Check OK"
fi
exit ${CHECK_ERROR}

#*
#* Editor modelines  -  http://www.wireshark.org/tools/modelines.html
#*
#* Local variables:
#* c-basic-offset: 4
#* tab-width: 4
#* indent-tabs-mode: nil
#* End:
#*
#* vi: set shiftwidth=4 tabstop=4 expandtab:
#* :indentSize=4:tabSize=4:noTabs=true:
#*
