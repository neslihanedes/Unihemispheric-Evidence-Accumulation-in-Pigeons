
rm(list=ls())
library(rstan)
library(tidyverse)
library(R.matlab)
library(lme4)
library(car)
library(multcomp)
source(paste(dirname(rstudioapi::getActiveDocumentContext()$path), "/functions.R", sep=""))

s
# import all the data
d_normal1 = read.csv("EXP1_NORMAL.csv")
d_normal1 = d_normal1[d_normal1$initDone==1,]
d_limit1 = read.csv("EXP1_PROBE.csv")
d_limit1 = d_limit1[d_limit1$initDone==1,]
d_limit1$fdelay = as.factor(d_limit1$delay)
d_normal2 = read.csv("EXP2_NORMAL.csv")
d_normal2 = d_normal2[d_normal2$initDone==1,]
d_normal2 = d_normal2[d_normal2$id != 156,]
d_limit2 = read.csv("EXP2_PROBE.csv")
d_limit2 = d_limit2[d_limit2$initDone==1,]
d_limit2 = d_limit2[d_limit2$delay < 0.7,]
d_limit2 = d_limit2[d_limit2$id != 156,]
d_limit2$fdelay = as.factor(d_limit2$delay)


# here are variables for the figure style
# order : probeRight probeLeft probeRight
# colmap = c("brown1", "forestgreen", "dodgerblue2")
colmap = c("gray20", "orange", "blue")

LWD = 1.8
DODGE_WID = .01
SE_WID = .01
TM = theme(axis.text.x = element_text(family = "Times New Roman",size = rel(6), colour = "black"),
           axis.text.y = element_text(family = "Times New Roman",size = rel(6), colour = "black"),
           axis.title.x = element_text(family = "Times New Roman",size = rel(6), colour = "black", vjust = .1),
           axis.title.y = element_text(family = "Times New Roman",size = rel(6), colour = "black"),
           legend.position = "none",
           panel.grid = element_blank(),
           panel.background = element_rect(fill="white"),
           panel.border = element_rect(colour = "black", fill=NA, size=1.5),
           axis.ticks = element_line(colour = "black", size=1.3))

#-------------------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------------------#
#------------------------------------- Experiment 1 ----------------------------------------------#
#-------------------------------------------------------------------------------------------------#
d.hit1 = get.d.rate.hit(d_limit1[d_limit1$rtGo > .050,])
d.hit1.mean = get_mean_rate(d.hit1)


# statistical analysis using ANOVA
summary(aov(value ~ cond * as.factor(delay) + Error( id/(cond+id/as.factor(delay))), data=d.hit1))


# statistical analysis using ANOVA
summary(aov(value ~ cond * as.factor(delay) + Error( id/(cond+id/as.factor(delay))), data=d.hit1))

delays = unique(d.hit1$delay)
summary(aov(value ~ cond  + Error( id/(cond+id)), data=d.hit1[d.hit1$delay == delays[1],]))
summary(aov(value ~ cond  + Error( id/(cond+id)), data=d.hit1[d.hit1$delay == delays[2],]))
summary(aov(value ~ cond  + Error( id/(cond+id)), data=d.hit1[d.hit1$delay == delays[3],]))
summary(aov(value ~ cond  + Error( id/(cond+id)), data=d.hit1[d.hit1$delay == delays[4],]))
summary(aov(value ~ cond  + Error( id/(cond+id)), data=d.hit1[d.hit1$delay == delays[5],]))
summary(aov(value ~ cond  + Error( id/(cond+id)), data=d.hit1[d.hit1$delay == delays[6],]))
summary(aov(value ~ cond  + Error( id/(cond+id)), data=d.hit1[d.hit1$delay == delays[7],]))
summary(aov(value ~ cond  + Error( id/(cond+id)), data=d.hit1[d.hit1$delay == delays[8],]))
summary(aov(value ~ cond  + Error( id/(cond+id)), data=d.hit1[d.hit1$delay == delays[9],]))
summary(aov(value ~ cond  + Error( id/(cond+id)), data=d.hit1[d.hit1$delay == delays[10],]))
summary(aov(value ~ cond  + Error( id/(cond+id)), data=d.hit1[d.hit1$delay == delays[11],]))
summary(aov(value ~ cond  + Error( id/(cond+id)), data=d.hit1[d.hit1$delay == delays[12],]))


pairwise.t.test(mean_by_cond(d.hit1[d.hit1$delay == delays[10],])$value, 
                mean_by_cond(d.hit1[d.hit1$delay == delays[10],])$cond, p.adjust.methods = "holm", paired = TRUE)


pairwise.t.test(mean_by_cond(d.hit1[d.hit1$delay == delays[10],])$value, 
                mean_by_cond(d.hit1[d.hit1$delay == delays[10],])$cond, p.adjust.methods = "holm", paired = TRUE)



