#!/bin/bash
echo "moving files...."
shopt -s nocasematch   # case-insensitive matching

INCOMING_DIR="incoming/fixed_income"
PROCESSING_DIR="processing/fixed_income"

TODAY_DASH=$(date +"%-m.%d.%y")
TODAY_UNDER=$(date +"%m_%d_%y")

mkdir -p "$PROCESSING_DIR"

find "$INCOMING_DIR" -type f \( -name "*$TODAY_DASH*.csv" -o -name "*$TODAY_DASH*.xlsx" \) |
while IFS= read -r FILE
do
    BASENAME=$(basename "$FILE")
    EXT="${BASENAME##*.}"

    PREFIX=""
    TYPE=""

    if [[ "$BASENAME" =~ SRTB ]]; then
        TYPE="SRTB"
        PREFIX=$(echo "$BASENAME" | sed 's/[[:space:]]SRTB.*//')

    elif [[ "$BASENAME" =~ TJM ]]; then
        TYPE="TJM"
        PREFIX=$(echo "$BASENAME" | sed 's/[[:space:]]TJM.*//')

    elif [[ "$BASENAME" =~ CITI[[:space:]]+EOD[[:space:]]+Blotter ]]; then
        TYPE="CITI_EOD_BLOTTER"

    elif [[ "$BASENAME" =~ CITI[[:space:]]+Daily[[:space:]]+Recap[[:space:]]+SRT ]]; then
        TYPE="CITI_DAILY_RECAP_SRT"

    elif [[ "$BASENAME" =~ Broker[[:space:]]+Trades[[:space:]]+recap ]]; then
        TYPE="BROKER_TRADES_RECAP"

    else
        echo "Skipping unknown file: $BASENAME"
        continue
    fi

    if [[ -n "$PREFIX" ]]; then
        NEW_NAME="${PREFIX}_${TYPE}_${TODAY_UNDER}.${EXT}"
    else
        NEW_NAME="${TYPE}_${TODAY_UNDER}.${EXT}"
    fi

    NEW_NAME=$(echo "$NEW_NAME" | tr ' ' '_')

    mv -n "$FILE" "$PROCESSING_DIR/$NEW_NAME"

    echo "Moved: $BASENAME → $NEW_NAME"
done
