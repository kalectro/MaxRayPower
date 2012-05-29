function mirr_height = mirr_func(x,y,spiegel_gross_parameter)
% x=k(1);
% y=k(2);
a=spiegel_gross_parameter(1);
b=spiegel_gross_parameter(2);
c=spiegel_gross_parameter(3);
d=spiegel_gross_parameter(4);
e=spiegel_gross_parameter(5);
if length(spiegel_gross_parameter) == 9
    f=spiegel_gross_parameter(6);
    g=spiegel_gross_parameter(7);
    h=spiegel_gross_parameter(8);
    i=spiegel_gross_parameter(9);
else
    f=0;
    g=0;
    h=0;
    i=0;
end

mirr_height = a*x^2 + b*y^2 + c*x*y + d*x + e*y ...
    + f*x^3 + g*y^3 + h*(x^2)*y + i*(y^2)*x; %additional 3rd grade part

% mirr_height = (x^2 + y^2) / 20;
end