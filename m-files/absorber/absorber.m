function [num_rays,angle_rays,energy,collision_points,ind_of_rays_that_hit_it] = absorber(rays, ellipt_constants, mirror_handle)
if isempty(ellipt_constants)
    ellipt_constants = [1 1 0 0 0 1]; %Kreis mit radius 1
end
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

energy = 0;
global mirr_borders
mirr_quadrat_equivalent = sqrt((mirr_borders(2)-mirr_borders(1))*(mirr_borders(4)-mirr_borders(3)));
sun_height = 4*mirr_quadrat_equivalent;
ind_of_rays_that_hit_it = zeros(1,size(rays,3));
tol_mirr_distance = 10e-3;
collision_points=zeros(3,size(rays,3));
collector_of_angle_rays = zeros(1,size(rays,3));
num_rays = 0;

for ray_ind = 1:size(rays,3)
    c_length = 0;
    c_candidate = rays(:,1,ray_ind);
    c_dir = rays(:,2,ray_ind);
    c_tol_interval = 2*sun_height;
    mirror_geschnitten = false;

    if(c_candidate(3)>0)
        %hüpf den Strahl entlang, bis du um die toleranz nah dran bist
        while(c_tol_interval > tol_mirr_distance)
            if(c_candidate(3) > mirror_handle(c_candidate(1),c_candidate(2)))
                %überm spiegel
                c_candidate = c_candidate + c_dir * (c_tol_interval/2);
                c_length = c_length + (c_tol_interval/2);
                c_tol_interval = c_tol_interval / 2;
            else
                mirror_geschnitten = true;
                %unterm spiegel
                c_candidate = c_candidate - c_dir * (c_tol_interval/2);
                c_length = c_length - (c_tol_interval/2);
                c_tol_interval = c_tol_interval / 2;
            end
        end

        %Wenn der Treffpunkt immernoch innerhalb der Grenzen: good ray!
        if(NONLCON_ellipse(c_candidate,ellipt_constants) <= 0 &&...
            mirror_geschnitten)
        
            num_rays = num_rays+1;
            collision_points(:,num_rays) = c_candidate;
            ind_of_rays_that_hit_it(num_rays) = ray_ind;
            c_plane_normal = mirror_normal_calculator(mirror_handle,c_candidate);
            collector_of_angle_rays(num_rays) = 180*acos(dot(c_plane_normal,-c_dir))/pi;
        end
    end
end

%Prunen der Ergebnisvektoren
collision_points = collision_points(:,1:num_rays);
ind_of_rays_that_hit_it = ind_of_rays_that_hit_it(1:num_rays);
angle_rays = collector_of_angle_rays(1:num_rays);

%Berechnung der kumulativen Strahlenenergie
for i = 1:num_rays
    %In angle_rays steht der Winkel relativ zur Normalen des Spiegels.
    %Dieser wird in den radian-Wert umgerechnet und als cosinus zur Energie
    %hinzugefügt. Daraus ergibt sich, dass senkrechte Strahlen die Energie
    %1 und Strahlen parallel zur Spiegeloberfläche die Energie 0 besitzen.
    energy = energy + cos(pi*angle_rays(i)/180);
end


%plot a circle and hitting rays
if ~(num_rays == 0) && verbosity
    hold on
    circle_coord = zeros(360,3);
    r=ellipt_constants(6);
    for phi_circle = 1:360
        circle_coord(phi_circle,1) = r*cos(pi*phi_circle/180);
        circle_coord(phi_circle,2) = r*sin(pi*phi_circle/180);
        circle_coord(phi_circle,3) = mirror_handle(circle_coord(phi_circle,1),circle_coord(phi_circle,2));
    end
    patch(circle_coord(:,1),circle_coord(:,2),circle_coord(:,3),'b')

    ray_dirs = zeros(3,num_rays);
    ray_dirs(:,:) = rays(:,2,ind_of_rays_that_hit_it);

    axis vis3d image
    arrow3(collision_points'-ray_dirs',collision_points','y',1,1)
    hold off
end
end
