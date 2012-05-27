function Spiegelung_Fokustest
% function zum Ausrechnen des Fokus für verschiedene Einstrahlwinkel
 close all

% Parameter um den Ablauf zu beeinflussen
theta_vector = -80:20:0;
phi_vector = -80:20:80;
num_rays_per_row = 30;
small_mirr_hand = @mirr_func_small;
handle_to_mirror_function = @mirr_func;
ellipt_parameters = [1 1 0 0 0 0.5];%parameter für die Form der Absorberellipse

% notwendige Initialisierungen
% focus_line = zeros(3,max(length(theta_vector),length(phi_vector)));
focus_line = [];
%mirr_borders are rectangular
global mirr_borders half_mirr_edge_length
half_mirr_edge_length = sqrt(10)/2; %10qm Grundflaeche
mirr_borders = [-half_mirr_edge_length half_mirr_edge_length -half_mirr_edge_length half_mirr_edge_length];
mirr_quadrat_equivalent = sqrt((mirr_borders(2)-mirr_borders(1))*(mirr_borders(4)-mirr_borders(3)));
[x,y,z] = sphere;
%plot der Spiegeloberflaeche
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


%%%%%
%FOR-Schleife (geht alle Einstrahlwinkel durch)
%%%%%
for theta_ind = 4%1:size(theta_vector,2)
for phi_ind = 4%1:size(phi_vector,2)

    theta = theta_vector(theta_ind);
    phi = phi_vector(phi_ind);

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
    % Kollisionen mit Spiegel und boundaries checken.
    [collision_points, ind_of_valid_rays] = collision_tracker_dychotom(ray_paths(:,1:2,:), handle_to_mirror_function);
    if isempty(ind_of_valid_rays) % wenn kein Strahl mehr existiert
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
    %10 Strahlen, die ihm am nächsten sind, bzw die ihm näher als xy cm sind
    %%%%%%%%%%%%%%%%%% Function call!
    % Fokuspunkt berechnen
    focus = focus_of_rays_fast(ray_paths(:,3:4,ind_of_valid_rays));
    %%%%%%%%%%%%%%%%%%

    % Hier Maxims Code einfügen
    
    %%%%%%%%%%%%%%%%%% Function call!
    % Direktabsorbtion
    [num_rays,~,~,absorption_points,ind_of_rays_that_are_pre_absorbed] =...
        absorber(ray_paths(:,1:2,ind_of_valid_rays), ellipt_parameters, handle_to_mirror_function,'verbose',ind_of_valid_rays);
    ray_paths(:,5:6,ind_of_rays_that_are_pre_absorbed)=ray_paths(:,1:2,ind_of_rays_that_are_pre_absorbed);  % der Vollständigkeit halber, damit ein Plot möglich ist
    ray_paths(:,7,ind_of_rays_that_are_pre_absorbed)=absorption_points;
    disp(['Anzahl direkt absorbierter Strahlen: ' int2str(num_rays)])
    %%%%%%%%%%%%%%%%%%
    
    % Kollisionen mit großem Spiegel, die direkt absorbiert wurden nicht weiter beruecksichtigen.
    for ray_ind = 1:size(ind_of_rays_that_are_pre_absorbed)
        ind_of_valid_rays = ind_of_valid_rays(ind_of_valid_rays~=ind_of_rays_that_are_pre_absorbed(ray_ind)); 
    end
    %%%%%%%%%%%%%%%%%%   

    %%%%%%%%%%%%%%%%%% Function call!
    %kleiner Spiegel
    rays_to_mirror=ray_paths(:,3:4,ind_of_valid_rays);
    [rays_from_small_mirror,ind_of_rays_from_small_mirror]=...
        smallmirrorreflection(rays_to_mirror,focus,small_mirr_hand,ind_of_valid_rays,'nonverbose');
    ray_paths(:,5:6,ind_of_rays_from_small_mirror)=rays_from_small_mirror;
    %%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%% Function call!
    %Absorption
    [num_rays,angle_rays,energy,absorption_points,ind_of_rays_that_are_absorbed] =...
        absorber(rays_from_small_mirror, ellipt_parameters, handle_to_mirror_function,'verbose',ind_of_rays_from_small_mirror);
    ray_paths(:,7,ind_of_rays_that_are_absorbed)=absorption_points;
    ind_of_rays_that_are_absorbed = [ind_of_rays_that_are_absorbed ind_of_rays_that_are_pre_absorbed];
    disp(['Anzahl absorbierter Strahlen: ' int2str(num_rays)])
    %%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%
    %%%ENDE der Kernfunktionen
    %%%%%%%%%%%%%%%%%%
    
    %Alle Fokuspunkte in einer Matrix speichern
    focus_line = [focus_line focus];
    
    %%% Es folgen schöne plots
    
    % plot current focus position
    s_rad = 0.01*mirr_quadrat_equivalent;
    hold on
    surf(s_rad*x+focus(1),s_rad*y+focus(2),s_rad*z+focus(3),'EdgeColor', 'none', 'FaceColor', 'blue');
    hold off
    axis vis3d image
    view(3)
    drawnow
    
