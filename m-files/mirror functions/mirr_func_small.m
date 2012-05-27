function mirr_height = mirr_func_small(x,y,spiegel_klein_parameter_ordnung2)
% x=k(1);
% y=k(2);
a=spiegel_klein_parameter_ordnung2(1);
b=spiegel_klein_parameter_ordnung2(2);
c=spiegel_klein_parameter_ordnung2(3);
d=spiegel_klein_parameter_ordnung2(4);
e=spiegel_klein_parameter_ordnung2(5);

mirr_height = a*x^2 + b*y^2 + c*x*y + d*x + e*y;

% mirr_height = (x^2 + y^2) / 20;
end