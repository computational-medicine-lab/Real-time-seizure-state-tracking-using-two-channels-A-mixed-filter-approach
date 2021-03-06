function [alph, beta, gamma, rho, sig2e, sig2v, xnew, signewsq, muone, a] = mixedlearningcurve(N, Z, background_prob, rhog, alphag, betag, sig2eg, sig2vg)
%Script to run the subroutines for binomial EM
%Updated by Anne Smith, Nov 29, 2010
%Michael Prerau
%Anne Smith, October 15th, 2003
% 
%variables to be reset by user:
%        N                        The discrete process
%        cornum (1 by num_trials) vector of number correct at each trial N(1,:)
%        totnum (1 by num_trials) total number that could be correct at each trial
%                                 N(2,:)
%
%        Z                        The reaction time (continuous)
%
%        background_prob          probabilty of correct by chance (bias)
%
%        sigv                     sqrt(variance) of random walk

%other variables
%        x, s   (vectors)         hidden process and its variance (forward estimate)
%        xnew, signewsq (vectors) hidden process and its variance (backward estimate)
%        newsigsq                 estimate of random walk variance from EM 
%        p      (vectors)         mode of prob correct estimate from forward filter
%        p05,p95   (vectors)      conf limits of prob correct estimate from forward filter
%        b      (vectors)         mode of prob correct estimate from backward filter
%        b05,b95   (vectors)      conf limits of prob correct estimate from backward filter

stats = [];
xfilt=[];
cornum = N(1,:);
totnum = N(2,:);


%PARAMETERS
%starting guess for rho
rho = rhog;  
%starting guess for beta
beta = betag;  
%starting guess for alpha
alph = alphag;  
%starting guess for sige = sqrt(sigma_eps squared)
sig2e = sig2eg;                    
%starting guess for sige = sqrt(sigma_v squared)
sig2v = sig2vg;  
gamma=0;
%set the value of mu from the chance of correct
muone = log(background_prob/(1-background_prob)) ;

%convergence criterion for sigma_eps_squared
cvgce_crit = 1e-6;

%----------------------------------------------------------------------------------
%loop through EM algorithm 

xguess = 0;  %starting point for random walk x


for jk=1:3000
    
    %forward filter 
    [xfilt, sfilt, xold, sold] = ...
        recfi   lter(N, Z, sig2e, sig2v, xguess, muone, rho, beta, alph, gamma);
    
    %backward filter
    [xnew, signewsq, a] = backest(xfilt, xold, sfilt, sold);
     
    %maximization step
    [alph, beta, gamma, rho, sig2e, sig2v, xnew, muone] = ...
         m_step(N, Z, signewsq, xnew, a, muone);

   
    newsigsq(jk) = sig2v;
    
    signewsq(1) = sig2v;    %updates the initial value of the latent process variance
    
    xnew1save(jk) = xnew(1);
    
    %check for convergence of parameters
    stats = [stats; [alph beta sig2e sig2v]] ;
    if(jk>1)
        diffsv = stats(jk,:) - stats(jk-1,:);
        a1   = mean(abs(diffsv));
        if( a1 < cvgce_crit )
            fprintf(2, 'EM converged after %d  \n', jk)
            break
        end
    end
    
    xguess = xnew(1);
    
end

if(jk == 3000)
    fprintf(2,'failed to converge after %d steps; convergence criterion was %f \n', jk, cvgce_crit)
end
failed=0;
fprintf(2,' alpha is %f, beta is %f, sigesq is %f, sigvsq is %f \n', alph, beta, sig2e, sig2v);

