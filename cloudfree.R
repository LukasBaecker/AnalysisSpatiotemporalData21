setwd('D:/astd-master')

# import spatial packages
library(raster)
library(rgdal)
library(rgeos)
# turn off factors
options(stringsAsFactors = FALSE)

# create a list of all landsat files that have the extension .tif and contain the word band.
all_landsat_bands <- list.files("L8_newImage2020/LC082330672020051701T1-SC20210308145654",
                                pattern = glob2rx("*band*.tif$"),
                                full.names = TRUE) # use the dollar sign at the end to get all files that END WITH
# create spatial raster stack from the list of file names
all_landsat_bands_st <- stack(all_landsat_bands)
all_landsat_bands_br <- brick(all_landsat_bands_st)

# turn the axis color to white and turn off ticks
par(col.axis = "white", col.lab = "white", tck = 0)
# plot the data - be sure to turn AXES to T (you just color them white)
plotRGB(all_landsat_bands_br,
        r = 4, g = 3, b = 2,
        stretch = "hist",
        main = "Pre-fire RGB image with cloud\n Cold Springs Fire",
        axes = TRUE)
# turn the box to white so there is no border on your plot
box(col = "white")

# apply shadow mask
cloud_mask_shadow <- raster("L8_newImage2020/LC082330672020051701T1-SC20210308145654/LC08_L1TP_233067_20200517_20200527_01_T1_sr_band1.tif")
# create cloud & cloud shadow mask
cloud_mask_shadow[cloud_mask_shadow > 500] <- NA
plot(cloud_mask_shadow,
     main = "Landsat 8 - Cloud mask layer with shadows.", legend=TRUE)

writeRaster(cloud_mask_shadow,'cloudfree.tif', overwrite=TRUE)

par(xpd = FALSE, mar = c(0, 0, 1, 5))

# plot the masked data
plot(cloud_mask_shadow,
     main = "The Raster Mask",
     col = c("green"),
     legend = FALSE,
     axes = FALSE,
     box = FALSE)
# add legend to map
par(xpd = TRUE) # force legend to plot outside of the plot extent
legend(x = cloud_mask_shadow@extent@xmax, cloud_mask_shadow@extent@ymax,
       c("Not masked", "Masked"),
       fill = c("green", "white"),
       bty = "n")

# mask the stack
all_landsat_bands_mask <- mask(all_landsat_bands_br, mask = cloud_mask_shadow)

# check the memory situation
inMemory(all_landsat_bands_mask)
## [1] TRUE
class(all_landsat_bands_mask)
## [1] "RasterBrick"
## attr(,"package")
## [1] "raster"

# plot RGB image
# first turn all axes to the color white and turn off ticks
par(col.axis = "white", col.lab = "white", tck = 0)
# then plot the data
plotRGB(all_landsat_bands_mask,
        r = 4, g = 3, b = 2,
        main = "Landsat RGB Image \n Are the clouds gone?",
        axes = TRUE)
box(col = "white")
