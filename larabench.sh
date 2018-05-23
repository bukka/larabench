#!/bin/bash

# set base directory
if readlink ${BASH_SOURCE[0]} > /dev/null; then
	LB_BASE="$( dirname "$( readlink ${BASH_SOURCE[0]} )" )"
else
	LB_BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

function lb_error {
    echo $@ > /dev/stderr
    exit 1
}

function lb_exec {
    echo $@
    exec $@
}

function lb_transform_template {
    cp $1 $2
    sed -i "s!{{BASE_DIR}}!$LB_BASE!g" $2
}

function lb_start_fpm {
    if [ -n "$2" ]; then
        LB_FPM_NAME="$2"
    else
        LB_FPM_NAME="basic"
    fi
    LB_FPM_EXECUTABLE="php-$1"
    LB_FPM_TEMPLATE="$LB_BASE/system/php-fpm/$LB_FPM_NAME/fpm.conf"
    LB_FPM_CONFIG="$LB_BASE/system/var/fpm.conf"

    if [ ! -f "$LB_FPM_TEMPLATE" ]; then
        lb_error "FPM config file $LB_FPM_TEMPLATE does not exist"
    fi
    lb_transform_template "$LB_FPM_TEMPLATE" "$LB_FPM_CONFIG"
    LB_FPM_CMD="$LB_FPM_EXECUTABLE -F -y $LB_FPM_CONFIG"

    echo "Larabench - starting $LB_FPM_EXECUTABLE:"
    lb_exec $LB_FPM_CMD
}

function lb_start_nginx {
    echo "Starting nginx"
}

function lb_start {
    if [ -z "$1" ]; then
        lb_error "No start application supplied"
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
            lb_error "Unknown start application $1"=
            ;;
    esac
}

if [ -z "$1" ]; then
    lb_error "No action set"
fi

case "$1" in
    start)
        shift
        lb_start $@
        ;;
    *)
        lb_error "Unknown action $1"
        ;;
esac