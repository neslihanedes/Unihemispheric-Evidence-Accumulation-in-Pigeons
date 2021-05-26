#------------------------------------------------------------------------------------------------------------#
# define function of vector ver
perturb_by_delay = function(l, delay, v, s, A, tau){
  s = sample(s, 1)
  v = sample(v, 1)
  A = sample(A, 1)
  a = runif(1, 0, A)
  tau = sample(tau, 1)
  
  slope = -100
  while(slope < 0){
    slope = rnorm(1, v, s)
  }

  evidence_when_delay = (delay) * slope + a
  RT = tau +  (A + 1 - a)/slope
  
  

  if( RT <= delay ){
    resp = 0 # correctly respond to go
  }else if(RT > delay & l < evidence_when_delay){
    resp = 1 # incorrectly respond to no-go
  }else{
    resp = 2 # not respond to no-go
  }
  
  # obvious cases
  if(RT <= delay) resp = 0 
  if(RT > 5) resp = 2
  
  if(RT <= .05 ) resp = 3
  return(resp)
  
  
}


#------------------------------------------------------------------------------------------------------------#



# second function
get_dfRate = function(N, l, delays, v, s, A, tau){
  
  response = NULL
  for(i in 1:length(delays)){
    response = c(response,
                 replicate(N, perturb_by_delay(l, delays[i], v, s, A, tau))
    )
  }
  
  
  df = data.frame(resp = response,
                  delay = rep(delays, each=N), 
                  delta = l)
  
  
  # remove the fast response
  df = df[df$resp!=3, ]
  return(df)
}

#------------------------------------------------------------------------------------------------------------#


# simulation
get_df.rate = function(res, N, deltas){
  # simulation
  s = res$s
  v = res$v
  tau = res$tau
  A = res$A
  delays = sort(unique(d_limit$delay))
  
  df.rate = get_dfRate(N, deltas[1], delays, v, s, A, tau)
  for(i in 2:length(deltas)){
    df.rate = rbind(df.rate, get_dfRate(N, deltas[i], delays, v, s, A, tau))
  }
  
  return(df.rate)
}


#------------------------------------------------------------------------------------------------------------#