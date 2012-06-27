close all;
modus.ordnung = 2;
modus.absorber_optimieren = false;
modus.grossen_spiegel_optimieren = true;
modus.kleinen_spiegel_optimieren = true;
modus.spiegelpfad_radius_optimieren = true;
modus.num_rays_per_row = 40;
modus.number_zeitpunkte = 10;

A = [0 0 0 1/20 1/20 0 0 0 ...
     0 0 0 1/20 1/20 0 0 0 ...
     2];
 
Objective_function(A, modus);