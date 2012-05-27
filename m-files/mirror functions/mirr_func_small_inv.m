function mirr_height = mirr_func_small_inv(x,y,spiegel_klein_parameter_ordnung2)
% mirr_height = (5*x^2 + 4*y^2 + 3*x*y + 2*x + 1*y) / 1000;
mirr_height = -mirr_func_small(x,y,spiegel_klein_parameter_ordnung2);
end