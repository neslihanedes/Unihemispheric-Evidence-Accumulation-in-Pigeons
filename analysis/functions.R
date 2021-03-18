### This is the supplementary file for analysis of helmet experiments ###
### which contains utility functions ###

#------------------------------------------------------------------------------------------------#
# get hit rates
get.d.rate.hit = function(d_limit){
  mat = split(d_limit, d_limit$id) %>% lapply(., function(d){
    tb = table(d$reward, d$trialType2, d$delay)
    mat = apply(tb, 3, function(arr) apply(arr, 2, function(v) v[2]/sum(v))) %>% t
    return(mat)
  }) 
  
  ids = unlist(lapply(mat, function(mat) nrow(mat)))
  
  d.rate = data.frame(do.call(rbind, mat), id=rep(names(ids), ids) %>% factor,
                      delay=rep(sort(unique(d_limit$delay)), length(unique(d_limit$id))))
  rownames(d.rate) = NULL
  d.rate = tidyr::gather(d.rate, "cond", "value", -delay, -id) 
  return(d.rate)
}

#------------------------------------------------------------------------------------------------#
# get FA rates
get.d.rate.fa = function(d_limit){
  d_limit = d_limit[d_limit$reward==0,]
  mat = split(d_limit, d_limit$id) %>% lapply(., function(d){
    tb = table(d$punish, d$trialType2, d$delay)
    mat = apply(tb, 3, function(arr) apply(arr, 2, function(v) v[2]/sum(v))) %>% t
    return(mat)
  }) 
  
  ids = unlist(lapply(mat, function(mat) nrow(mat)))
  
  d.rate = data.frame(do.call(rbind, mat), id=rep(names(ids), ids) %>% factor,
                      delay=rep(sort(unique(d_limit$delay)), length(unique(d_limit$id))))
  rownames(d.rate) = NULL
  d.rate = tidyr::gather(d.rate, "cond", "value", -delay, -id) 
  return(d.rate)
}


#------------------------------------------------------------------------------------------------#
# get mean rates with SE
get_mean_rate = function(d.rate){
  df = split(d.rate, d.rate$cond) %>% lapply(., function(d.rate){
    se = tapply(d.rate$value, d.rate$delay, sd)/sqrt(length(unique(d.rate$id)))
    df = data.frame(mean = tapply(d.rate$value, d.rate$delay, mean),
                    se = se, cond = d.rate$cond[1],
                    delay = sort(unique(d.rate$delay))
    )
    return(df)
  }) %>% do.call(rbind,.)
  return(df)
}

#------------------------------------------------------------------------------------------------#
# multicomp for hit rates at each delays
multcomp.hit = function(d, delay){
  mod = glmer(reward ~ trialType2 + (1|id), data=d[d$delay==delay,], family=binomial)
  return(summary(glht(mod, linfct=mcp(trialType2= "Tukey"))))
}

#------------------------------------------------------------------------------------------------#
# multicomp for hit rates at each delays
multcomp.fa = function(d, delay){
  mod = glmer(punish ~ trialType2 + (1|id), data=d[d$delay==delay & d$reward==0,], family=binomial)
  return(summary(glht(mod, linfct=mcp(trialType2= "Tukey"))))
}


#------------------------------------------------------------------------------------------------#
mean_by_cond = function(d){
  split(d, d$id) %>% lapply(.,function(d){
    data.frame(value = tapply(d$value, d$cond, mean),
               id = d$id[1],
               cond = names(tapply(d$value, d$cond, mean)))
  }) %>% do.call(rbind,.)
}

#------------------------------------------------------------------------------------------------#
mean_by_delay = function(d){
  split(d, d$id) %>% lapply(.,function(d){
    data.frame(value = tapply(d$value, d$delay, mean),
               id = d$id[1],
               delay = names(tapply(d$value, d$delay, mean)))
  }) %>% do.call(rbind,.)
}


#------------------------------------------------------------------------------------------------#
get.d.rt.fa = function(d_partial){
  
  d.rate = split(d_partial, d_partial$id) %>% lapply(., function(d_partial){
    
    d.rate = data.frame(value = tapply( d_partial$rtNogo, d_partial$trialType2, mean),
                        id = d_partial$id[1], 
                        cond = names(tapply( d_partial$rtNogo, d_partial$trialType2, mean))
    )
    return(d.rate)
  }) %>% do.call(rbind,.)
  
  return(d.rate)
}


get.d.rt.fa.mean = function(d.rt.fa){
  
  d.rate.mean = data.frame( value = tapply(d.rt.fa$value, d.rt.fa$cond, mean),
                            se = tapply(d.rt.fa$value, d.rt.fa$cond, mean)/sqrt(length(unique(d.rt.fa$id))),
                            cond = names(tapply(d.rt.fa$value, d.rt.fa$cond, mean)))
  return(d.rate.mean)
}

#------------------------------------------------------------------------------------------------#



df(.887,1,23)
7.041/ 7.942
