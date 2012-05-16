function [C,Ceq] = NONLCON_ellipse(X,ellipt_constants)
a=ellipt_constants(1);
b=ellipt_constants(2);
c=ellipt_constants(3);
d=ellipt_constants(4);
e=ellipt_constants(5);
r=ellipt_constants(6);

x=X(1);
y=X(2);

    C = a*x^2 + b*y^2 + c*x*y + d*x + e*y - r^2;
    Ceq = 0;
end