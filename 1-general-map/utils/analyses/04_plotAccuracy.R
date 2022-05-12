## plot accuracy per version
## mapbiomas collection 7 
## dhemerson.costa@ipam.org.br

## read libraries
library(ggplot2)

## avoid scientific notation
options(scipen= 999)

## set root path
root <- './table/accuracy/'

# list files
files <- list.files('./table/accuracy', pattern= "metrics", full.names=TRUE)

## create empty recipe
recipe <- as.data.frame(NULL)

## read files
for (i in 1:length(files)) {
  ## read file [i]
  x <- na.omit(read.csv(files[i])[-1])
  ## stack into recipe
  recipe <- rbind(recipe, x)
  rm(x)
}

## get only accuracy
global <- subset(recipe, variable == "Accuracy")

## plot summarized
ggplot(data= global, mapping= aes(x= year, y= value, colour= file)) +
  stat_summary(fun='mean', geom= 'line', alpha= .6) +
  stat_summary(fun='mean', geom= 'point') +
  scale_colour_manual(values=c('orange', 'red', 'black', 'green')) +
  theme_bw() +
  xlab(NULL) +
  ylab('Global accuracy')

## get specific accuracies
per_class <- subset(recipe, variable == 'Class: 3' | variable == 'Class: 4' |
                      variable == 'Class: 12' | variable == 'Class: 21' | variable == 'Class: 33')

## merge global with per class
per_class <- rbind(per_class, global)

## rename 
per_class$variable <- gsub('Class: 3', 'Forest',
                         gsub('Class: 4', 'Savanna',
                              gsub('Class: 12', 'Grassland/Wetland',
                                   gsub('Class: 21', 'Farming',
                                        gsub('Class: 33', 'Water',
                                             gsub('Accuracy', 'Acc. global',
                                                  per_class$variable))))))
## plot
ggplot(data= per_class, mapping= aes(x= year, y= value, colour= file)) +
  stat_summary(fun='mean', geom= 'line', alpha= .6) +
  stat_summary(fun='mean', geom= 'point') +
  scale_colour_manual(values=c('orange', 'red', 'black', 'green')) +
  facet_wrap(~variable, scales= 'free_y') +
  theme_bw() +
  xlab(NULL) +
  ylab('Accuracy')
