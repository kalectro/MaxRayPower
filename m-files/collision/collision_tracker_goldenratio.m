function [collision_points, ind_of_rays_that_hit_it] = collision_tracker_goldenratio(rays, mirror_handle)
global mirr_borders
mirr_quadrat_equivalent = sqrt((mirr_borders(2)-mirr_borders(1))*(mirr_borders(4)-mirr_borders(3)));
sun_height = 4*mirr_quadrat_equivalent;
ind_of_rays_that_hit_it = zeros(1,size(rays,3));
tol_mirr_distance = 1e-4;
collision_points=zeros(3,size(rays,3));
num_rays = 0;
golden_ratio = 1.61803398875;

for ray_ind = 1:size(rays,3)
    c_candidate = rays(:,1,ray_ind);
    c_dir = rays(:,2,ray_ind);
    c_length = 2*sun_height;
    borders = [0 c_length];
    
    if(c_candidate(3)>0)
        %hüpf den Strahl entlang, bis du um die toleranz nah dran bist
        
        c_length1 = borders(2) - (borders(2)-borders(1))/golden_ratio;  % erste Länge
        c_length2 = borders(1) + (borders(2)-borders(1))/golden_ratio;  % zweite Länge
        c_candidate1 = c_candidate + c_dir * c_length1; % erster Testpunkt
        c_candidate2 = c_candidate + c_dir * c_length2; % zweiter Testpunkt
        a = abs(mirror_handle(c_candidate1(1),c_candidate1(2)) - c_candidate1(3));  % Abstand erster Punkt
        b = abs(mirror_handle(c_candidate2(1),c_candidate2(2)) - c_candidate2(3));  % Abstand zweiter Punkt
        
        while(abs(a-b) > tol_mirr_distance)
            
            if(a > b)   % welcher Punkt liegt näher?
                borders(1) = c_length1; % Grenze ändern
            else
                borders(2) = c_length2; % Grenze ändern
            end
            
            c_length1 = borders(2) - (borders(2)-borders(1))/golden_ratio;  % erste Länge
            c_length2 = borders(1) + (borders(2)-borders(1))/golden_ratio;  % zweite Länge
            c_candidate1 = c_candidate + c_dir * c_length1; % erster Testpunkt
            c_candidate2 = c_candidate + c_dir * c_length2; % zweiter Testpunkt
            a = abs(mirror_handle(c_candidate1(1),c_candidate1(2)) - c_candidate1(3));  % Abstand erster Punkt
            b = abs(mirror_handle(c_candidate2(1),c_candidate2(2)) - c_candidate2(3));  % Abstand zweiter Punkt
        end
        
        %Wenn der Treffpunkt immernoch innerhalb der Grenzen: good ray!
        if(mirr_borders(1) < c_candidate1(1) && c_candidate1(1) < mirr_borders(2) &&...
            mirr_borders(3) < c_candidate1(2) && c_candidate1(2) < mirr_borders(4))
            %Überprüfung, ob der Strahl den Spiegel auf der richtigen Seite trifft
            strahl = c_dir;
            normale = mirror_normal_calculator(mirror_handle,c_candidate1);
            right_side=collision_direction(strahl,normale);
            if right_side 
                num_rays = num_rays+1;
                collision_points(:,num_rays) = c_candidate1;
                ind_of_rays_that_hit_it(num_rays) = ray_ind;
            end
        end
    end
end
% Matricen nur so groß wie sie auch sein müssen (alle 0er raus)
collision_points= collision_points(:,1:num_rays);
ind_of_rays_that_hit_it = ind_of_rays_that_hit_it(1:num_rays);

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