#!/bin/bash

for FILE in /plugins/*.sh; do
    echo "Granting execution permission: $FILE"
    chmod +x "$FILE"
done

for FILE in /items/*.sh; do
    echo "Granting execution permission: $FILE"
    chmod +x "$FILE"
done
