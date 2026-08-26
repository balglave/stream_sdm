############################
## Check geoprocessing steps
############################

par(mfrow = c(1,1))

## Filter a specific bassin
rht_sf_2 <- rht_sf # |> 
  # filter(CdSecteurHydro == "M4")

## Simplification operations
#---------------------------
rht_network <- as_sfnetwork(st_transform(st_as_sf(rht_sf_2, "edges"), 32631), directed = TRUE)

edges <- st_as_sf(activate(rht_network, "edges"))
nodes <- st_as_sf(activate(rht_network, "nodes"))

## Add number of the node
nodes <- nodes |> mutate(node_index = 1:nrow(nodes))

# Create a data frame of unique nodes
unique_nodes <- unique(c(edges$from, edges$to))

# Identify upstream nodes
upstream_nodes <- unique_nodes[!unique_nodes %in% edges$to]

# Filter edges to remove those connected to upstream nodes
filtered_edges <- edges %>%
  rename(from_node = from, to_node = to) %>%
  filter(!from_node %in% upstream_nodes & !to_node %in% upstream_nodes) |> 
  distinct(from_node,to_node,.keep_all = T)

rht_network_filtered <- as_sfnetwork(st_transform(st_as_sf(filtered_edges[,colnames(rht_loire)], "edges"), 32631), directed = TRUE)

## Plot network versus simplified network
#----------------------------------------
plot(st_geometry(rht_sf_2))
plot(st_geometry(filtered_edges),add = T,col="green")
plot(rht_network_filtered,add = T,col="green")
text(nodes,cex = 1)
text(nodes[which(nodes$node_index %in% unique_nodes),],cex = 1,col = "red")
text(nodes[which(nodes$node_index %in% upstream_nodes),],cex = 1,col = "blue")

## Reverse network
source("r/source/reverse_network.R")

## Detect problematic nodes
nodes_upstream <- st_as_sf(activate(stream_upstream, "nodes"))
nodes_upstream <- nodes_upstream |> mutate(node_index = 1:nrow(nodes))
edges_upstream <- st_as_sf(activate(stream_upstream, "edges")) %>%
  distinct(from, to, .keep_all = TRUE)




N = nrow(nodes_upstream)
table = data.frame(from = edges_upstream$from, to = edges_upstream$to, dist = drop_units(st_length(edges_upstream)))
number_of_parents = table(factor(table$to, levels = seq_len(N)))
number_of_parents[which(number_of_parents > 1)]

nodes_of_interest <- as.numeric(names(graph$number_of_parents[which(graph$number_of_parents>1)]))
nodes_of_interest_sf <- nodes_upstream[which(nodes_upstream$node_index %in% nodes_of_interest),]

# mapView(x = st_geometry(rht_sf_2),color="green")+
mapView(x = st_geometry(edges_upstream),color="blue")+
  mapView(x = st_geometry(nodes_of_interest_sf),color="green")

coord_point <- st_coordinates(nodes_of_interest_sf[i,])
plot_network <- ggplot()+
  geom_sf(data=st_geometry(edges_upstream),aes(col = edges_upstream$CdSecteurHydro))+
  # geom_sf(data=st_geometry(filtered_edges),col="green")+
  # geom_sf_text(data=st_geometry(nodes_upstream),
  #   aes(label=nodes_upstream$node_index),col="blue")+
  geom_sf_text(data=st_geometry(nodes_of_interest_sf),
    aes(label=nodes_of_interest_sf$node_index),col="red")

edges_upstream |> 
  filter(to == 3944)


## Check model structure
dim(distinct(as.data.frame(edges_upstream)))
dim(distinct(as.data.frame(edges_upstream), from ,to))


graph = sfnetwork_mesh_2( stream_upstream )
nodes_of_interest <- as.numeric(names(graph$number_of_parents[which(graph$number_of_parents>2)]))
nodes_of_interest_sf <- nodes_upstream[which(nodes_upstream$node_index %in% nodes_of_interest),]

## Plot interactive map of networks and problematic nodes
library(mapview)
# mapView(x = st_geometry(rht_sf_2),color="green")+
  mapView(x = st_geometry(filtered_edges),color="blue")+
  mapView(x = st_geometry(nodes_of_interest_sf),color="green")

# ## Plot each problematic node
# library(ggrepel)
# for(i in 1:nrow(nodes_of_interest_sf)){

#   coord_point <- st_coordinates(nodes_of_interest_sf[i,])

#   plot_network <- ggplot()+
#     geom_sf(data=st_geometry(rht_sf_2))+
#     geom_sf(data=st_geometry(filtered_edges),col="green")+
#     geom_sf_text(data=st_geometry(nodes_of_interest_sf),
#       aes(label=nodes_of_interest_sf$node_index),col="blue",alpha=0.5)+
#     coord_sf(
#       xlim = c(coord_point[1] - 100,coord_point[1] + 100),
#       ylim = c(coord_point[2] - 100,coord_point[2] + 100),
#       expand = FALSE
#     )
  
#   plot(plot_network)

# }

