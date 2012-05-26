function Spiegelung_Fokustest
% function zum Ausrechnen des Fokus für verschiedene Einstrahlwinkel
 close all

theta_vector = -80:20:80;
phi_vector = -80:20:80;

num_rays_per_row = 40;

focus_line = zeros(3,max(length(theta_vector),length(phi_vector)));
small_mirr_hand = @mirr_func_small;

%mirr_borders are rectangular

global mirr_borders half_mirr_edge_length

half_mirr_edge_length = sqrt(10)/2; %10qm Grundflaeche
mirr_borders = [-half_mirr_edge_length half_mirr_edge_length -half_mirr_edge_length half_mirr_edge_length];
mirr_quadrat_equivalent = sqrt((mirr_borders(2)-mirr_borders(1))*(mirr_borders(4)-mirr_borders(3)));

[x,y,z] = sphere;
handle_to_mirror_function = @mirr_func;

%parameter für die Form der Absorberellipse
ellipt_parameters = [1 1 0 0 0 1];

%plot der Spiegeloberflï¿½che
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

% for theta_ind = 1:size(theta_vector,2)
theta_ind = 5;
% for phi_ind = 1:length(phi_vector)
for phi_ind = 4%1:size(phi_vector,2)

theta = theta_vector(theta_ind);
phi = phi_vector(phi_ind);
% close all

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
[collision_points, ind_of_rays_that_hit_it] = collision_tracker_dychotom(ray_paths(:,1:2,:), handle_to_mirror_function);
%%%%%%%%%%%%%%%%%%

ray_paths(:,3,ind_of_rays_that_hit_it) = collision_points;

%%%%%%%%%%%%%%%%%% Function call!
% Reflektierte Richtung berechnen und in ray_paths eintragen.
reflection1_direction = reflection(ray_paths(:,2:3,ind_of_rays_that_hit_it),handle_to_mirror_function, 'nonverbose');
ray_paths(:,4,ind_of_rays_that_hit_it) = reflection1_direction;
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
focus = focus_of_rays_fast(ray_paths(:,3:4,ind_of_rays_that_hit_it));
%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%% Function call!
%Drehmatrix
% drehmatrix = transformation(focus);
%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%% Function call!
%kleiner Spiegel
rays_to_mirror=ray_paths(:,3:4,ind_of_rays_that_hit_it);
[rays_from_mirror]=smallmirrorreflection(rays_to_mirror,focus,small_mirr_hand);
%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%% Function call!
%Absorption
[num_rays,angle_rays,energy,absorption_point,ind_of_rays_that_are_absorbed] = absorber(rays_from_mirror, ellipt_parameters, handle_to_mirror_function);
% disp(['Anzahl absorbierter Strahlen: ' int2str(num_rays)])
%%%%%%%%%%%%%%%%%%
energy
num_rays

pos = focus;
%wenn es keinen Fokuspunkt gibt, ist pos = [[];[];[]]
% focus_line(:,theta_ind) = pos;
focus_line(:,phi_ind) = pos;

% plot current focus position
s_rad = 0.01*mirr_quadrat_equivalent;
hold on
surf(s_rad*x+pos(1),s_rad*y+pos(2),s_rad*z+pos(3),'EdgeColor', 'none', 'FaceColor', 'blue');
hold off
axis vis3d image
view(3)

drawnow
end
% end
% plot connecting line of all focus points
hold on
plot3(focus_line(1,:),focus_line(2,:),focus_line(3,:),'LineWidth', 4);
hold off
axis vis3d image
view(3)
lighting gouraud
camlight

hold on
% Plottet vom kleinen Spiegel reflektierte Strahlen
for i=1:length(rays_from_mirror(1,1,:))
    arrow3(rays_from_mirror(:,1,i)',(rays_from_mirror(:,1,i)+rays_from_mirror(:,2,i))','y',1,1);
end
hold off
axis vis3d image
view(3)
lighting gouraud
camlight
%bis hierhin
end