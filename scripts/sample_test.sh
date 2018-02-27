#!/bin/bash

TSHARK_EXECUTABLE="$1"
FILE="$2"
TYPE="$3"
VERBOSE="$4"
TEST_FAIL_FIRST="$5"
shift
shift
shift

exit_fail () {
  if [ "${TEST_FAIL_FIRST}" == "yes" ]; then
    exit $1
   else
    exit 0
  fi
}

${TSHARK_EXECUTABLE} --version > /dev/null 2> /dev/null
if [ "$?" != "0" ]; then
    echo "Executable for tshark doesn't exists (${TSHARK_EXECUTABLE})"
    exit 0
fi

DIR=`dirname "${FILE}"`
FILENAME=`basename "${FILE}"`
OUTFILE=${DIR}/output/${FILENAME}

echo -n "Processing ${FILE}.${TYPE}: "

TSHARK_VERSION=`${TSHARK_EXECUTABLE} --version | head -1 | cut -d' ' -f 3 | cut -d'.' -f1,2`
if [ -n "${REQ_VERSION}" ]; then
    if [ "${REQ_VERSION}" != "${TSHARK_VERSION}" ]; then
        echo "  FAILED, required tshark version do not match running version"
        exit 1
    fi
fi

if [ -f "${FILE}.pcap.gz" ]; then
        FILE_PCAP="${FILE}.pcap.gz"
elif [ -f "${FILE}.pcapng.gz" ]; then
        FILE_PCAP="${FILE}.pcapng.gz"
else
    echo "  No sample for ${FILE}"
    exit_fail 0
fi

TSHARK_ARGS=
if [ -r "${FILE}.args" ]; then
    TSHARK_ARGS=`cat "${FILE}.args"`
fi

OUTPUT_FILE="${OUTFILE}.${TYPE}.current"

LAST_VER=
for x in $@; do
    if [ -f "${OUTFILE}_${x}.${TYPE}" ]; then
        LAST_VER=$x
    fi
    if [ "${x}" == "${TSHARK_VERSION}" ]; then
        break
    fi
done

BASE_FILE="${OUTFILE}_${LAST_VER}.${TYPE}"

if [ ! -f "${BASE_FILE}" ]; then
    echo "  No stored output up to version ${TSHARK_VERSION}."
fi

XTYPE=${TYPE}
XARGS=
if [ "${TYPE}" == "pdml1" ]; then
    XTYPE=pdml
    XARGS=
elif [ "${TYPE}" == "pdml2" ]; then
    XTYPE=pdml
    XARGS=-2
fi
"${TSHARK_EXECUTABLE}" $TSHARK_ARGS -T ${XTYPE} ${XARGS} -r "${FILE_PCAP}" 1> "${OUTPUT_FILE}".tmp2 2>&1
if [ "$?" -eq "0" ]; then
    if [ "${XTYPE}" == "pdml" ]; then
        xsltproc "${DIR}"/filter.xsl "${OUTPUT_FILE}.tmp2" > "${OUTPUT_FILE}.tmp"
        if [ "$?" -ne "0" ]; then
            echo "  FAILED (${LAST_VER}/${TSHARK_VERSION})"
            exit_fail 1
        fi

        if [ "${VERBOSE}" == "yes" ]; then
          diff "${BASE_FILE}" "${OUTPUT_FILE}.tmp"
         else
          diff -q "${BASE_FILE}" "${OUTPUT_FILE}.tmp"
        fi
        if [ "$?" -ne "0" ]; then
            echo "  FAILED (${LAST_VER}/${TSHARK_VERSION})"
            exit_fail 1
        fi
    else
        mv "${OUTPUT_FILE}.tmp2" "${OUTPUT_FILE}.tmp"
    fi

    if [ "${VERBOSE}" == "yes" ]; then
      diff "${BASE_FILE}" "${OUTPUT_FILE}.tmp"
     else
      diff -q "${BASE_FILE}" "${OUTPUT_FILE}.tmp"
    fi
    if [ "$?" -ne "0" ]; then
        echo "  FAILED (${LAST_VER}/${TSHARK_VERSION})"
        exit_fail 1
    fi

    rm -f "${OUTPUT_FILE}.tmp2"
    mv "${OUTPUT_FILE}.tmp" "${OUTPUT_FILE}"
    echo "  OK (${LAST_VER}/${TSHARK_VERSION})"
    exit_fail 0
else
    echo "  FAILED (${LAST_VER}/${TSHARK_VERSION})"
    exit_fail 1
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
