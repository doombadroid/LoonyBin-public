/*
    compositions\zones.sqf -- COMPOSITION ZONE REGISTRY (LooneyBin, owner 2026-07-10)

    One mission-relative path per zone file. life_fnc_compZones loads this once per machine, compiles each
    listed file, and: spawns serverSide zones on the dedicated server at boot, spawns always-on zones
    (radius <= 0) once per client, and proximity-streams the rest per client as they travel.

    WORKFLOW (full doc: tools/MAP_EDITING.md, "Composition zones"):
      build/edit  ->  3DEN editor, select the pieces  ->  run tools/compExport.sqf (Eden debug console)
                  ->  paste the clipboard into compositions/zone_<name>.sqf  ->  add its path here
      re-edit     ->  copy the zone file's array onto the clipboard  ->  run tools/compImport.sqf in Eden
                  ->  edit the 'comp_<name>' layer  ->  re-export  ->  DELETE the layer before saving the sqm
*/ ["compositions\zone_example.sqf"]
