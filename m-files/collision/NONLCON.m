function [C,Ceq] = NONLCON(X)
    global mirr_radius;
    C = X(1)^2 + X(2)^2 - mirr_radius^2;
    Ceq = 0;
end