### Accumulation time of experiment 1

return.accum = function(d_limit){
  mod = glm(reward ~ delay * trialType2 - 1, d_limit, family = binomial(link = logit))
  # mod = glm(reward ~ delay , d_limit1, family = binomial(link = logit))
  
  beta = coef(mod)
  p = 0.5
  accum = 
    data.frame(
      accum = c((log(p/(1-p)) - beta[2]) / beta[1],
                (log(p/(1-p)) - beta[3]  ) / (beta[1] + beta[5]),
                (log(p/(1-p)) - beta[4]  ) / (beta[1] + beta[6])),
      id = d_limit$id[1],
      trialType2 = c("bino", "left", "right")
    )
  
  rownames(accum) = NULL
  return(accum)
}

d.accum = split(d_limit1, d_limit1$id) %>% lapply(., return.accum) %>% do.call(rbind,.)

summary(aov(accum ~ trialType2 + Error( id/trialType2), d.accum))



### Analysis on FA rates
d.fa1 = get.d.rate.fa(d_limit1[d_limit1$rtNogo > .05,])
d.fa1.mean = get_mean_rate(d.fa1)


# statistical analysis using ANOVA
summary(aov(value ~ cond * as.factor(delay) + Error( id/(cond*as.factor(delay)) ), data=d.fa1))


pairwise.t.test(mean_by_cond(d.fa1)$value, 
                mean_by_cond(d.fa1)$cond, p.adjust.methods = "holm", paired = TRUE)

temp = mean_by_cond(d.fa1)
t.test(temp$value[temp$cond == "binoProbe"], temp$value[temp$cond == "probeRight"], paired = TRUE)
t.test(temp$value[temp$cond == "binoProbe"], temp$value[temp$cond == "probeLeft"], paired = TRUE)
t.test(temp$value[temp$cond == "probeRight"], temp$value[temp$cond == "probeLeft"], paired = TRUE)


#-------------------------------------------------------------------------------------------------#
#------------------------------------- Experiment 2 ----------------------------------------------#
#-------------------------------------------------------------------------------------------------#
d.hit2 = get.d.rate.hit(d_limit2[d_limit2$rtGo > .050,])
d.hit2.mean = get_mean_rate(d.hit2)

summary(aov(value ~ cond * as.factor(delay) + Error( id/cond + id/as.factor(delay)), data=d.hit2))
pairwise.t.test(mean_by_cond(d.hit2)$value, mean_by_cond(d.hit2)$cond, p.adjust.methods = "holm", paired = TRUE)


### Accumulation time of experiment 2

return.accum = function(d_limit){
  mod = glm(reward ~ delay * trialType2 - 1, d_limit, family = binomial(link = logit))
  # mod = glm(reward ~ delay , d_limit1, family = binomial(link = logit))
  
  beta = coef(mod)
  p = 0.5
  accum = 
    data.frame(
      accum = c((log(p/(1-p)) - beta[2]) / beta[1],
                (log(p/(1-p)) - beta[3]  ) / (beta[1] + beta[5]),
                (log(p/(1-p)) - beta[4]  ) / (beta[1] + beta[6])),
      id = d_limit$id[1],
      trialType2 = c("bino", "left", "right")
    )
  
  rownames(accum) = NULL
  return(accum)
}

d.accum = split(d_limit2, d_limit2$id) %>% lapply(., return.accum) %>% do.call(rbind,.)

summary(aov(accum ~ trialType2 + Error( id/trialType2), d.accum))


### Analysis on FA rates
d.fa2 = get.d.rate.fa(d_limit2[d_limit2$rtNogo > .050,])
d.fa2.mean = get_mean_rate(d.fa2)

# statistical test
summary(aov(value ~ cond * as.factor(delay) + Error( id/cond + id/as.factor(delay)), data=d.fa2))
pairwise.t.test(mean_by_cond(d.fa2)$value, mean_by_cond(d.fa2)$cond, p.adjust.methods = "holm", paired = TRUE)

temp = mean_by_cond(d.fa2)
t.test(temp[temp$cond=="binoProbe",]$value, temp[temp$cond=="probeRight",]$value, paired = TRUE)
t.test(temp[temp$cond=="binoProbe",]$value, temp[temp$cond=="probeLeft",]$value, paired = TRUE)
t.test(temp[temp$cond=="probeRight",]$value, temp[temp$cond=="probeLeft",]$value, paired = TRUE)


#-------------------------------------------------------------------------------------------------#
#-------------------------------- check binouclar is identical ----------------------------------#
#-------------------------------------------------------------------------------------------------#

d.hit1$exp =  "exp1"
d.hit2$exp =  "exp2"
d.hit = rbind(d.hit1, d.hit2)
summary(aov(value ~ exp * as.factor(delay) * cond+ Error( id/exp + id/as.factor(delay)), data=d.hit))

