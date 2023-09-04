#!/bin/bash

delayed_shutdown() {
    if [ $# -ne 1 ]; then
        echo "Usage: delayed_shutdown <minutes>"
        return 1
    fi

    minutes="$1"

    echo "Shutdown has been delayed for $minutes minutes. Please enter your password:"
    sudo -v && sleep "${minutes}m" && sudo shutdown now
}
