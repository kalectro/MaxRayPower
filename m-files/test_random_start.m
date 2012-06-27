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

fid = fopen('optimization_start.txt','a+');
fprintf(fid, '##########################\n');
fprintf(fid, 'Parameter der Optimierung:\n');
fprintf(fid, '--------------------------\n');
fprintf(fid, 'modus.ordnung: %d\n', modus.ordnung);
fprintf(fid, 'modus.absorber_optimieren: %d\n', modus.absorber_optimieren);
fprintf(fid, 'modus.grossen_spiegel_optimieren: %d\n', modus.grossen_spiegel_optimieren);
fprintf(fid, 'modus.kleinen_spiegel_optimieren: %d\n', modus.kleinen_spiegel_optimieren);
fprintf(fid, 'modus.spiegelpfad_radius_optimieren: %d\n', modus.spiegelpfad_radius_optimieren);
fprintf(fid, 'modus.num_rays_per_row: %d\n', modus.num_rays_per_row);
fprintf(fid, 'modus.number_zeitpunkte: %d\n', modus.number_zeitpunkte);
fprintf(fid, 'A = [ ');
fprintf(fid,'%f ',A);
fprintf(fid,']\n##########################\n\n');
fclose(fid);
 
% Objective_function(A, modus);