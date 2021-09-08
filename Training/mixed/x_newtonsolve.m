function [xres, timefail] = x_newtonsolve(muone, xold, sig2old, cornum, z, alpha, beta, rho,gamma, sig2e);

%Solve for x hat using Newton's method
learning_rate=2;
timefail = 1; %time when the algorithm fails 

%Set the initial guess for x hat to the old value of x
while timefail==1 
    clearvars -except muone xold sig2old cornum z alpha beta rho gamma sig2e learning_rate timefail
    learning_rate=learning_rate/2;
    x(1)=xold-rho*xold-((sig2old*beta)/(sig2old*beta^2+sig2e))*(z-alpha-beta*rho*xold)-...
        ((sig2e*sig2old)/(sig2old*beta^2+sig2e))*...
        (cornum - exp(muone)*exp(gamma*xold)/(1+exp(muone)*exp(gamma*xold)));

    for i = 1:200
        %Find x hat
        g(i) = x(i)-rho*xold-((sig2old*beta)/(sig2old*beta^2+sig2e))*(z-alpha-beta*rho*x(i))-...
            ((sig2e*sig2old)/(sig2old*beta^2+sig2e))*...
            (cornum - exp(muone)*exp(gamma*x(i))/(1+exp(muone)*exp(gamma*x(i))));

        %Find the first derivative
        gprime(i) = 1+((sig2e*sig2old)/(sig2old*beta^2+sig2e))*...
            (gamma*exp(muone+gamma*x(i)))/(1+exp(muone+gamma*x(i)))^2;

        %newton's method
        x(i+1)=x(i)-learning_rate*g(i)/gprime(i);
        xres=x(i+1); %Save the result

        %Check for convergence to zero
        if abs(xres-x(i))<1e-14
            timefail = 0; 
            return
        end
    end
end
