function rays = raymaker(phi,theta,num_rays_per_row, verbosity)
% Example: raymaker(20,10) produces a regular matrix of rays. They are
% shifted 'phi'=20 degrees around the y- and 'theta'=10 degrees around the
% x-axis (twisted-right-hand-rule). Adjust the number of rays by changing the variable
% "num_rays_per_row" in the code.

%A Tännchen!:
%Muss noch geändert werden in fucking Kugelkoordinaten, so wie der
%Sonnenstand nun auch leider definiert ist. Ansonsten stimmt der
%Sonnenstand nur, wenn entweder phi oder theta null sind, zusammen machen
%sie kein Sinn.
%TODO

% close all

if exist('verbosity','var')
switch verbosity
    case 'verbose',
        verbosity = true;
    case 'nonverbose',
        verbosity = false;
    otherwise
        error('Falsches Eingabeargument bei reflection(~,~,v)! verbose oder nonverbose eingeben');
end
else
    verbosity = false;
end

global mirr_borders
mirr_quadrat_equivalent = sqrt((mirr_borders(2)-mirr_borders(1))*(mirr_borders(4)-mirr_borders(3)));

sun_height = 4*mirr_quadrat_equivalent;


[rays_x rays_y] = meshgrid(linspace(sqrt(2)*mirr_borders(1), sqrt(2)*mirr_borders(2), num_rays_per_row));
rays_z = repmat(sun_height, size(rays_x));

theta_rad = (theta/180)*pi;
% theta dreht um die x-Achse
R_theta = [ 1   0   0
            0   cos(theta_rad)  -sin(theta_rad)
            0   sin(theta_rad)  cos(theta_rad)
            ];
        
% v_neu = R * v Zeile fuer Zeile:
% rays_x = rays_x;
rays_y_new = R_theta(2,2)*rays_y + R_theta(2,3)*rays_z;
rays_z_new = R_theta(3,2)*rays_y + R_theta(3,3)*rays_z;

rays_y = rays_y_new;
rays_z= rays_z_new;

% ray-direction
ray_dir = R_theta * [0;0;-1]; %3x1 vector


phi_rad = (phi/180)*pi;
%phi dreht um die z-Achse (!)
R_phi = [   cos(phi_rad)  -sin(phi_rad) 0 
            sin(phi_rad)  cos(phi_rad)  0
            0             0             1];
% v_neu = R * v Zeile fuer Zeile:
rays_x_new = R_phi(1,1)*rays_x + R_phi(1,2)*rays_y;
rays_y_new = R_phi(2,1)*rays_x + R_phi(2,2)*rays_y;
% rays_z = rays_z;

rays_x = rays_x_new;
rays_y = rays_y_new;

% ray-direction
ray_dir = R_phi * ray_dir; %3x1 vector

    
% phi_rad = (phi/180)*pi;
% %phi dreht um die y-Achse
% R_phi = [   cos(phi_rad)  0 sin(phi_rad)
%             0             1 0
%             -sin(phi_rad) 0 cos(phi_rad)];
% % v_neu = R * v Zeile fuer Zeile:
% rays_x_new = R_phi(1,1)*rays_x;
% % rays_y = rays_y;
% rays_z = R_phi(3,1)*rays_x;
% 
% rays_x = rays_x_new;


% ray-direction
% ray_dir = R_theta * R_phi * [0;0;-1]; %3x1 vector

% sun-height-Offset
% rays_x = rays_x + sun_height*(-ray_dir(1));
% rays_y = rays_y + sun_height*(-ray_dir(2));
% rays_z = rays_z + sun_height*(-ray_dir(3));

% plot
if verbosity
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
end
% output
rays = zeros(3,2,num_rays_per_row^2);
% Zeilen: x,y,z Koordinate;
% Spalten: 1. Spalte: Startpunkt, 2. Spalte: Richtung
% Tiefe: alle num_rays_per_row^2 Lichtstrahlen
rays(:,1,:) = [rays_x(:) rays_y(:) rays_z(:)]';
rays(:,2,:) = repmat(ray_dir,1,num_rays_per_row^2);
end