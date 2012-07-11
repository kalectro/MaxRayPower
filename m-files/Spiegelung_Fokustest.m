function Spiegelung_Fokustest
% function zum Ausrechnen des Fokus f�r verschiedene Einstrahlwinkel
 close all

 %Fuer die Dokumentation: Bilder von der Seite in 2d und ohne zweiten
 %Spiegel
%  myplot_2d = true;
plotmode.smallmirr_axissystem = true;
plotmode.smallmirr = true;
 
% Parameter um den Ablauf zu beeinflussen
% theta_vector = -80:20:80;
% phi_vector = -80:20:80;
number_zeitpunkte=15;
num_rays_per_row = 40;

ord=2;

%Ergebnis vom Maxim Ordnung 2
% A = [ 3.773764 4.082476 -0.417852 1.099477 -0.247735 0.727536 0.877974 1.301105...%gro�er sp.
%     1.347643 -0.985132 0.098795 -0.063957 0.219685 -0.736024 0.537959 0.071259...%kleiner sp.
%     1.290853 ]; %radius
% A = [ 0.815000 0.906000 0.127000 0.914000 0.633000 0.098000 0.279000 0.547000 0.958000 0.965000 0.158000 0.971000 0.958000 0.486000 0.801000 0.142000 2.400000]
% spiegel_gross = [A(1:8) zeros(1,35-((ord+1)^2-1))];
% spiegel_klein = [A(9:16) zeros(1,35-((ord+1)^2-1))];
ellipt_parameters = [1 1 0 0 0 0.5];%parameter f�r die Form der Absorberellipse

% %Ergebnis von Kai(?) Ordnung 2, mit Absorber optim. und radius optim.
% A=[ 0.815000 0.906000 0.127000 0.914000 0.633000 0.098000...
%     0.279000 0.547000 0.958000 0.965000 0.158000 0.971000 0.958000 0.486000...
%     0.801000 0.142000 0.422000 0.916000 0.793000 0.960000 0.656000 0.036000...
%     4.400000];
% spiegel_gross = [A(1:8 +6) zeros(1,35-((ord+1)^2-1))];
% spiegel_klein = [A(9:16 +6) zeros(1,35-((ord+1)^2-1))];
% ellipt_parameters = A(1:6);

%Auffuellen
spiegel_gross = [[0 0.5 0 1/20 1/20 0 0 0] zeros(1,35-((ord+1)^2-1))];
spiegel_klein = [[0 0 0 1/20 1/20 0 0 0] zeros(1,35-((ord+1)^2-1))];

handle_to_mirror_function = @(x,y)mirr_func2(x,y,spiegel_gross);
small_mirr_hand = @(x,y)mirr_func2(x,y,spiegel_klein);
small_mirr_hand_inv = @(x,y)mirr_func_small_inv(x,y,spiegel_klein);

verbosity = 'verbose';

% Notwendige Initialisierungen
Leistung_gesamt = 0;
Leistung_Sonne = 0;
strahlen_gesamt = 0;
focus_line = [];
%mirr_borders are rectangular
global mirr_borders half_mirr_edge_length
half_mirr_edge_length = sqrt(10)/2; %10qm Grundflaeche
mirr_borders = [-half_mirr_edge_length half_mirr_edge_length -half_mirr_edge_length half_mirr_edge_length];
mirr_quadrat_equivalent = sqrt((mirr_borders(2)-mirr_borders(1))*(mirr_borders(4)-mirr_borders(3)));

radius=mirr_quadrat_equivalent;
% radius = A(end);

[x,y,z] = sphere;
[phi_vector, theta_vector] = make_phi_theta(number_zeitpunkte);


% %plot der Spiegeloberflaeche
% [rays_x rays_y] = meshgrid(linspace(mirr_borders(1), mirr_borders(2), 10));
% mirror_surface = zeros(10);
% for x_ind = 1:10
%     for y_ind = 1:10
%         mirror_surface(x_ind,y_ind) = handle_to_mirror_function(rays_x(x_ind,y_ind),rays_y(x_ind,y_ind));
%     end
% end
% hold on
% surf(rays_x,rays_y,mirror_surface,'FaceColor','red','EdgeColor','none','FaceAlpha',0.8);
% hold off
% axis vis3d image


%%%%%
%FOR-Schleife (geht alle Einstrahlwinkel durch)
%%%%%

for timestep_ind = 2:(length(phi_vector)-1)

% for timestep_ind = 9
% for theta = 0
%     phi = 30;
    theta = theta_vector(timestep_ind);
    phi = phi_vector(timestep_ind);
    %Leistung pro qm in Watt
    sol_intensty = solar_intensity(theta);
    %Leistung pro Strahl in Watt
    P_ray = 20*sol_intensty/(num_rays_per_row^2); %*20 weil die raymaker-Fl�che so gross ist
    P_max = 10*sol_intensty; %10qm k�nnen maximal erhitzt werden
    
