#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

MODE=$(jq --raw-output '.mode // empty' $CONFIG_PATH)
LOG=$(jq --raw-output '.log // empty' $CONFIG_PATH)

if [ -f "/homeassistant/addons/neolink.toml" ]; then
    echo "Migrating '/homeassistant/addons/neolink.toml' to '/addon_configs/a14d3924_neolink/neolink.toml'"
    cp /homeassistant/addons/neolink.toml /config/
    mv /homeassistant/addons/neolink.toml /homeassistant/addons/neolink.toml.migrated
fi

echo "--- VERSIONS ---"
echo "add-on version: 0.0.10"
echo -n "neolink version: " && neolink --version
echo "neolink mode: ${MODE}"
echo "neolink log: ${LOG}"
echo "ATTENTION: if you expected a newer Neolink version, please reinstall this Add-on!"
echo "--- Neolink ---"

case $LOG in
  debug)
    export RUST_LOG="neolink=debug"
    ;;
  trace)
    export RUST_LOG="neolink=trace"
    ;;
  info)
    export RUST_LOG="neolink=info"
    ;;
  warn)
    export RUST_LOG="neolink=warn"
    ;;
  error)
    export RUST_LOG="neolink=error"
    ;;
  *)
    echo -n "Unknown log level"
    ;;
esac

case $MODE in
  rtsp)
    neolink rtsp --config /config/neolink.toml
    ;;

  mqtt)
    neolink mqtt --config /config/neolink.toml
    ;;

  dual)
    neolink mqtt-rtsp --config /config/neolink.toml
    ;;

  talk)
    neolink talk --config /config/neolink.toml Haupteingang --microphone
    ;;
    
  *)
    echo -n "Unknown mode option"
    ;;
esac
