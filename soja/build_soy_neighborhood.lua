
-- Creates a neighborhood file that connects the municipalities to their
-- respective SimUs. The intersection areas are stored as attributes of
-- the neighborhood in munic_to_simu.gpm.

import("gis")
import("gpm")

p = Project{
    file = "mysoja.tview",
    clean = true,
    munic = "munic_soja_reproj_5880.shp",
    simu = "simu_reproj_5880.shp"
}

simu = CellularSpace{
    project = p,
    layer = "simu"
}

munic = CellularSpace{
    project = p,
    layer = "munic"
}


gpm = GPM{
    origin = munic,
    strategy = "area",
    destination = simu
}

gpm:save("munic_to_simu.gpm")

