function Spiegelung_Fokustest
% function zum Ausrechnen des Fokus für verschiedene Einstrahlwinkel
% close all

theta_vector = -90:10:0;
phi_vector = -90:10:90;
num_rays_per_row = 10;
focus_line = zeros(3,max(length(theta_vector),length(phi_vector)));

%mirr_borders are rectangular

global mirr_borders half_mirr_edge_length

half_mirr_edge_length = sqrt(10)/2; %10qm Grundflï¿½che
mirr_borders = [-half_mirr_edge_length half_mirr_edge_length -half_mirr_edge_length half_mirr_edge_length];
mirr_quadrat_equivalent = sqrt((mirr_borders(2)-mirr_borders(1))*(mirr_borders(4)-mirr_borders(3)));

% min_borders = 100*[-50; -50; -100]; %x,y,z borders in a 3x1 vector
% max_borders = 100*[50; 50; 100];

[x,y,z] = sphere;
[x_grid, y_grid] = meshgrid(linspace(mirr_borders(1),mirr_borders(2),10));
mirror = zeros(size(x_grid));
handle_to_mirror_function = @mirr_func;
pos = [0;0;0];

% for theta_ind = 1:10
% for theta_ind = 10
theta_ind = 10;
% for phi_ind = 1:length(phi_vector)
for phi_ind = 5
    
theta = theta_vector(theta_ind);
phi = phi_vector(phi_ind);

old_pos = pos;
% old_small_mirr_plane_normal = small_mirr_plane_normal;


%%%%%%%%%%%%%%%%%% Function call!
% Strahlen generieren
ray_paths = raymaker(phi, theta, num_rays_per_row);
%%%%%%%%%%%%%%%%%%

%ZEITFRESSER (20sek bei 100 Strahlen)
%Verbesserung 23.04. ->> 5,3sek bei 100 Strahlen
%Weitere Verbesserung mï¿½glich:
%   1. Spiegel-z-Hï¿½he begrenzen
%   2. Analytische Lï¿½sung fï¿½r t, erste Nullstele mit NewtonRaphson finden,
%      und dann Treffer von oben/unten unterscheiden

%%%%%%%%%%%%%%%%%% Function call!
% Kollisionen mit Spiegel und boundaries checken.
[collistion_point, ind_of_rays_that_hit_it] = collision_tracker_dychotom(ray_paths(:,1:2,:), handle_to_mirror_function);
%%%%%%%%%%%%%%%%%%
% break
ray_paths(:,3,ind_of_rays_that_hit_it) = collistion_point;

%%%%%%%%%%%%%%%%%% Function call!
% Reflektierte Richtung berechnen und in ray_paths eintragen.
reflection1_direction = reflection(ray_paths(:,2:3,ind_of_rays_that_hit_it), 'verbose');
ray_paths(:,4,ind_of_rays_that_hit_it) = reflection1_direction;
%%%%%%%%%%%%%%%%%%


% forget about that! Those rays are LOST!!!! - Kai
% hit_test_var = ind_of_rays_that_hit_it;
% num_collision_runs = 1;
% collision_run_limit = 10;
% % while ~isempty(hit_test_var) && (num_collision_runs < collision_run_limit)
% % %     rekursiver Aufruf, bis alle Reflektionen nicht mehr den groï¿½en
% % %     Spiegel treffen
% %     [rays, hit_test_var] = collision_tracker_kai(rays, handle_to_mirror_function);
% %     [rays] = reflection(rays, hit_test_var, 'nonverbose');
% %     num_collision_runs = num_collision_runs+1;
% % end

% nicht genau genug
%mï¿½glichkeiten der Verbesserung:
%1. Schnitte von Schlï¿½uchen in einer MxNxP - Matrix (Hough)
%2. Gewichtung von Fokuspunkten nach: nahe Nachbarn: gut!, nachbarn weit
%weg: bï¿½se! (z.B weight = sum(1/dist_to_neighbor_i)) over i
%3. notwendig: Begrenzung des maximalen Abstands des kleinen spiegels von
%[0,0,0]
%%%%%%%%%%%%%%%%%% Function call!
% Fokuspunkt berechnen
focus = focus_of_rays(ray_paths, ind_of_rays_that_hit_it);
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
s_rad = 0.1*mirr_quadrat_equivalent;
hold on
surf(s_rad*x+pos(1),s_rad*y+pos(2),s_rad*z+pos(3),'EdgeColor', 'none', 'FaceColor', 'red');
hold off
axis vis3d image
view(3)

%wenn es keinen Fokuspunkt gibt, ist pos = [[];[];[]]
% focus_line(:,theta_ind) = pos;
focus_line(:,phi_ind) = pos;

drehmatrix = transformation(pos);



drawnow
% pause
end

% plot connecting line of all focus points
hold on
plot3(focus_line(1,:),focus_line(2,:),focus_line(3,:),'LineWidth', 4);
hold off
axis vis3d image
view(3)
lighting gouraud

end
