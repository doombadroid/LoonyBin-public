#!/usr/bin/env bash
# Boot 1: load + compile test (no extDB3 needed). Run from arma3server root.
set -e
A3="$HOME/arma3server"
PROJ="$HOME/Documents/LooneyBin Altis Life"
# mission unpacked into mpmissions (allowedFilePatching=2)
mkdir -p "$A3/mpmissions"
rm -rf "$A3/mpmissions/LooneyBin.Altis"
cp -a "$PROJ/mission/LooneyBin.Altis" "$A3/mpmissions/LooneyBin.Altis"
# life_server packed addon
mkdir -p "$A3/@life_server/addons"
cp "$PROJ/deploy/server.cfg" "$A3/server.cfg"
cp "$PROJ/deploy/basic.cfg" "$A3/basic.cfg"
cd "$A3"
./arma3server_x64 -config=server.cfg -cfg=basic.cfg -serverMod=@life_server \
  -filePatching -noSound -world=empty -name=looneybin 2>&1 | tee "$PROJ/deploy/last-rpt.txt"
