function [C, Ceq] = elliptic_constraints(A, modus)
if(modus.absorber_optimieren)
    a=A(1);
    b=A(2);
    c=A(3);
    C = -(4*b*a - c^2) + 1e-6;
else
    C=[];
end

Ceq = [];
end