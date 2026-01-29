#############
## Shape data
#############

graph = sfnetwork_mesh_2( stream_upstream )
graph$table$dist = graph$table$dist / 1000  # Convert distance scale
spp_sf <- st_transform(spp_sf,crs = st_crs(stream))
Data = data.frame( Count = log(spp_sf$effectif+1),
  st_coordinates(spp_sf),
  var = "species", # Univariate model so only one value
  time = spp_sf$annee, # time varying intercept
  dist = "obs") # only one type of sampling in data

data2 <- spp_sf %>% 
  sf::st_drop_geometry() %>% 
  mutate(var = "species",
         dist = "obs",
         Count = log(effectif+1)) %>% 
  rename(time = annee) %>% 
  cbind(st_coordinates(spp_sf))
  

seq_times <- unique(Data$time)[order(unique(Data$time))]
seq_times2 <- unique(data2$time)[order(unique(data2$time))]
