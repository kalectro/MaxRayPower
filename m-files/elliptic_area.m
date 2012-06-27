function ell_area = elliptic_area(parameters)
a=parameters(1);
b=parameters(2);
c=parameters(3);
d=parameters(4);
e=parameters(5);
R=parameters(6);
%C = a*x^2 + b*y^2 + c*x*y + d*x + e*y - r^2;


x_1 = (c*e-2*b*d)/(4*b*a - c^2);
y_1 = (c*d-2*a*e)/(4*b*a - c^2);

r = - R^2 - a*x_1^2 - c*x_1*y_1 - b*y_1^2;

A = a/r;
B = c/r;
C = b/r;

ell_area = 2*pi/sqrt(4*A*C-B^2);
% ell_area = pi/sqrt(4*A*C-B^2);
end