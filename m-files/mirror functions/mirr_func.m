function mirr_height = mirr_func(x,y,spiegel_gross_parameter_ordnung2)
% x=k(1);
% y=k(2);
a=spiegel_gross_parameter_ordnung2(1);
b=spiegel_gross_parameter_ordnung2(2);
c=spiegel_gross_parameter_ordnung2(3);
d=spiegel_gross_parameter_ordnung2(4);
e=spiegel_gross_parameter_ordnung2(5);

mirr_height = a*x^2 + b*y^2 + c*x*y + d*x + e*y;
% mirr_height = (x^2 + y^2) / 20;
end