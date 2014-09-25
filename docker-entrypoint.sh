#!/bin/bash
set -e

# Configure exports.
if [ -n "${DATA_EXPORTS}" -a -n "${DATA_EXPORT_DIR}" ]; then
    [ -d ${DATA_EXPORT_DIR} ] || (mkdir -p ${DATA_EXPORT_DIR} && chown shiny:shiny ${DATA_EXPORT_DIR})

    su -c "docker-link-exports" shiny
fi

# Replace this shell with the supplied command (and any arguments).
exec $@
