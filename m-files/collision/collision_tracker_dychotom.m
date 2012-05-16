function [collision_points, ind_of_rays_that_hit_it] = collision_tracker_dychotom(rays, mirror_handle)
global mirr_borders
mirr_quadrat_equivalent = sqrt((mirr_borders(2)-mirr_borders(1))*(mirr_borders(4)-mirr_borders(3)));
sun_height = 4*mirr_quadrat_equivalent;
ind_of_rays_that_hit_it = zeros(1,size(rays,3));
tol_mirr_distance = 10e-3;
collision_points=zeros(3,size(rays,3));
num_rays = 0;

for ray_ind = 1:size(rays,3)
    c_length = 0;
    c_candidate = rays(:,1,ray_ind);
    c_dir = rays(:,2,ray_ind);
    c_tol_interval = 2*sun_height;
    mirror_geschnitten = false;

    if(c_candidate(3)>0)
        %hüpf den Strahl entlang, bis du um die toleranz nah dran bist
        while(c_tol_interval > tol_mirr_distance) %random value!
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
        if(mirr_borders(1) < c_candidate(1) && c_candidate(1) < mirr_borders(2) &&...
            mirr_borders(3) < c_candidate(2) && c_candidate(2) < mirr_borders(4) &&...
            mirror_geschnitten)
            %Überprüfung, ob der Strahl den Spiegel auf der richtigen Seite trifft
            strahl = c_dir;
            normale = mirror_normal_calculator(mirror_handle,c_candidate);
            right_side=collision_direction(strahl,normale);
            if right_side 
                num_rays = num_rays+1;
                collision_points(:,num_rays) = c_candidate;
                ind_of_rays_that_hit_it(num_rays) = ray_ind;
            end
        end
        collision_points = collision_points(:,1:num_rays);
        ind_of_rays_that_hit_it = ind_of_rays_that_hit_it(1:num_rays);
    end
end

%plot der Spiegeloberflï¿½che
[rays_x rays_y] = meshgrid(linspace(mirr_borders(1), mirr_borders(2), 10));
mirror_surface = zeros(10);
for x_ind = 1:10
    for y_ind = 1:10
        mirror_surface(x_ind,y_ind) = mirror_handle(rays_x(x_ind,y_ind),rays_y(x_ind,y_ind));
    end
end
hold on
surf(rays_x,rays_y,mirror_surface,'FaceColor','red','EdgeColor','none','FaceAlpha',0.8);
hold off
camlight

end