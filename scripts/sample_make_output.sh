#!/bin/bash

TSHARK_EXECUTABLE="$1"
SAMPLE_DIR="$2"
TYPE="$3"
REQ_VERSION="$4"

${TSHARK_EXECUTABLE} --version > /dev/null 2> /dev/null
if [ "$?" != "0" ]; then
    echo "Executable for tshark doesn't exists (${TSHARK_EXECUTABLE})"
    exit 0
fi

echo "Creating output '${TYPE}' for ${SAMPLE_DIR}:"
FILE=`basename "${SAMPLE_DIR}"`

TSHARK_VERSION=`${TSHARK_EXECUTABLE} --version | head -1 | cut -d' ' -f 3 | cut -d'.' -f1,2`
if [ -n "${REQ_VERSION}" ]; then
    if [ "${REQ_VERSION}" != "${TSHARK_VERSION}" ]; then
        echo "  FAILED, required tshark version do not match running version"
        exit 1
    fi
fi

cd "${SAMPLE_DIR}"

if [ -f "${FILE}.pcap.gz" ]; then
        FILE_PCAP="${FILE}.pcap.gz"
elif [ -f "${FILE}.pcapng.gz" ]; then
        FILE_PCAP="${FILE}.pcapng.gz"
else
    echo "  No sample for ${SAMPLE_DIR}"
    exit 0
fi

TSHARK_ARGS=
if [ -r "${FILE}.args" ]; then
    TSHARK_ARGS=`cat "${FILE}.args"`
fi

OUTPUT_FILE="${FILE}_${TSHARK_VERSION}.${TYPE}"

XTYPE=${TYPE}
XARGS=
if [ "${TYPE}" == "pdml1" ]; then
    XTYPE=pdml
    XARGS=
elif [ "${TYPE}" == "pdml2" ]; then
    XTYPE=pdml
    XARGS=-2
fi

if [ ! -f "${OUTPUT_FILE}" -o ${FILE_PCAP} -nt ${OUTPUT_FILE} ]; then
    "${TSHARK_EXECUTABLE}" $TSHARK_ARGS -T ${XTYPE} ${XARGS} -r "${FILE_PCAP}" > "${OUTPUT_FILE}".tmp
    if [ "$?" -eq "0" ]; then
        if [ "${XTYPE}" == "pdml" ]; then
            mv -f "${OUTPUT_FILE}.tmp" "${OUTPUT_FILE}.tmp2"
            xsltproc filter.xsl "${OUTPUT_FILE}.tmp2" > "${OUTPUT_FILE}.tmp"
            if [ "$?" -ne "0" ]; then
                rm -f "${OUTPUT_FILE}.tmp"
                rm -f "${OUTPUT_FILE}.tmp2"
                echo "  FAILED, file ${SAMPLE_DIR}/${OUTPUT_FILE}"
                exit 1
            fi
            rm -f "${OUTPUT_FILE}.tmp2"
        fi
        mv "${OUTPUT_FILE}.tmp" "${OUTPUT_FILE}"
        echo "  OK, file ${SAMPLE_DIR}/${OUTPUT_FILE}"
        exit 0
    else
        rm -f "${OUTPUT_FILE}.tmp"
        echo "  FAILED, file ${SAMPLE_DIR}/${OUTPUT_FILE}"
        exit 1
    fi
else
    echo "  SKIPPED, already exists and is up to date (${SAMPLE_DIR}/${OUTPUT_FILE})"
    exit 0
fi

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
