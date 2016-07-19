library(ggplot2)
library(dplyr)

setwd("~/git/pgCryptoBench/data/")

benchTimes <- read.csv("stats.csv",
                       colClasses = c("character","numeric","numeric","numeric"))

colnames(benchTimes) <- c("Algorithm", "Level", "Compression", "Execution_Time")

benchTimes$Algorithm <- as.factor(benchTimes$Algorithm)
benchTimes$Level <- as.factor(benchTimes$Level)
benchTimes$Compression <- as.factor(benchTimes$Compression)

byType <- group_by(benchTimes, Algorithm, Level, Compression)
summarize(byType, mean(Execution_Time))

byAlgo <- group_by(benchTimes, Algorithm)
byAlgoMinMax <- summarize(byAlgo,max(Execution_Time),min(Execution_Time), mean(Execution_Time))
colnames(byAlgoMinMax) <- c("Algorithm","Max","Min", "Mean")

byAlgoNoComp <- group_by(benchTimes, Algorithm)
noComp <- summarize(filter(byAlgoNoComp, Level == 0),mean(Execution_Time))

byAlgoCompLevel <- group_by(benchTimes,Algorithm, Level)
comp <- summarize(filter(byAlgoCompLevel, Level == 1 || Level == 2) , mean(Execution_Time))

filteringByCompression <- filter(byType, Level == 1 || Level == 2)
compCompression <- summarize(filteringByCompression, 
                             min(Execution_Time) , max(Execution_Time))


# Graphing Algorithms by Min Max with no filters (Comp and No compression included)  
limits <- aes(ymax = byAlgoMinMax$Max,
              ymin = byAlgoMinMax$Min)
dodge <- position_dodge(width = 0.9)

plooooot <- ggplot(data = byAlgoMinMax, aes(x = Algorithm, y = Mean, fill = Algorithm ))

plooooot + geom_bar(stat = "identity", position = dodge) +
  geom_errorbar(limits, position = dodge, width = 0.25) +
  theme(axis.text.x=element_blank(), axis.ticks.x=element_blank(),
        axis.title.x=element_blank())