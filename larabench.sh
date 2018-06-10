#!/bin/bash

# set base directory
if readlink ${BASH_SOURCE[0]} > /dev/null; then
	LB_BASE="$( dirname "$( readlink ${BASH_SOURCE[0]} )" )"
else
	LB_BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi
LB_VAR="$LB_BASE/system/var"

function lb_error {
    echo $@ > /dev/stderr
    exit 1
}

function lb_exec {
    echo $@
    exec $@
}

function lb_cmd {
    echo $@
    $@
}

function lb_transform_template {
    cp $1 $2
    sed -i.bak "s!{{BASE_DIR}}!$LB_BASE!g" $2
    sed -i.bak "s!{{VAR_DIR}}!$LB_VAR!g" $2
}

function lb_start_fpm {
    if [ -n "$2" ]; then
        LB_FPM_NAME="$2"
    else
        LB_FPM_NAME="basic"
    fi
    LB_FPM_EXECUTABLE="php-$1"
    LB_FPM_TEMPLATE="$LB_BASE/system/php-fpm/$LB_FPM_NAME/fpm.conf"
    LB_FPM_CONFIG="$LB_VAR/fpm.conf"

    if [ ! -f "$LB_FPM_TEMPLATE" ]; then
        lb_error "FPM config file $LB_FPM_TEMPLATE does not exist"
    fi
    lb_transform_template "$LB_FPM_TEMPLATE" "$LB_FPM_CONFIG"
    LB_FPM_CMD="$LB_FPM_EXECUTABLE -F -y $LB_FPM_CONFIG"

    echo "Larabench - starting $LB_FPM_EXECUTABLE:"
    lb_exec $LB_FPM_CMD
}

function lb_start_nginx {
    LB_BASE_NGINX="$LB_BASE/system/nginx"
    LB_NGINX_CONF_SRC="$LB_BASE_NGINX/nginx.conf"
    LB_NGINX_CONF_DST="$LB_VAR/nginx.conf"
    lb_transform_template $LB_NGINX_CONF_SRC $LB_NGINX_CONF_DST
    cp "$LB_BASE_NGINX/fastcgi_params" "$LB_VAR/"

    LB_NGINX_CMD="nginx -c $LB_NGINX_CONF_DST"
    echo "Larabench - starting nginx:"
    lb_exec $LB_NGINX_CMD
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

function lb_run {
    if [ -n "$1" ]; then
        LB_RUN_PATH="$1"
    else
        LB_RUN_PATH=api/log/basic/128
    fi
    if [ -n "$2" ]; then
        LB_RUN_THREADS="$2"
    else
        LB_RUN_THREADS=8
    fi
    if [ -n "$3" ]; then
        LB_RUN_CONNS="$3"
    else
        LB_RUN_CONNS=8
    fi
    if [ -n "$4" ]; then
        LB_RUN_APP="$4"
    else
        LB_RUN_APP=wrk
    fi

    lb_cmd $LB_RUN_APP -t$LB_RUN_THREADS -c$LB_RUN_CONNS http://localhost:8083/$LB_RUN_PATH
}

if [ -z "$1" ]; then
    lb_error "No action set"
fi

case "$1" in
    start)
        shift
        lb_start $@
        ;;
    run)
        shift
        lb_run $@
        ;;
    *)
        lb_error "Unknown action $1"
        ;;
esac