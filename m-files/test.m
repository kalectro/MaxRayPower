close all;
modus.ordnung = 2;
modus.absorber_optimieren = false;
modus.kleinen_spiegel_optimieren = true;
modus.grossen_spiegel_optimieren = true;
modus.spiegelpfad_radius_optimieren = true;
modus.num_rays_per_row = 20;
modus.number_zeitpunkte = 5;

A = [0 1/20 0 0 0 1/20 0 0 0 1/20 0 0 0 1/20 0 0 1];
Objective_function(A, modus);