%     if strcmp(verbosity,'verbose')
%         disp(['Werte um ' num2str(5+(15/number_zeitpunkte)*(timestep_ind-1)) ' Uhr'])
%     end
    %%%%%%%%%%%%%%%%%% Function call!
    % Strahlen generieren
    ray_paths = raymaker(phi, theta, num_rays_per_row,'nonverbose');
    %%%%%%%%%%%%%%%%%%

    %ZEITFRESSER (20sek bei 100 Strahlen)
    %Verbesserung 23.04. ->> 5,3sek bei 100 Strahlen
    %Verbesserung 20.05. ->> 0,1sek bei 100 Strahlen
    %Verbesserung 23.05. ->> 4  sek bei 16000 Strahlen
    %Weitere Verbesserung moeglich:
    %   1. Spiegel-z-Hoehe begrenzen
    %   2. Analytische Loesung fuer t, erste Nullstele mit NewtonRaphson finden,
    %      und dann Treffer von oben/unten unterscheiden
    %%%%%%%%%%%%%%%%%% Function call!
    % Kollisionen mit grossem Spiegel und grosse boundaries checken.
    [collision_points, ind_of_valid_rays] = collision_tracker_dychotom(ray_paths(:,1:2,:), handle_to_mirror_function);
    if isempty(ind_of_valid_rays) % wenn kein Strahl mehr existiert
        if strcmp(verbosity,'verbose')
        disp('Anzahl direkt absorbierter Strahlen: 0')
        disp('Anzahl sekund�r absorbierter Strahlen: 0')
        end
        continue  % naechster Winkel
    end
    ray_paths(:,3,ind_of_valid_rays) = collision_points;
    %%%%%%%%%%%%%%%%%%   
    
    %%%%%%%%%%%%%%%%%% Function call!
    % Reflektierte Richtung berechnen und in ray_paths eintragen.
    reflection1_direction = reflection(ray_paths(:,2:3,ind_of_valid_rays),handle_to_mirror_function, 'nonverbose');
    ray_paths(:,4,ind_of_valid_rays) = reflection1_direction;
    %%%%%%%%%%%%%%%%%%

    %Zeitfresser
    %Moeglichkeiten der Verbesserung:
    %1. Schnitte von Schlaeuchen in einer MxNxP - Matrix (Hough)
    %2. Gewichtung von Fokuspunkten nach: nahe Nachbarn: gut!, nachbarn weit
    %weg: boese! (z.B weight = sum(1/dist_to_neighbor_i)) over i
    %3. Gegen das Zeitfressen: jeder Strahl berechnet seinen Schnitt nur mit den
    %10 Strahlen, die ihm am n�chsten sind, bzw die ihm n�her als xy cm sind
    %%%%%%%%%%%%%%%%%% Function call!
    % Fokuspunkt berechnen
    focus = focus_of_rays_fast(ray_paths(:,3:4,ind_of_valid_rays), radius);
    %%%%%%%%%%%%%%%%%%
    
    %save rays that hit the big one directly
    ind_of_big_mirror_rays = ind_of_valid_rays;
    %%%%%%%%%%%%%%%%%%
    % vom kleinen Spiegel geblockte Strahlen verwerfen
    ind_of_valid_rays=discard_rays_blocked_by_small_mirror(ray_paths(:,1:2,:),focus,small_mirr_hand_inv);
    %%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%% Function call!
    % Direktabsorbtion
    [num_rays,~,~,absorption_points,ind_of_rays_that_are_pre_absorbed] =...
        absorber(...
        ray_paths(:,1:2,ind_of_valid_rays), ellipt_parameters, handle_to_mirror_function,...
        'nonverbose', ind_of_valid_rays);
    
    ray_paths(:,5:6,ind_of_rays_that_are_pre_absorbed)=ray_paths(:,1:2,ind_of_rays_that_are_pre_absorbed);  % der Vollst�ndigkeit halber, damit ein Plot m�glich ist
    ray_paths(:,7,ind_of_rays_that_are_pre_absorbed)=absorption_points;
    if strcmp(verbosity,'verbose')
        disp(['Anzahl direkt absorbierter Strahlen: ' int2str(num_rays)])
    end
    %%%%%%%%%%%%%%%%%%
    
    % Kollisionen mit gro�em Spiegel, die direkt absorbiert wurden nicht weiter beruecksichtigen.
    for ray_ind = 1:size(ind_of_rays_that_are_pre_absorbed,2)
        ind_of_valid_rays = ind_of_valid_rays(ind_of_valid_rays~=ind_of_rays_that_are_pre_absorbed(ray_ind)); 
    end
    %%%%%%%%%%%%%%%%%%   

    %%%%%%%%%%%%%%%%%% Function call!
    %kleiner Spiegel
    rays_to_mirror=ray_paths(:,3:4,ind_of_valid_rays);
    
    [rays_from_small_mirror,ind_of_rays_from_small_mirror]=...
        smallmirrorreflection(...
        rays_to_mirror,focus,small_mirr_hand,ind_of_valid_rays,'nonverbose');
    
    ray_paths(:,5:6,ind_of_rays_from_small_mirror)=rays_from_small_mirror;
    %%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%% Function call!
    %Absorption
    [num_rays,angle_rays,energy,absorption_points,ind_of_rays_that_are_absorbed_second] =...
        absorber(rays_from_small_mirror, ellipt_parameters, handle_to_mirror_function,'nonverbose',ind_of_rays_from_small_mirror);
    ray_paths(:,7,ind_of_rays_that_are_absorbed_second)=absorption_points;
    ind_of_rays_that_are_absorbed = [ind_of_rays_that_are_absorbed_second ind_of_rays_that_are_pre_absorbed];
    if strcmp(verbosity,'verbose')
        disp(['Anzahl sekund�r absorbierter Strahlen: ' int2str(num_rays)])
    end
    %%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%
    %%%ENDE der Kernfunktionen
    %%%%%%%%%%%%%%%%%%
    
    %Alle Fokuspunkte in einer Matrix speichern
    focus_line = [focus_line focus];
    
    %%% Es folgen sch�ne plots
    if strcmp(verbosity,'verbose')
        figure;
        % plot current focus position
        s_rad = 0.01*mirr_quadrat_equivalent;
