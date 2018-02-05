#!/bin/bash

# This script is invoked by the monitor whenever anything changes in the /watch directory

SRCDIR=/watch
DESTDIR=/output
PROCESSED_FILES=/config/processed_files.dat

# To get HANDBRAKE_COMMAND
. /config/HandBrake.conf

IFS=$(echo -en "\n\b")
for INPUT_FILE in $(cd "$SRCDIR" && find . -type f)
do
    # Hash the file details for some privacy. To uniquely identify the file, we hash the file name, size, and last
    # modification time.
    file_hash=$(stat -c '%n %s %Y' "$SRCDIR/$INPUT_FILE" | md5sum | awk '{print $1}')

    if grep -q "$file_hash" "$PROCESSED_FILES"; then
        echo "Skipping already-processed file $INPUT_FILE, hash $file_hash"
        continue
    fi

    SUBDIR=$(dirname "$INPUT_FILE")
    FILENAME=$(basename "$INPUT_FILE")
    EXTENSION=${FILENAME##*.}
    BASE=${FILENAME%.*}

    mkdir -p "$DESTDIR/$SUBDIR"

    eval $HANDBRAKE_COMMAND &

    PID=$!
    # This might fail if the user has not provided --cap-add=SYS_NICE to the container. So ignore failures here.
    renice 19 $PID
    wait $PID

    # Should we only remember the hash for the file if handbrake succeeded? If we do that, we'll keep trying to
    # convert the same file over and over. This way is simpler. If they want to re-encode, rename the file, or move
    # it out and back into the watch folder.
    echo $file_hash >> "$PROCESSED_FILES"
done
