% Skript zum Ausrechnen des Fokus f�r verschiedene Einstrahlwinkel
close all


theta_vector = -90:10:0;
phi_vector = -90:10:90;
focus_line = zeros(3,max(length(theta_vector),length(phi_vector)));

%mirr_borders are quadratic
%Kantenlänge = mirr_edge_length = 5 "=" 5meters

global mirr_borders mirr_edge_length
mirr_edge_length = 5;
mirr_borders = [-mirr_edge_length mirr_edge_length -mirr_edge_length mirr_edge_length];

% min_borders = 100*[-50; -50; -100]; %x,y,z borders in a 3x1 vector
% max_borders = 100*[50; 50; 100];

[x,y,z] = sphere;
[x_grid, y_grid] = meshgrid(linspace(mirr_borders(1),mirr_borders(2),10));
mirror = zeros(size(x_grid));
handle_to_mirror_function = @mirr_func;
pos = [0;0;0];

% for theta_ind = 1:10
% for theta_ind = 10:10
theta_ind = 10;
% for phi_ind = 1:length(phi_vector)
for phi_ind = 2
    
theta = theta_vector(theta_ind);
phi = phi_vector(phi_ind);

old_pos = pos;
% old_small_mirr_plane_normal = small_mirr_plane_normal;


%%%%%%%%%%%%%%%%%% Function call!
% Strahlen generieren
rays = raymaker(phi, theta);
%%%%%%%%%%%%%%%%%%

%ZEITFRESSER (20sek bei 100 Strahlen)
%Verbesserung 23.04. ->> 5,3sek bei 100 Strahlen
%Weitere Verbesserung m�glich:
%   1. Spiegel-z-H�he begrenzen
%   2. Analytische L�sung f�r t, erste Nullstele mit NewtonRaphson finden,
%      und dann Treffer von oben/unten unterscheiden

%%%%%%%%%%%%%%%%%% Function call!
% Kollisionen mit Spiegel und boundaries checken.
[rays, ind_of_rays_that_hit_it] = collision_tracker(rays, handle_to_mirror_function);
%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%% Function call!
% Reflektierte Richtung berechnen und in rays eintragen.
[rays] = reflection(rays, ind_of_rays_that_hit_it);
%%%%%%%%%%%%%%%%%%


% nicht genau genug
%m�glichkeiten der Verbesserung:
%1. Schnitte von Schl�uchen in einer MxNxP - Matrix (Hough)
%2. Gewichtung von Fokuspunkten nach: nahe Nachbarn: gut!, nachbarn weit
%weg: b�se! (z.B weight = sum(1/dist_to_neighbor_i)) over i
%3. notwendig: Begrenzung des maximalen Abstands des kleinen spiegels von
%[0,0,0]
%%%%%%%%%%%%%%%%%% Function call!
% Fokuspunkt berechnen
focus = focus_of_rays(rays, ind_of_rays_that_hit_it);
%%%%%%%%%%%%%%%%%%

% % Fokus out of bounds?
% if( any( focus < min_borders | focus > max_borders) )
%     pos = old_pos;
% %     small_mirr_plane_normal = old_small_mirr_plane_normal;
% else
%     pos = focus;
% %     small_mirr_plane_normal = - focus/norm(focus);
% end

pos = focus;

% plot current focus position
hold on
surf(x+pos(1),y+pos(2),z+pos(3),'EdgeColor', 'none', 'FaceColor', 'red');
hold off
axis vis3d image
view(3)

% focus_line(:,theta_ind) = pos;
focus_line(:,phi_ind) = pos;

drawnow
% pause
end

% plot connecting line of all focus points
hold on
plot3(focus_line(1,:),focus_line(2,:),focus_line(3,:),'LineWidth', 4);
hold off
axis vis3d image
view(3)

