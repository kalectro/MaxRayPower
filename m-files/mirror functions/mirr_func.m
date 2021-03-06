function mirr_height = mirr_func(x,y,spiegel_gross_parameter)

spiegel_gross_parameter = [0 spiegel_gross_parameter];

Ordnung = sqrt(length(spiegel_gross_parameter))-1;
exp_vec = 0:Ordnung;
x_vec = x.^(exp_vec);
y_vec = y.^(exp_vec);

combination_matrix = x_vec' * y_vec;
combination_vector = combination_matrix(:);
mirr_height = spiegel_gross_parameter * combination_vector;

end