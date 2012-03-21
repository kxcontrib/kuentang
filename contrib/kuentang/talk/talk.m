
kappa=0.2
theta=0.0
eta = 0.05
obj = hwv( kappa, theta , eta,'StartState',0.1)
nPeriods = 251;      % # of simulated observations
dt       =   1;      % time increment = 1 day
%rng(142857,'twister')
[S,T] = obj.simBySolution(nPeriods, 'DeltaTime', dt);
o=ones(size(S));
upp = theta+eta*o;
und = theta-eta*o;

plot(T(1:8:end),und(1:8:end),'.', ... 
     T,S, ... 
     T(1:8:end),upp(1:8:end),'.')
xlabel('Trading Day'), ylabel('Spread')
title('Pairs Trading')
legend('\theta - eta','dX=\kappa (\theta - X) + \eta dW', ...
    '\theta + eta')
