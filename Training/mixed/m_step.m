function  [alph, beta, gamma, rho, sig2e, sig2v, xnew, muone] ... 
    = m_step(N, Z, signewsq, xnew, a, muone, startflag);


K = length(N);

gamma=1; %fixed

%added by ACS 12/02/2010 to deal with different ics on x
%EM convergence is very sensitive to specification of this part
M          = K+1;  
xnewt      = xnew(3:M);
xnewtm1    = xnew(2:M-1);
signewsqt  = signewsq(3:M);
A          = a(2:end);
covcalc    = signewsqt.*A;
term1      = sum(xnewt.^2) + sum(signewsqt);
term2      = sum(covcalc) + sum(xnewt.*xnewtm1);

if (startflag  == 0)                   %fixed initial condition
 term3      = 2*xnew(2)*xnew(2) + 2*signewsq(2);
 term4      = xnew(end)^2 + signewsq(end);
elseif( startflag == 2)                %estimated initial condition
 term3      = 1*xnew(2)*xnew(2) + 2*signewsq(2);
 term4      = xnew(end)^2 + signewsq(end);
 M = M-1;
end

sig2v   = (2*(term1-term2)+term3-term4)/M;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WkK = sum(signewsq(2:end)+xnew(2:end).^2);
Wkm1K = xnew(1)^2+sum(signewsq(2:end-1)+xnew(2:end-1).^2);
Wkm1kK =xnew(1)*xnew(2)+sum(a(1:end-1).*signewsq(3:end)+xnew(2:end-1).*xnew(3:end)); 
%  

ab = inv([K sum(xnew(2:end));sum(xnew(2:end)) WkK])*[sum(Z);sum(xnew(2:end).*Z)];
alph =ab(1);
beta  =ab(2);
sig2e = (1/(K))*(sum(Z.^2)+K*alph^2+beta^2*WkK-2*alph*sum(Z)-2*beta*sum(xnew(2:end).*Z)+2*alph*beta*sum(xnew(2:end)));

rho = 1; %fixed

