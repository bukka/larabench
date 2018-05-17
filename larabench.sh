#!/bin/bash

function lb_transform_template {
    cp $1 $2
}

function lb_start_fpm {
    fpm_type=$1
    echo "Starting php-$fpm_type"
}

function lb_start_nginx {
    echo "Starting nginx"
}

function lb_start {
    if [ -z "$1" ]; then
        echo "No start application supplied"
        exit
    fi

    case "$1" in
        nginx)
            lb_start_nginx $@
            ;;
        fpm)
            lb_start_fpm $@
            ;;
        fpmi)
            lb_start_fpm $@
            ;;
        *)
            echo "Unknown start application $1"
            exit
            ;;
    esac
}

if [ -z "$1" ]; then
    echo "No action set"
    exit
fi

case "$1" in
    start)
        shift
        lb_start $@
        ;;
    *)
        echo "Unknown action $1"
        exit
        ;;
esac