/*
    compositions\zone_example.sqf -- FORMAT REFERENCE, DISABLED (enabled=false spawns nothing).

    [ name, [cx,cy], radius, enabled, serverSide, objects ]
      radius 350   -> clients stream the set in within 350m, out past 470m (+120 hysteresis)
      radius <= 0  -> always loaded
      serverSide   -> also spawned on the dedicated server at boot
    object: [class, posWorld, vectorDir, vectorUp, simple?(optional, default true)]
      posWorld everywhere -- NEVER hand-convert ATL/ASL (sea-level footgun). tools/compExport.sqf
      emits exactly this shape; don't hand-author entries, round-trip through Eden.
*/ ["example", [3600.0, 13100.0], 350, false, false, [
        ["Land_BagFence_Long_F", [3600.000, 13100.000, 22.500], [0.000, 1.000, 0.000], [0.000, 0.000, 1.000]],
        ["Land_BagFence_Long_F", [3603.100, 13100.000, 22.500], [0.000, 1.000, 0.000], [0.000, 0.000, 1.000]],
        ["Land_CampingTable_F",  [3601.500, 13102.200, 22.850], [0.707, 0.707, 0.000], [0.000, 0.000, 1.000]]]]