d.hit.mean1 = mean_by_cond(d.hit1)
d.hit.mean2 = mean_by_cond(d.hit2)

d.hit.mean1$exp = "exp1"
d.hit.mean2$exp = "exp2"

d.hit.mean = rbind(d.hit.mean1, d.hit.mean2)

t.test(d.hit.mean[d.hit.mean$cond=="binoProbe",]$value ~ d.hit.mean[d.hit.mean$cond=="binoProbe",]$exp  , paired = TRUE    )
t.test(d.hit.mean[d.hit.mean$cond=="probeLeft",]$value ~ d.hit.mean[d.hit.mean$cond=="probeLeft",]$exp  , paired = TRUE    )
t.test(d.hit.mean[d.hit.mean$cond=="probeRight",]$value ~ d.hit.mean[d.hit.mean$cond=="probeRight",]$exp    , paired = TRUE  )



d.fa1$exp = "exp1"
d.fa2$exp = "exp2"
d.fa = rbind(d.fa1, d.fa2)

summary(aov(value ~ exp * as.factor(delay) * cond+ Error( id/exp + id/as.factor(delay)), data=d.fa))



d.fa.mean1 = mean_by_cond(d.fa1)
d.fa.mean2 = mean_by_cond(d.fa2)

d.fa.mean1$exp = "exp1"
d.fa.mean1 = d.fa.mean1[order(d.fa.mean1$id),]
d.fa.mean2$exp = "exp2"
d.fa.mean2 = d.fa.mean2[order(d.fa.mean2$id),]
d.fa.mean = rbind(d.fa.mean1, d.fa.mean2)

res1 = t.test(d.fa.mean[d.fa.mean$cond=="binoProbe",]$value ~ d.fa.mean[d.fa.mean$cond=="binoProbe",]$exp  , paired = TRUE )
res2 = t.test(d.fa.mean[d.fa.mean$cond=="probeLeft",]$value ~ d.fa.mean[d.fa.mean$cond=="probeLeft",]$exp  , paired = TRUE    )
res3 = t.test(d.fa.mean[d.fa.mean$cond=="probeRight",]$value ~ d.fa.mean[d.fa.mean$cond=="probeRight",]$exp   , paired = TRUE   )

# to calculate corrected p-value, simply multiplied by 3, 
# because we perfomerd t-test 3-times
pairwise.t.test( d.fa.mean1[d.fa.mean1$cond=="binoProbe",]$value,  d.fa.mean1[d.fa.mean1$cond=="binoProbe",]$value  , paired = TRUE　)


#-------------------------------------------------------------------------------------------------#
### direct comparison between experimental 1 and 2
### Analysis on incorrect rates have been already done
### so, focus on correct rates (experiments itself were totally same)

d.hit1 = get.d.rate.hit(d_limit1[d_limit1$rtGo > .050,])

d.hit2 = get.d.rate.hit(d_limit2[d_limit2$rtGo > .050,])

d.hit1$exp =  "exp1"
d.hit2$exp =  "exp2"
d.hit = rbind(d.hit1, d.hit2)

d.hit.mean1 = mean_by_cond(d.hit1)
d.hit.mean2 = mean_by_cond(d.hit2)

d.hit.mean1$exp = "exp1"
d.hit.mean2$exp = "exp2"

d.hit.mean = rbind(d.hit.mean1, d.hit.mean2)

res1 = t.test(d.hit.mean[d.hit.mean$cond=="binoProbe",]$value ~ d.hit.mean[d.hit.mean$cond=="binoProbe",]$exp  , paired = TRUE    )
res2 = t.test(d.hit.mean[d.hit.mean$cond=="probeLeft",]$value ~ d.hit.mean[d.hit.mean$cond=="probeLeft",]$exp  , paired = TRUE    )
res3 = t.test(d.hit.mean[d.hit.mean$cond=="probeRight",]$value ~ d.hit.mean[d.hit.mean$cond=="probeRight",]$exp    , paired = TRUE  )

p = c(res1$p.value,
  res2$p.value,
  res3$p.value)

# Using Holm's method for p-adjustment
# binoProbe, probeLeft, probeRight
p.adjust(p, "holm")



#-------------------------------------------------------------------------------------------------#
#-------------------------------- Evidence Accumulation Process ----------------------------------#
#-------------------------------------------------------------------------------------------------#
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
res = readRDS("result.rds")

d_normal1_correct = d_normal1[d_normal1$reward==1,]

# RT disribution
p = ggplot() + 
  geom_histogram(aes(x=(d_normal1_correct$rt), y=..density..), bins=30, fill="gray", colour="black") + 
  geom_freqpoly(aes(x=(res$pred), y=..density..), colour="red", alpha=1, bins=30, lwd = 2) +
  xlim(0,5) +
  TM + xlab(NULL) + ylab(NULL)  
p
ggsave("fig9a.png", p, dpi = 600)


