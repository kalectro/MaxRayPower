function rays = raymaker(phi,theta)
% Example: raymaker(20,10) produces a regular matrix of rays. They are
% shifted 'phi'=20 degrees around the y- and 'theta'=10 degrees around the
% x-axis (twisted-right-hand-rule). Adjust the number of rays by changing the variable
% "num_rays_per_row" in the code.

% close all
global mirr_borders
mirr_quadrat_equivalent = sqrt((mirr_borders(2)-mirr_borders(1))*(mirr_borders(4)-mirr_borders(3)));

sun_height = 4*mirr_quadrat_equivalent;
num_rays_per_row = 10;


[rays_x rays_y] = meshgrid(linspace(mirr_borders(1), mirr_borders(2), num_rays_per_row));

phi_rad = (phi/180)*pi;
%phi dreht um die y-Achse
R_phi = [   cos(phi_rad)  0 sin(phi_rad)
            0             1 0
            -sin(phi_rad) 0 cos(phi_rad)];
% v_neu = R * v Zeile für Zeile:
rays_x_new = R_phi(1,1)*rays_x;
% rays_y = rays_y;
rays_z = R_phi(3,1)*rays_x;

rays_x = rays_x_new;

theta_rad = (theta/180)*pi;
% theta dreht um die x-Achse
R_theta = [ 1   0   0
            0   cos(theta_rad)  -sin(theta_rad)
            0   sin(theta_rad)  cos(theta_rad)
            ];
% v_neu = R * v Zeile für Zeile:
% rays_x = rays_x;
rays_y_new = R_theta(2,2)*rays_y + R_theta(2,3)*rays_z;
rays_z = R_theta(3,2)*rays_y + R_theta(3,3)*rays_z;

rays_y = rays_y_new;

% ray-direction
ray_dir = R_theta * R_phi * [0;0;-1]; %3x1 vector

% sun-height-Offset
rays_x = rays_x + sun_height*(-ray_dir(1));
rays_y = rays_y + sun_height*(-ray_dir(2));
rays_z = rays_z + sun_height*(-ray_dir(3));

% plot
figure;
surf(rays_x,rays_y,rays_z,'EdgeColor','none', 'FaceColor', 'interp')
hold on

axis equal
axis(1.1*[-sun_height sun_height -sun_height mirr_borders(2) -0.5*sun_height sun_height])

arrow3([rays_x(:) rays_y(:) rays_z(:)],[rays_x(:) rays_y(:) rays_z(:)]+...
    repmat(0.5*sun_height*ray_dir',num_rays_per_row^2,1), 'y', 1,1)

camlight
lighting gouraud
hold off

% output
rays = zeros(3,2,num_rays_per_row^2);
% Zeilen: x,y,z Koordinate;
% Spalten: 1. Spalte: Startpunkt, 2. Spalte: Richtung
% Tiefe: alle num_rays_per_row^2 Lichtstrahlen
rays(:,1,:) = [rays_x(:) rays_y(:) rays_z(:)]';
rays(:,2,:) = repmat(ray_dir,1,num_rays_per_row^2);
end