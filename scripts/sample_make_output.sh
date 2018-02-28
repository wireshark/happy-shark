#!/bin/bash

TSHARK_EXECUTABLE="$1"
SAMPLE_DIR="$2"
TYPE="$3"
VERBOSE="$4"
REQ_VERSION="$5"

OUTPUT=""

echo_history () {
  echo -ne "${OUTPUT} $*"
  OUTPUT=""
}

echo_verbose () {
  if [ "${VERBOSE}" == "yes" ]; then
    echo -ne "$*"
   else
    OUTPUT="${OUTPUT} $*"
  fi
}

${TSHARK_EXECUTABLE} --version > /dev/null 2> /dev/null
if [ "$?" != "0" ]; then
    echo_history "Executable for tshark doesn't exists (${TSHARK_EXECUTABLE})\n"
    exit 0
fi

echo_verbose "Creating output '${TYPE}' for ${SAMPLE_DIR}:\n"
FILE=`basename "${SAMPLE_DIR}"`

TSHARK_VERSION=`${TSHARK_EXECUTABLE} --version | head -1 | cut -d' ' -f 3 | cut -d'.' -f1,2`
if [ -n "${REQ_VERSION}" ]; then
    if [ "${REQ_VERSION}" != "${TSHARK_VERSION}" ]; then
        echo_history "  FAILED, required tshark version do not match running version\n"
        exit 1
    fi
fi

cd "${SAMPLE_DIR}"

if [ -f "${FILE}.pcap.gz" ]; then
        FILE_PCAP="${FILE}.pcap.gz"
elif [ -f "${FILE}.pcapng.gz" ]; then
        FILE_PCAP="${FILE}.pcapng.gz"
else
    echo_history "  No sample for ${SAMPLE_DIR}\n"
    exit 0
fi

TSHARK_ARGS=
if [ -r "${FILE}.args" ]; then
    TSHARK_ARGS=`cat "${FILE}.args"`
fi

OUTPUT_FILE="output/${FILE}_${TSHARK_VERSION}.${TYPE}"

XTYPE=${TYPE}
XARGS=
if [ "${TYPE}" == "pdml1" ]; then
    XTYPE=pdml
    XARGS=
elif [ "${TYPE}" == "pdml2" ]; then
    XTYPE=pdml
    XARGS=-2
fi

"${TSHARK_EXECUTABLE}" $TSHARK_ARGS -T ${XTYPE} ${XARGS} -r "${FILE_PCAP}" > "${OUTPUT_FILE}".tmp
if [ "$?" -eq "0" ]; then
    if [ "${XTYPE}" == "pdml" ]; then
        mv -f "${OUTPUT_FILE}.tmp" "${OUTPUT_FILE}.tmp2"
        xsltproc filter.xsl "${OUTPUT_FILE}.tmp2" > "${OUTPUT_FILE}.tmp"
        if [ "$?" -ne "0" ]; then
            rm -f "${OUTPUT_FILE}.tmp"
            rm -f "${OUTPUT_FILE}.tmp2"
            echo_history "  FAILED, file ${SAMPLE_DIR}/${OUTPUT_FILE}\n"
            exit 1
        fi
        rm -f "${OUTPUT_FILE}.tmp2"
    fi
    mv "${OUTPUT_FILE}.tmp" "${OUTPUT_FILE}"
    echo_history "  OK, file ${SAMPLE_DIR}/${OUTPUT_FILE}\n"
    exit 0
else
    rm -f "${OUTPUT_FILE}.tmp"
    echo_history "  FAILED, file ${SAMPLE_DIR}/${OUTPUT_FILE}\n"
    exit 1
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
