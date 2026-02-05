#!/bin/sh

echo "moving files"

INCOMING_DIR="/var/tmp/etl/1k37367/incoming/fixed_income"
PROCESSING_DIR="/var/tmp/etl/1k37367/processing/fixed_income"

# Date formats
TODAY_DASH=$(date "+%m.%d.%y")     # 02.04.26
TODAY_UNDER=$(date "+%m_%d_%y")    # 02_04_26

# Ensure processing directory exists
mkdir -p "$PROCESSING_DIR"

# Find and process files
find "$INCOMING_DIR" -type f -name "*$TODAY_DASH*.csv" | while IFS= read FILE
do
    BASENAME=$(basename "$FILE")

    TYPE=""

    case "$BASENAME" in
        *" SRIB "*)
            TYPE="SRIB"
            ;;
        *" TJM "*)
            TYPE="TJM"
            ;;
        *)
            echo "Skipping unknown file: $BASENAME"
            continue
            ;;
    esac

    # Extract prefix (everything before TYPE)
    PREFIX=$(echo "$BASENAME" | sed "s/ $TYPE.*//")

    # Build new filename
    NEW_NAME="${PREFIX}_${TYPE}_${TODAY_UNDER}.csv"
    NEW_NAME=$(echo "$NEW_NAME" | tr ' ' '_')

    echo "Moving: $FILE -> $PROCESSING_DIR/$NEW_NAME"

    mv "$FILE" "$PROCESSING_DIR/$NEW_NAME"
done