%         hold on
%         surf(s_rad*x+focus(1),s_rad*y+focus(2),s_rad*z+focus(3),'EdgeColor', 'none', 'FaceColor', 'blue');
%         hold off
        axis vis3d
        view(3)
        plot_all_the_rays(ray_paths, ind_of_valid_rays, ind_of_rays_that_are_absorbed, ...
            ind_of_rays_that_are_absorbed_second, handle_to_mirror_function, ...
            small_mirr_hand, focus,ellipt_parameters, plotmode, ind_of_big_mirror_rays)
        disp(['Anzahl der absorbierter Strahlen in einem Zeitschritt: ' int2str(length(ind_of_rays_that_are_absorbed))])
        disp('================================')
    end
    Leistung_gesamt = Leistung_gesamt + length(ind_of_rays_that_are_absorbed)*P_ray;
    Leistung_Sonne = Leistung_Sonne + P_max;
    
    strahlen_gesamt = strahlen_gesamt + length(ind_of_rays_that_are_absorbed);
end %f�r timestep-Schleife
% end %f�r phi-Schleife
% end %f�r theta-Schleife
%%%%%
%ENDE der for-Schleife
%%%%%

aufgenommene_Energie = (Leistung_gesamt/(number_zeitpunkte-2))*...
    (15*(number_zeitpunkte/(number_zeitpunkte-2)))/1000 %in kWh

Sonnenenergie = (Leistung_Sonne/(number_zeitpunkte-2))*...
    (15*(number_zeitpunkte/(number_zeitpunkte-2)))/1000 %in kWh

Wirkungsgrad = aufgenommene_Energie/Sonnenenergie

%%% Es folgen weitere sch�ne plots
%plot der Spiegeloberflaeche
if strcmp(verbosity,'verbose')
    figure;
    axis equal
    axis([1.5*mirr_borders 0 3*half_mirr_edge_length])
    [rays_x rays_y] = meshgrid(linspace(mirr_borders(1), mirr_borders(2), 10));
    mirror_surface = zeros(10);
    for x_ind = 1:10
        for y_ind = 1:10
            mirror_surface(x_ind,y_ind) = handle_to_mirror_function(rays_x(x_ind,y_ind),rays_y(x_ind,y_ind));
        end
    end
    hold on
    surf(rays_x,rays_y,mirror_surface,'FaceColor','red','EdgeColor','none','FaceAlpha',0.8);
    hold off
    % plot connecting line of all focus points
%     hold on
%     plot3(focus_line(1,:),focus_line(2,:),focus_line(3,:),'LineWidth', 4);
%     hold off
    axis vis3d image
    view(3)
    lighting gouraud
    camlight
end
disp('================================')
disp('================================')
disp(['Anzahl ALLER absorbierter Strahlen: ' int2str(strahlen_gesamt)])
disp('================================')
disp('================================')
end