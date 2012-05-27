function [collision_points, ind_of_rays_that_hit_it] = collision_tracker_dychotom(rays, mirror_handle, param_borders)
global mirr_borders
if ~exist('param_borders','var')
    local_mirr_borders = mirr_borders;
else
    local_mirr_borders = param_borders;
end
mirr_quadrat_equivalent = sqrt((local_mirr_borders(2)-local_mirr_borders(1))*(local_mirr_borders(4)-local_mirr_borders(3)));
sun_height = 4*mirr_quadrat_equivalent;
ind_of_rays_that_hit_it = zeros(1,size(rays,3));
tol_mirr_distance = 1e-3;
collision_points=zeros(3,size(rays,3));
num_rays = 0;
borders = [0 2*sun_height]; %grenzen den Suchraum in c_dir-Richtung ein

for ray_ind = 1:size(rays,3)
    counter=0;

    tol_interval = borders(2)-borders(1);
    c_candidate = rays(:,1,ray_ind);
    c_dir = rays(:,2,ray_ind);
    
    scnd_border_position = c_candidate + borders(2)*c_dir;

        %Wenn du die letzte Länge wiederverwendet hast, jedoch kein
        %Schnittpunkt mit dem Spiegel existiert, verwirf die Laenge und
        %mache eine Suche mit den min und max borders (0 und 2fache
        %Sonnenhöhe).
        if scnd_border_position(3) > mirror_handle(scnd_border_position(1),scnd_border_position(2))
            borders = [0 2*sun_height];
            scnd_border_position = c_candidate + borders(2)*c_dir;
        end

    %Wenn der Strahl über dem Boden startet und nicht am Spiegel
    %vorbeifliegt, dann...
    if(c_candidate(3)>0 && scnd_border_position(3)<mirror_handle(scnd_border_position(1),scnd_border_position(2)))
        while(tol_interval > tol_mirr_distance)
            counter = counter + 1;
            length_inbetween_borders = (borders(1)+borders(2))/2;
            middle_point = c_candidate + length_inbetween_borders*c_dir;
            %Wenn die Mitte des derzeitigen Intervalls über dem Spiegel
            %liegt, nimm nur noch die untere Hälfte als Suchraum, wenn si
            %eunter dem Spiegel liegt, nimm die obere Hälfte.
            if middle_point(3) > mirror_handle(middle_point(1),middle_point(2))
                borders(1)= length_inbetween_borders;
            else
                borders(2)= length_inbetween_borders;
            end
            %Update Toleranzintervall
            tol_interval = borders(2)-borders(1);
        end
        final_length = (borders(1) + borders(2)) / 2;
        coll_point = c_candidate + final_length*c_dir;
        
        borders = [0 2*sun_height];
        
        %Wenn der Treffpunkt immernoch innerhalb der Grenzen: good ray!
        if(local_mirr_borders(1) < coll_point(1) && coll_point(1) < local_mirr_borders(2) &&...
            local_mirr_borders(3) < coll_point(2) && coll_point(2) < local_mirr_borders(4))
            %Überprüfung, ob der Strahl den Spiegel auf der richtigen Seite trifft
%             normale = mirror_normal_calculator(mirror_handle,coll_point);
%             right_side=collision_direction(c_dir,normale);
            right_side = collision_direction_neu([coll_point c_dir],mirror_handle);
            if right_side 
                num_rays = num_rays+1;
                collision_points(:,num_rays) = coll_point;
                ind_of_rays_that_hit_it(num_rays) = ray_ind;
                
                borders = [final_length-mirr_quadrat_equivalent/16 final_length+mirr_quadrat_equivalent/16];
            end
            
        end
    end
end
collision_points = collision_points(:,1:num_rays);
ind_of_rays_that_hit_it = ind_of_rays_that_hit_it(1:num_rays);
    
%     c_length = 0;
%     c_candidate = rays(:,1,ray_ind);
%     c_dir = rays(:,2,ray_ind);
%     c_tol_interval = 2*sun_height;
%     mirror_geschnitten = false;
% 
%     if(c_candidate(3)>0)
%         %hüpf den Strahl entlang, bis du um die toleranz nah dran bist
%         while(c_tol_interval > tol_mirr_distance) %random value!
%             if(c_candidate(3) > mirror_handle(c_candidate(1),c_candidate(2)))
%                 %überm spiegel
%                 c_candidate = c_candidate + c_dir * (c_tol_interval/2);
%                 c_length = c_length + (c_tol_interval/2);
%                 c_tol_interval = c_tol_interval / 2;
%             else
%                 mirror_geschnitten = true;
%                 %unterm spiegel
%                 c_candidate = c_candidate - c_dir * (c_tol_interval/2);
%                 c_length = c_length - (c_tol_interval/2);
%                 c_tol_interval = c_tol_interval / 2;
%             end
%         end
%     end

end