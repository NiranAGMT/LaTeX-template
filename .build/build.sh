#!/usr/bin/env bash
set -e

MAKE=$(command -v make)

CONF=config/1_novathesis.tex

# Select options for showcase PDF: final phd document form FCT-NOVA, with final index (_índice remissivo_) and trimed book spine
sed -i'.OLD' -e 's,.*\\ntsetup{doctype=.*},\\ntsetup{doctype=phd},' \
            -e 's,.*\\ntsetup{school=.*},\\ntsetup{school=nova/fct},' \
            -e 's,.*\\ntsetup{docstatus=.*},\\ntsetup{docstatus=final},' \
            -e 's,.*\\ntsetup{spine=.*},\\ntsetup{spine=trim},' \
            -e 's,.*\\ntsetup{print/index=.*},\\ntsetup{print/index=true},' \
            $CONF

# Build the PDF.
$MAKE

# Restore defaults
mv -f ${CONF}.OLD ${CONF}
