// STAN code for linear ballistic accumulator model
// codes modified from this page 
// https://ykunisato.github.io/lbaStan/lbaStan.html (Japanese)
// and 
// https://www.vanderbilt.edu/psychological_sciences/bio/jeff-annis


functions{
  
  real lba_pdf(real t, real b, real A, real v, real s){
    //PDF of the LBA model
    
    real b_A_tv_ts;
    real b_tv_ts;
    real term_1;
    real term_2;
    real term_3;
    real term_4;
    real pdf;
    
    b_A_tv_ts = (b - A - t * v) / (t * s);
    b_tv_ts = (b - t * v) / (t * s);
    term_1 = v * Phi(b_A_tv_ts);
    term_2 = s * exp(normal_lpdf(b_A_tv_ts|0, 1)); 
    term_3 =v * Phi(b_tv_ts);
    term_4 = s * exp(normal_lpdf(b_tv_ts|0, 1)); 
    pdf = (1 / A) * (-term_1 + term_2 + term_3 - term_4);
    
    return pdf;
  }
  
  real lba_cdf(real t, real b, real A, real v, real s){
    //CDF of the LBA model
    
    real b_A_tv;
    real b_tv;
    real ts;
    real term_1;
    real term_2;
    real term_3;
    real term_4;
    real cdf;	
    
    b_A_tv = b - A - t*v;
    b_tv = b - t * v;
    ts = t*s;
    term_1 = b_A_tv / A * Phi(b_A_tv / ts);	
    term_2 = b_tv / A * Phi(b_tv / ts);
    term_3 = ts / A * exp(normal_lpdf(b_A_tv / ts|0, 1)); 
    term_4 = ts / A * exp(normal_lpdf(b_tv / ts|0, 1)); 
    cdf = 1 + term_1 - term_2 + term_3 - term_4;
    
    return cdf;
    
  }
  
  real lba_lpdf(real rt, real res, real k, real A, vector v, real s, real tau){
    
    real t;
    real b;
    real cdf;
    real pdf;		
    real prob;
    real out;
    real prob_neg;
    
    b = A + k;
    t = rt - tau;
    
    if(t > 0){			
      cdf = 1;
      for(j in 1 : num_elements(v)){
        if(res == j){
          pdf = lba_pdf(t, b, A, v[j], s);
        }else{	
          cdf = (1 - lba_cdf(t, b, A, v[j], s)) * cdf;
        }
      }
      
      prob_neg = 1;
      for(j in 1 : num_elements(v)){
        prob_neg = Phi( - v[j] / s) * prob_neg;    
      }
      prob = pdf * cdf;		
      prob = prob / (1 - prob_neg);	
      if(prob < 1e-10){
        prob = 1e-10;				
      }
    }else{
      prob = 1e-10;			
    }
    out = log(prob);
    return out;		
  }
  
  vector lba_rng(real k, real A, vector v, real s, real tau){
    
    int get_pos_drift;	
    int no_pos_drift;
    int get_first_pos;
    vector[num_elements(v)] drift;
    int max_iter;
    int iter;
    real start[num_elements(v)];
    real ttf[num_elements(v)];
    int resp[num_elements(v)];
    real rt;
    vector[2] pred;
    real b;
    
    //try to get a positive drift rate
    get_pos_drift = 1;
    no_pos_drift = 0;
    max_iter = 1000;
    iter = 0;
    while(get_pos_drift){
      for(j in 1 : num_elements(v)){
        drift[j] = normal_rng(v[j],s);
        if(drift[j] > 0){
          get_pos_drift = 0;
        }
      }
      iter = iter + 1;
      if(iter > max_iter){
        get_pos_drift = 0;
        no_pos_drift = 1;
      }	
    }
    //if both drift rates are <= 0
    //return an infinite response time
    if(no_pos_drift){
      pred[1] = - 1;
      pred[2] = - 1;
    }else{
      b = A + k;
      for(i in 1:num_elements(v)){
        //start time of each accumulator	
        start[i] = 0; // uniform_rng(0,A);
        //finish times
        ttf[i] = (b-start[i])/drift[i];
      }
      //rt is the fastest accumulator finish time	
      //if one is negative get the positive drift
      resp = sort_indices_asc(ttf);
      ttf = sort_asc(ttf);
      get_first_pos = 1;
      iter = 1;
      while(get_first_pos){
        if(ttf[iter] > 0){
          pred[1] = ttf[iter] + tau;
          pred[2] = resp[iter]; 
          get_first_pos = 0;
        }
        iter = iter + 1;
      }
    }
    return pred;	
  }
}

data{
  int LENGTH;
  int NUM_CHOICES;
  vector[LENGTH] rt;
  vector[LENGTH] res;
}

parameters {
  real<lower=0> A;
  vector<lower=0>[NUM_CHOICES] v;
  real<lower=0> s;
  real tau;
  
  simplex[2] Pi;
  real<lower=0> rate;
}

transformed parameters{
  real k;
  k = 1;
}

model {
  A ~ normal(0, 3)T[0,];
  tau ~ normal(0, 1)T[0,]; // changed since parameters fell into local optima
  //tau ~ uniform(0, .6);
  s ~ normal(1, 3)T[0,];
  
  for(n in 1:NUM_CHOICES){
    v[n] ~ normal(2, 1)T[0,];
  }
  
  for(m in 1:LENGTH){
    real lp[2];
    lp[1] = exponential_lpdf(rt[m] | rate);
    lp[2] = lba_lpdf(rt[m] | res[m], k, A, v, s, tau);
    // rt[m] ~ lba(res[m], k, A, v, s, tau);
    target += log_sum_exp(lp);
  }
}

generated quantities {
  real pred;
  real z;
  // vector[LENGTH] log_lik;
  
  
  
  for(i in 1 : LENGTH){
    z = bernoulli_rng(Pi[1]);
    if(z == 1){
      pred = exponential_rng(rate);
    }else{
      vector[2] LBA;
      LBA = lba_rng(k, A, v, s, tau);
      pred = LBA[1];
    }
    // log_lik[i] = lba_lpdf(rt[i] | res[i], k, A, v, s, tau);
  }
}


