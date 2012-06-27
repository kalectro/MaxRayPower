close all;
modus.ordnung = 2;
modus.absorber_optimieren = false;
modus.grossen_spiegel_optimieren = true;
modus.kleinen_spiegel_optimieren = true;
modus.spiegelpfad_radius_optimieren = true;
modus.num_rays_per_row = 20;
modus.number_zeitpunkte = 15;

randomNum = 0;

numParam = (modus.ordnung+1)^2-1;

if modus.absorber_optimieren
    randomNum = randomNum + 6;
end

if modus.grossen_spiegel_optimieren
    randomNum = randomNum + numParam;
end

if modus.kleinen_spiegel_optimieren
    randomNum = randomNum + numParam;
end

A = [randi(1000,1,randomNum)/1000 , (randi(45,1,1)/10 + .5)];
 
Objective_function(A, modus);