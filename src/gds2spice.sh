#!/usr/bin/env bash
set -e

show_help() {
    echo "Usage: $(basename "$0") <design_name.gds> [schematic.spice]"
    echo ""
    echo "Arguments:"
    echo "  <design_name.gds>   Input GDSII layout file (Required)"
    echo "  [schematic.spice]   Reference SPICE file to align subckt pin order (Optional)"
    exit 0
}

if [ "$#" -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
fi

INPUT_GDS="$(realpath "$1")"
BASE_NAME="$(basename "$INPUT_GDS" .gds)"
OUTPUT_SPICE="$(pwd)/${BASE_NAME}_magic.spice"
PDK_MAGICRC="/usr/local/share/pdk/sky130A/libs.tech/magic/sky130A.magicrc"

if [ ! -f "$INPUT_GDS" ]; then
    echo "Error: GDS file not found: $1" >&2
    exit 1
fi

SCHEM_SPICE=""
if [ -n "$2" ]; then
    SCHEM_SPICE="$(realpath "$2")"
    if [ ! -f "$SCHEM_SPICE" ]; then
        echo "Error: SPICE file not found: $2" >&2
        exit 1
    fi
fi

magic -dnull -noconsole -rcfile "$PDK_MAGICRC" << EOF
gds read $INPUT_GDS
load $BASE_NAME
select top cell
flatten ${BASE_NAME}_flat
load ${BASE_NAME}_flat
select top cell
extract do local
extract all
ext2spice lvs
ext2spice format ngspice
ext2spice -o $OUTPUT_SPICE
quit
EOF

rm -f "${BASE_NAME}_flat.ext"
sed -i "s/${BASE_NAME}_flat/${BASE_NAME}/g" "$OUTPUT_SPICE"
sed -i -E 's/^X([0-9a-zA-Z_]+)(.*sky130_fd_pr__[np]fet)/M\1\2/g' "$OUTPUT_SPICE"

if [ -n "$SCHEM_SPICE" ]; then
    HEADER=$(grep -i "^[.]subckt[[:space:]]\+${BASE_NAME}[[:space:]]" "$SCHEM_SPICE" | head -n 1)
    if [ -n "$HEADER" ]; then
        sed -i "s/^[.]subckt[[:space:]]\+${BASE_NAME}[[:space:]].*/$HEADER/I" "$OUTPUT_SPICE"
        echo "Aligned port header to: $HEADER"
    fi
fi

echo "Generated: $OUTPUT_SPICE"