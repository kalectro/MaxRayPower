function optimizer
A=[1/20 1/20 0 0 0 1/20 1/20 0 0 0];
options = optimset('PlotFcns',@optimplotfval,'Display','on','MaxFunEvals',100);
x = fminsearch(@Objective_function,A,options);
x
end