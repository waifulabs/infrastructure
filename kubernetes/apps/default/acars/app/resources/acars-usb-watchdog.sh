 #!bin/bash

DEVICES=$SERIALS
# Turn this into iterable
SERIALS=$(echo $SERIALS | sed 's/,/\n/g')
STS=$(echo $STATEFULSETS | sed 's/,/\n/g')
hub=/sys/bus/pci/drivers/xhci_hcd

function log() {
    echo "[$(date "+%F %T")][usb-watchdog] $1"
}

function idle() {
    log "Sleeping for $1 seconds..."
    sleep $1
}

function unbind() {
    for i in ????:??:??.? ; do
    echo -n "$i" > unbind
    done
}

function bind() {
    for i in ????:??:??.? ; do
    echo -n "$i" > bind
    done
}

scaled=1
function scale() {
    log "Scaling to $1"
    scaled=$1
    value=0
    for s in $${STS[@]}; do
    kubectl scale statefulset $s --replicas $1
    [[ $? != 0 ]] && value=1
    done
    return $value
}

function activereplicas() {
    count=0
    for s in $${STS[@]}; do
        if [[ $(kubectl get statefulset $s | grep "$s " | awk '{print $2}') != "0/0" ]]; then
        let count++
        fi
    done
    echo $count
}

function waitforzero() {
    limit=36 # 3 minutes with 5 second waits
    period=5
    count=0
    log "Waiting up to $(( limit * period )) seconds for pods to terminate..."
    while [[ $(activereplicas) > 0 ]]; do
    if [[ $count == $limit ]]; then
        log "Not all apps scaled down, but not waiting any longer"
        return 1
    fi
    let count++
    idle $period
    done
    log "Scaled down to zero"
}

function bounce() {
    kubectl rollout restart sts $${HOSTNAME%-0}
}

log "Watching USB for: $DEVICES"
log "Starting..."
sleep 5
while :; do
    missing=0
    for SERIAL in $SERIALS; do
    if [[ $(timeout 5 usb-devices | grep -q SerialNumber=$SERIAL; echo $?) != 0 ]]; then
        missing=1
        log "$SERIAL: Couldn't get bus or device, resetting the controller"
        log "Here's the devices present:"
        timeout 5 usb-devices | grep -A2 "Nooelec"
        for controller in /sys/bus/pci/drivers/?hci_hcd; do
        if ! cd $xhci ; then
            echo Weird error. Failed to change directory to $xhci
            exit 1
        fi
        if [[ "$${controller}x" == "x" ]]; then
            log "$SERIAL: Couldn't determine controller, here's $controller dir"
            ls $controller
            log "Exiting with error"
            exit 10
        else
            scale 0
            waitforzero; status=$?
            if [[ $status == 0 ]]; then
            log "Resetting USB Hub: Unbinding controller $controller"
            unbind $controller
            idle 5
            log "Resetting USB Hub: Binding controller $controller"
            bind $controller
            idle 60
            log "Restarting pod to remount filesystem"
            bounce
            sleep 10
            else
            log "Apps didn't scale down, exiting with error"
            exit 30
            fi
        fi
        done
    fi
    done
    if [[ $missing == 0 ]]; then
    log "All devices present."
    if [[ $(activereplicas) < 3 ]]; then
        scale 1
    fi
    fi
    idle 30
done