end %für phi-Schleife
end %für theta-Schleife
%%%%%
%ENDE der for-Schleife
%%%%%

%%% Es folgen weitere schöne plots

% plot connecting line of all focus points
hold on
plot3(focus_line(1,:),focus_line(2,:),focus_line(3,:),'LineWidth', 4);
hold off
axis vis3d image
view(3)
lighting gouraud
camlight

%plot reflection with latest phi and theta
  %the small mirror
    half_small_mirr_edge_length = sqrt(1)/2; %1qm Grundflaeche
    [rays_x rays_y] = meshgrid(linspace(-half_small_mirr_edge_length, half_small_mirr_edge_length, 10));
    small_mirror_surface = zeros(10);
    drehmatrix = transformation(focus);
    for x_ind = 1:10
        for y_ind = 1:10
            %Oberfläche berechnen
            small_mirror_surface(x_ind,y_ind) = small_mirr_hand(rays_x(x_ind,y_ind),rays_y(x_ind,y_ind));
            %rotation
            tmp = drehmatrix*[rays_x(x_ind,y_ind);rays_y(x_ind,y_ind);small_mirror_surface(x_ind,y_ind)];
            rays_x(x_ind,y_ind) = tmp(1);
            rays_y(x_ind,y_ind) = tmp(2);
            small_mirror_surface(x_ind,y_ind) = tmp(3);
        end
    end
    %translation
    rays_x = rays_x + focus(1);
    rays_y = rays_y + focus(2);
    small_mirror_surface = small_mirror_surface + focus(3);
%     %plotten
% hold on
%     surf(rays_x,rays_y,small_mirror_surface,'FaceColor','red','EdgeColor','none','FaceAlpha',0.5);
%   %the rays
%     arrow3((permute(ray_paths(:,1,ind_of_rays_that_are_absorbed),[1 3 2]))',(permute(ray_paths(:,3,ind_of_rays_that_are_absorbed),[1 3 2]))','y',0.5,0.5)
%     arrow3((permute(ray_paths(:,3,ind_of_rays_that_are_absorbed),[1 3 2]))',(permute(ray_paths(:,5,ind_of_rays_that_are_absorbed),[1 3 2]))','y',0.5,0.5)
%     arrow3((permute(ray_paths(:,5,ind_of_rays_that_are_absorbed),[1 3 2]))',absorption_points','y',0.5,0.5)
% 
%   %test fuer die Koordinaten des kleinen Spiegels
%     ex=[1;0;0];
%     ey=[0;1;0];
%     ez=[0;0;1];
%     e1=drehmatrix*ex+focus;
%     e2=drehmatrix*ey+focus;
%     e3=drehmatrix*ez+focus;
%     arrow3(focus',e1','r2',1,1)
%     arrow3(focus',e2','b2',1,1)
%     arrow3(focus',e3','m2',1,1)
% hold off
% xlabel('X-Achse')
% ylabel('Y-Achse')
% zlabel('Z-Achse')
end