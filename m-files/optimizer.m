function finally = optimizer()
options = optimset('PlotFcns',@optimplotfval,'Display','iter','MaxFunEvals',1000);

% grobe Annäherung mit Funktionen zweiten Grades mit vielen  Startwerten
modus.ordnung = 2;

% 10 willkürliche Startwerte
start_vec(1,:) = [0 1/20 0 0 0 1/20 0 0 0 1/20 0 0 0 1/20 0 0 1];
start_vec(2,:) = [1/20 0 0 0 1/20 0 0 0 1/20 0 0 0 1/20 0 0 0 1];
start_vec(3,:) = [0 0 0 1/20 0 0 0 1/20 0 0 0 1/20 0 0 0 1/20 1];
start_vec(4,:) = [0 0 1/20 0 0 0 1/20 0 0 0 1/20 0 0 0 1/20 0 1];
start_vec(5,:) = [1/20 1/20 1/20 1/20 1/20 1/20 1/20 1/20 1/20 1/20 1/20 1/20 1/20 1/20 1/20 1/20 2];
start_vec(6,:) = [1/20 1/50 0 0 1/20 1/50 0 0 1/20 1/50 0 0 1/20 1/50 0 0 4];
start_vec(7,:) = [1/20 -1/20 0 0 1/20 -1/20 0 0 1/20 -1/20 0 0 1/20 -1/20 0 0 3];
start_vec(8,:) = [-1/40 -1/40 -1/40 -1/40 -1/40 -1/40 -1/40 -1/40 -1/40 -1/40 -1/40 -1/40 -1/40 -1/40 -1/40 -1/40 2];
start_vec(9,:) = [0 1/20 0 0 0 1/20 0 0 0 1/20 0 0 0 1/20 0 0 3];
start_vec(10,:)= [0 1/20 0 0 0 1/20 0 0 0 1/20 0 0 0 1/20 0 0 4];

modus.absorber_optimieren = false;
modus.kleinen_spiegel_optimieren = true;
modus.num_rays_per_row = 5;
modus.number_zeitpunkte = 5;

for i=1:4
    % Optimierung starten
    [x_grob, FVAL] = fminsearch(@(x)Objective_function(x,modus),start_vec(i,:),options);
    % FVAL am Anfang von x_grob anhängen und für später speichern
    Ergebnisse(:,i) = [FVAL x_grob]'
end

% finde die drei besten Optimierungen
Ergebnisse = sort(Ergebnisse,2)
% lösche die anderen
Ergebnisse = Ergebnisse(:,1:3)
% lösche die erreichten FunValues
Ergebnisse = Ergebnisse(2:end,:)
%liegende Parametervektoren
Ergebnisse=Ergebnisse'


modus.ordnung = 3;
start_neu = zeros(3,(modus.ordnung+1)^2);
for i= 1:3
    matrix_form = reshape([0 Ergebnisse(i,1:end-1)],modus.ordnung,modus.ordnung);
    temp = zeros(modus.ordnung + 1);
    temp(1:modus.ordnung,1:modus.ordnung)=matrix_form;
    temp=[temp(2:end) Ergebnisse(i,end)];
    start_neu(i,:)=temp;
end



%start_vec = zeros(1,(modus.ordnung+1)^2);
%start_vec([3 (modus.ordnung*2+3)]) = 1/20;
%neuer default / startvektor : [0 0 1/20 0 0 0 1/20 0 0] bei Ordnung 2

modus.absorber_optimieren = false;
modus.kleinen_spiegel_optimieren = true;
modus.num_rays_per_row = 30;
modus.number_zeitpunkte = 30;

% % Höhe vom großen Spiegel soll nicht optimiert werden
% A = start_vec(2:end);

for i=1:3
    [x_fein, FVAL] = fminsearch(@(x)Objective_function(x,modus),start_neu(i,:),options);
    finally(i,:) = [FVAL x_fein]'
end
end