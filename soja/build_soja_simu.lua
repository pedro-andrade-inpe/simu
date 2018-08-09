-- create csv files with the amount of soy per simu
-- using a neighborhood file to make it faster

import("gis")

processFile = function(filename)
    local _, name, _ = filename:split()

    local p = Project{
        file = "mysoja.tview",
        clean = true,
        munic = filename,
        simu = "simu_reproj_5880.shp"
    }

    local cell = Cell{
        soy = 0
    }

    local simu = CellularSpace{
        project = p,
        layer = "simu",
        instance = cell
    }

    -- a small bug in TerraME that requires updating
    -- the layer to its name in order to allow loading
    -- the neighborhood file. This will be fixed a
    -- future version.
    local simulayer = simu.layer
    simu.layer = "simu"

    local munic = CellularSpace{
        project = p,
        layer = "munic",
    }

    munic.layer = "munic"

    local env = Environment{simu, munic}

    env:loadNeighborhood{file = "munic_to_simu.gpm", check = false}

    forEachCell(munic, function(municipio)
        local sum = 0

        if municipio:getNeighborhood() == nil then return end

        forEachNeighbor(municipio, function(_, weigh)
            sum = sum + weigh
        end)

        forEachNeighbor(municipio, function(neigh, weigh)
            neigh.soy = neigh.soy + weigh / sum * municipio.soy
        end)
    end)

    local total = 0

    forEachCell(munic, function(c)
        total = total + c.soy
    end)

    --print("total by simu: "..simu:soy())
    --print("total by municipality: "..total)

    simu.layer = simulayer

    local file = File("result/"..name..".csv")
    file:deleteIfExists()
    file:writeLine("simuid;soy")

    local result = {}

    forEachCell(simu, function(c)
        local id = c.simuid
        if not result[id] then result[id] = 0 end

        result[id] = result[id] + c
        .soy
    end)

    forEachOrderedElement(result, function(idx, value)
        local v = idx..";"..value
        file:writeLine(v)
    end)

    file:close()
end

forEachFile("shps", function(file)
    if file:extension() == "shp" then
        print("Processing "..file:name())
        processFile(file)
    end
end)

