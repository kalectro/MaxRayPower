function optimizer
modus.ordnung = 3;

start_vec = zeros(1,(modus.ordnung+1)^2);
start_vec([3 (modus.ordnung*2+3)]) = 1/20;
%neuer default / startvektor : [0 0 1/20 0 0 0 1/20 0 0] bei Ordnung 2

%A=[1/20 1/20 0 0 0 1/20 1/20 0 0 0];
%A = [0.0350 0.0519 0.0005 0.0001 0.0003 0.0472 0.0504 0.0001 0.0003 0.0001];
% A = [ 0.0358 0.0512 0.0005 0.0001 0.0003 0.0469 0.0486 0.0001 0.0003 0.0001]
% A= [0.0380000000000000 0.0497000000000000 0.000500000000000000 0.000100000000000000 0.000300000000000000 0.0472000000000000 0.0471000000000000 0.000100000000000000 0.000300000000000000 0.000100000000000000];
%3rd grade
% A=[A 0 0 0 0 0 0 0 0];


% number_big_mirr_args = 
modus.absorber_optimieren = false;
modus.kleinen_spiegel_optimieren = false;
modus.zweite_ordnung = false;
modus.dritte_ordnung = true;

A = start_vec(2:end);

options = optimset('PlotFcns',@optimplotfval,'Display','iter','MaxFunEvals',1000);
% [X,FVAL,~,OUTPUT] = patternsearch(@(x)distance_ray_mirror_anonym(x,ray,mirror),...
x_out = fminsearch(@(x)Objective_function(x,modus),A,options);
x_out
end