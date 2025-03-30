##########################################
# PART 1: SIMPLIFY AND SAVE MAP DATA
##########################################

# Load essential libraries for simplification
library(sf)

# Load map data first
map_data <- readRDS("data/map_data.rds")
map_data$id_riding <- as.character(map_data$id_riding)

# Transform to WGS84 for better web rendering
map_data <- st_transform(map_data, 4326)

# Safe geometry simplification function
simplify_geometry <- function(g, tolerance = 0.01) {
  tryCatch({
    st_simplify(g, dTolerance = tolerance)
  }, error = function(e) {
    # If error, try with smaller tolerance
    tryCatch({
      st_simplify(g, dTolerance = tolerance/10)
    }, error = function(e) {
      # If still error, return original
      g
    })
  })
}

# Apply simplification to each geometry individually
geom_list <- st_geometry(map_data)
simplified_geoms <- lapply(geom_list, function(g) simplify_geometry(g, tolerance = 0.01))

# Create simplified map data
map_data_simplified <- map_data
map_data_simplified$geometry <- st_sfc(simplified_geoms, crs = st_crs(map_data))

# Save the simplified map data
saveRDS(map_data_simplified, "data/map_data_simplified.rds")
