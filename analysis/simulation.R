library(rstan)
library(tidyverse)
library(R.matlab)
library(lme4)
library(car)
rm(list=ls())

d_normal = read.csv("EXP1_NORMAL.csv")
d_normal = d_normal[d_normal$initDone==1,]
d_partial_normal = d_normal[d_normal$reward == 1, ]

# stan fitting------------------------------------------------------------------------------------#

create_stanData = function(d_stan){
  stanData = list(rt=d_stan$rt, res=rep(1, length(d_stan$rt)),
                  LENGTH = length(d_stan$rt), NUM_CHOICES=1, id = as.integer(as.factor(d_stan$id)), N_id = length(unique(d_stan$id)))
  return(stanData)
}


return_badR_hat = function(fit){
  print(
    summary(fit)$summary[,"Rhat"][which(summary(fit)$summary[,"Rhat"] >= 1.1)]
  )
}

stan_fit = function(stanData){
  fit = stan(
    file = 'LBA_mixture.stan', 
    seed = 1234,
    data = stanData,
    warmup = 50000,
    iter = 55000,
    chains = 4,
    thin =1)
  return(fit)
}

rstan_options(auto_write=TRUE)
options(mc.cores = parallel::detectCores())

fit = stan_fit(create_stanData(d_partial_normal))
res = rstan::extract(fit)
saveRDS(res, file="result.rds")



# simulation------------------------------------------------------------------------------------#
# tau_constant
TM = theme(axis.text.x = element_text(family = "Times New Roman",size = rel(6), colour = "black"),
           axis.text.y = element_text(family = "Times New Roman",size = rel(6), colour = "black"),
           axis.title.x = element_text(family = "Times New Roman",size = rel(6), colour = "black", vjust = .1),
           axis.title.y = element_text(family = "Times New Roman",size = rel(6), colour = "black"),
           legend.position = "none",
           panel.grid = element_blank(),
           panel.background = element_rect(fill="white"),
           panel.border = element_rect(colour = "black", fill=NA, size=1.5),
           axis.ticks = element_line(colour = "black", size=1.3))


res = readRDS("result.rds")
source("simulation_fun.R")

N = 10000
deltas = seq(0,1 + max(res$A), length=20)
df = get_df.rate(res, N=N, deltas=deltas)

delays = sort(unique(d_limit$delay))

d.rate = split(df, df$delta) %>% lapply(., function(df){
  temp = df[df$resp!=0,]
  temp$delayf = factor(as.factor(temp$delay), levels = as.character(sort(unique(d_limit$delay))))
  p = table(temp$resp,temp$delayf)[1,]/colSums(table(temp$resp,temp$delayf))
  p[is.nan(p)] = 0
  d.rate = data.frame(punish = p, delay = as.numeric(names(p)), delta = temp$delta[1])
  return(d.rate)
}) %>% do.call(rbind,.)



d.rate_correct = split(df, df$delta) %>% lapply(., function(df){
  temp = df
  temp$delayf = factor(as.factor(temp$delay), levels = as.character(sort(unique(d_limit$delay))))
  p = table(temp$resp,temp$delayf)[1,]/colSums(table(temp$resp,temp$delayf))
  p[is.nan(p)] = 0
  d.rate = data.frame(reward = p, delay = as.numeric(names(p)), delta = temp$delta[1])
  return(d.rate)
}) %>% do.call(rbind,.)



d.fa1 = get.d.rate.fa(d_limit[d_limit$rtNogo > .050,])
d.fa1.mean = get_mean_rate(d.fa1)

d.hit1 = get.d.rate.hit(d_limit[d_limit$rtGo > .050,])
d.hit1.mean = get_mean_rate(d.hit1)

unique(d.rate$delta)

p = ggplot() +
  geom_line(data=d.rate[d.rate$delta == max(d.rate$delta),], aes(x=delay, y=punish), lwd=2) +
  ylim(0, .8) + TM + xlab(NULL) + ylab(NULL) 
p


ggsave("fig9c.png", p)



p = ggplot() +
  geom_line(data=d.rate_correct[d.rate_correct$delta == max(d.rate_correct$delta),], 
            aes(x=delay, y=reward), lwd=2) +
  ylim(0, 1) + TM + xlab(NULL) + ylab(NULL) + 
  viridis::scale_color_viridis()
p

ggsave("fig9b.png", p)

