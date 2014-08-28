#!/bin/bash
set -e

# Configure exports.
if [ -n "${DATA_EXPORTS}" -a -n "${DATA_EXPORT_DIR}" ]; then
    docker-link-exports
fi

# Replace this shell with the supplied command (and any arguments).
exec $@
