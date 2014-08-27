#!/bin/bash
set -e

# Configure exports. If an exported directory doesn't yet exist on
# /export, move the container's data over before symlinking the export
# into place. DOCKER_EXPORT is set in the Dockerfile or at runtime.
set -u
for dir in ${DOCKER_EXPORT}; do
    # If the directory doesn't exist in /export, copy it over.
    if [ ! -d /export${dir} ]; then
        echo -n "Migrating ${dir} to /export$dir... "
        EXPORT_BASE="/export$(dirname ${dir})"
        # Since most of this will be many small text files, compress
        # and stream the data (instead of mv) in case /export is
        # actually mounted over a network.
        tar cpz -C / ${dir} 2> /dev/null | tar xpzf - -C /export
        echo "done."
    fi
    # Unlink the container directory and symlink the exported one in.
    echo -n "Symlinking /export$dir into place... "
    rm -rf ${dir}
    ln -s /export${dir} ${dir}
    echo "done."
done
set +u

# Replace this shell with the supplied command (and any arguments).
exec $@