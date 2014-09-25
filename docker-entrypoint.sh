#!/bin/bash
set -e

# Configure exports.
if [ -n "${DATA_EXPORTS}" -a -n "${DATA_EXPORT_DIR}" ]; then
    su -c "docker-link-exports" shiny
fi

# Replace this shell with the supplied command (and any arguments).
exec $@
