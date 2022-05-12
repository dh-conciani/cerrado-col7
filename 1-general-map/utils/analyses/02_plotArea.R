## plot areas from collection 7 
## dhemerson.costa@ipam.org.br

# read libraries
library(ggplot2)

## avoid sci-notation
options(scipen= 999)

## set root
root <- './table/area/'

## list files
files <- list.files(root, full.names= TRUE)

## create recipe
data <- as.data.frame(NULL)

## read and stack files
for (i in 1:length(unique(files))) {
  ## read file [i]
  x <- read.csv(files[i])[-1][-6]
  ## merge
  data <- rbind(data, x)
  rm(x)
}

## rename classes
data$class_id <- gsub('^3$', 'Forest', 
                      gsub('^4$', 'Savanna',
                           gsub('^11$', 'Wetland',
                                gsub('^12$', 'Grassland',
                                     gsub('^15$', 'Farming',
                                          gsub('^19$', 'Farming',
                                               gsub('^21$', 'Farming',
                                                    gsub('^25$', 'Non-vegetated',
                                                         gsub('^33$', 'Water',
                                                              data$class_id)))))))))

## parse filenames and get suitable names
data$file <- substr(data$file, start= nchar('CERRADO_col7_') + 1, stop= 1e2)

## plot general area class per version, summarized for the biome 
ggplot(data= data, mapping= aes(x= year, y= area/1e6, group= file, col= as.factor(file))) +
  stat_summary(fun='sum', geom= 'line', alpha= .6) +
  stat_summary(fun='sum', geom= 'point') +
  scale_colour_manual('Version', values=c('blue', 'green', 'red')) +
  facet_wrap(~class_id, scales= 'free_y') +
  theme_bw() +
  ylab('Área (Mha)') +
  xlab(NULL)

## plot specific area class by region 
ggplot(data= subset(data, class_id == 'Forest'), mapping= aes(x= year, y= area/1e6, group= class_id, col= as.factor(file))) +
  stat_summary(fun='sum', geom= 'line') +
  stat_summary(fun='sum', geom= 'point', alpha= .6) +
  scale_colour_manual('Version', values=c('blue')) +
  facet_wrap(~territory, scales= 'fixed') +
  theme_bw() +
  ylab('Área (Mha)') +
  xlab(NULL)
