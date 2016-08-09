#!/bin/bash
#
# Import script for zythum
# Load unpack and sort mods from import dir
#

IMPORTLOC=./import
IMPORTDIR=$1

rm -rf "$IMPORTLOC"
mkdir -p "$IMPORTLOC"
mkdir -p "$IMPORTLOC/__final"
mkdir -p "$IMPORTLOC/__trash"

if [[ "$1" == "rm" ]]; then
  rm -rf "$IMPORTLOC"
  exit 0
fi

if [[ -e "./info.json" ]]; then
  if [[ -d "$IMPORTDIR" ]]; then
    ls $IMPORTDIR | while read FILE; do
      echo "OK: Found mod $FILE"

      if [[ ! -d "$IMPORTDIR/$FILE" && "$FILE" =~ .*\.zip ]]; then
        unzip "$IMPORTDIR/$FILE" -d "$IMPORTLOC" > /dev/null 2>&1
        #rm "$IMPORTDIR/$FILE"
        echo "OK: Unzipped and moved mod $FILE"
      else
        mv "$IMPORTDIR/$FILE" "$IMPORTLOC"
        echo "OK: Moved mod $FILE"
      fi
    done

    ls $IMPORTLOC | while read FILE; do
      if [[ "$FILE" =~ \_\_final || "$FILE" =~ \_\_trash ]]; then
        continue
      fi

      echo "OK: Found imported mod $FILE"

      if [[ -d "$IMPORTLOC/$FILE" ]]; then
        NVFILE=$(echo $FILE| cut -d'_' -f 1)

        if [[ -d "$IMPORTLOC/$FILE/prototypes" ]]; then
          echo "OK: Loading prototypes for mod $NVFILE"
          cp -R "$IMPORTLOC/$FILE/prototypes" "$IMPORTLOC/__final/"
          mkdir -p "$IMPORTLOC/__final/__temp"

          ITERATOR=0
          find "$IMPORTLOC/__final/prototypes" -name \*.lua -print0 |
            while read -r -d $'\0' FILE; do
              cp "$FILE" "$IMPORTLOC/__final/__temp/$ITERATOR.lua"
              ITERATOR=$(($ITERATOR + 1))
            done

          mv "$IMPORTLOC/__final/__temp" "$IMPORTLOC/__final/$NVFILE"
          rm -r "$IMPORTLOC/__final/prototypes"
          rm -r "$IMPORTLOC/$FILE"
        else
          echo "ER: No prototypes found for mod $FILE"
          mv "$IMPORTLOC/$FILE" "$IMPORTLOC/__trash/"
        fi
      fi
    done

    ls "$IMPORTLOC/__final" | while read FILE; do
      lua ./script/templater.lua "$FILE"
    done
  else
    echo "ER: Import directory invalid!"
  fi
else
  echo "ER: Not running from project root!"
fi
