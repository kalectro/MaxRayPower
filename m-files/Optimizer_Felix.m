%  Modus einstellen
modus.absorber_optimieren = false;
modus.kleinen_spiegel_optimieren = false;
modus.grossen_spiegel_optimieren = false;
modus.spiegelpfad_radius_optimieren = false;
modus.num_rays_per_row = 100;
modus.number_zeitpunkte = 15;
% Ordnung der Spiegelfunktion
modus.ordnung = 2;

%SPECIAL!
modus.y_component = true;

%A ist bloss die y-Komponente des grossen Spiegels
A = 0;

% Optimierer-Parameter festlegen
options = optimset('PlotFcns',@optimplotfval,'Display','iter','MaxFunEvals',1000);

[A, FVAL] = fminbnd(@(x)Objective_function(x,modus),-2,2,options);

A

FVAL

