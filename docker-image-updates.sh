#!/bin/sh
# Scan all docker image tags for updates.
# Send findings in email to root.

COUNT=0
IMAGE_LIST=

for img in $(docker images -f dangling=false | sed '1d' | awk '{ print $1 ":" $2 }'); do
	echo "Checking image: $img..."
	A=$(docker images -q $img)
	docker pull $img
	B=$(docker images -q $img)

	if [ "$A" != "$B" ]; then
		COUNT=$((COUNT+1))
		IMAGE_LIST="$IMAGE_LIST$img\n"
	fi

	echo
done

# Send email if updates were found.
if [ $COUNT -ne 0 ]; then
	SUBJECT="Docker image updates - $(hostname)"
	BODY="Docker image updates are available for $COUNT image(s):\n\n$IMAGE_LIST"
	echo $BODY | mail -s "$SUBJECT" root
fi
