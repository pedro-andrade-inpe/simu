require(sf)

# This script creates shp files with soy data for each Brazilian municipality
# It uses a modified version of IBGE data to allow matching the names
# of all municipalities (see below)

# To run this script, it is necessary to be in the directory where
# the

processFile <- function(filename){
  csv = read.csv(paste0("BRAZIL_SOY_2.2/", filename), as.is=TRUE)

  munic <- sf::read_sf(dsn = ".", layer = "55mu2500gsd_albersconic")

  shp = as.data.frame(munic)

  mystates = list(
    AMAPA = "AP", MARANHAO = "MA", `MATO GROSSO` = "MT", PARA = "PA", RONDONIA = "RO",
    RORAIMA = "RR", TOCANTINS = "TO", `MINAS GERAIS` = "MG", PIAUI = "PI",
    BAHIA = "BA", `DISTRITO FEDERAL` = "DF", GOIAS = "GO", `MATO GROSSO DO SUL` = "MS",
    PARANA = "PR", `SAO PAULO` = "SP", `RIO GRANDE DO SUL` = "RS", `SANTA CATARINA` = "SC",
    ALAGOAS = "AL", `UNKNOWN STATE` = "US", `RIO DE JANEIRO` = "RJ",
    PERNAMBUCO = "PE", SERGIPE = "SE"
  )

  # update state names to match the names from the shapefile
  csv$Sigla = unlist(mystates[csv$STATE])
  csv$code = paste(csv$MUNICIPALITY, csv$Sigla)

  # use munic concatenated to the state name to guarantee unique names
  shp$code = paste(shp$name_plain, shp$Sigla)

  csv$code = sub(" Do ", " do ", csv$code)
  csv$code = sub(" De ", " de ", csv$code)
  csv$code = sub(" Da ", " da ", csv$code)
  csv$code = sub(" Dos ", " dos ", csv$code)
  csv$code = sub(" Das ", " das ", csv$code)
  csv$code = sub(" D'Oeste ", " DOeste ", csv$code)

  csv$code = sub("Patos de Mina", "Patos de Minas", csv$code)
  csv$code = sub("Mirassol DOeste", "Mirassol dOeste", csv$code)
  csv$code = sub("Pontes E Lacerda", "Pontes e Lacerda", csv$code)
  csv$code = sub("Vila Bela Santissima Trindade", "Vila Bela da Santissima Trindade", csv$code)
  csv$code = sub("Sao Joao D'Alianca", "Sao Joao dAlianca", csv$code)
  csv$code = sub("Sitio D'Abadia", "Sitio dAbadia", csv$code)
  csv$code = sub("Couto de Magalhaes", "Couto Magalhaes", csv$code)
  csv$code = sub("Porto Naciona", "Porto Nacional", csv$code)
  csv$code = sub("Madre de Deus De Minas", "Madre de Deus de Minas", csv$code)
  csv$code = sub("Sao Joao Del Rei", "Sao Joao del Rei", csv$code)
  csv$code = sub("Coronel Vivid", "Coronel Vivida", csv$code)
  csv$code = sub("Itapejara DOeste", "Itapejara dOeste", csv$code)
  csv$code = sub("Perola DOeste", "Perola dOeste", csv$code)
  csv$code = sub("Sao Jorge DOeste", "Sao Jorge dOeste", csv$code)
  csv$code = sub("Faxinal dos G", "Faxinal dos Guedes", csv$code)
  csv$code = sub("Herval DOeste", "Herval dOeste", csv$code)
  csv$code = sub("Presidente Castelo Branco SC", "Presidente Castello Branco SC", csv$code)
  csv$code = sub("Sao Miguel D Oeste", "Sao Miguel do Oeste", csv$code)
  csv$code = sub("Santa Barbara DOeste", "Santa Barbara dOeste", csv$code)
  csv$code = sub("Santa Clara DOeste", "Santa Clara dOeste", csv$code)
  csv$code = sub("Eldorado do S", "Eldorado do Sul", csv$code)
  csv$code = sub("Santana do Livramento", "Sant Ana do Livramento", csv$code)
  csv$code = sub("Mojui dos Campos", "Moju", csv$code)
  csv$code = sub("Paraiso das Aguas", "Paraiso do Sul", csv$code)

  #csv$code = sub("Rio dos Indios", "Rio dos ?ndios", csv$code)
  # I needed to change this municipality manually in the input data
  # as R did not recognize it

  shp$soy = 0
  for(i in 1:dim(csv)[1]){
    munic = csv$code[i]
    soy = csv$SOY_EQUIVALENT_TONS[i]

    pos = which(shp$code == munic)

    if(length(pos) == 0) cat(paste0("Problem: ", munic, "at position ", i, "\n"))

    shp$soy[pos] = shp$soy[pos] + soy
  }

  #sum(shp$soy) - sum(csv$SOY_EQUIVALENT_TONS) # the error

  shp$soy = round(shp$soy, digits = 3)

  st_sf(shp) -> result

  myfile = paste0("shps/", tools::file_path_sans_ext(filename), ".shp")
  sf::write_sf(result, myfile, delete_layer=TRUE)
  cat(paste0("Total csv: ", sum(csv$SOY_EQUIVALENT_TONS), "\n"))
  cat(paste0("Total shp: ", sum(shp$soy), "\n"))
}

files <- list.files(path = "BRAZIL_SOY_2.2", pattern = "\\.csv$")

for(file in files) {
  cat(paste0("Processing ", file, "\n"))
  processFile(file)
}
