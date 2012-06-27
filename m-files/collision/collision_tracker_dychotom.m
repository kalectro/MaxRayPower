function [collision_points, ind_of_rays_that_hit_it] = collision_tracker_dychotom(rays, mirror_handle, param_borders)
global mirr_borders
if ~exist('param_borders','var')
    local_mirr_borders = mirr_borders;
else
    local_mirr_borders = param_borders;
end
mirr_quadrat_equivalent = sqrt((local_mirr_borders(2)-local_mirr_borders(1))*(local_mirr_borders(4)-local_mirr_borders(3)));
BIG_mirr_quadrat_equivalent = sqrt((mirr_borders(2)-mirr_borders(1))*(mirr_borders(4)-mirr_borders(3)));
sun_height = 4*BIG_mirr_quadrat_equivalent;
ind_of_rays_that_hit_it = zeros(1,size(rays,3));
tol_mirr_distance = 1e-3;
step_size = 1e-1; %10 cm
collision_points=zeros(3,size(rays,3));
num_rays = 0;
borders = [0 2*sun_height]; %grenzen den Suchraum in c_dir-Richtung ein
too_far = false;

for ray_ind = 1:size(rays,3)

    tol_interval = borders(2)-borders(1);
    c_candidate = rays(:,1,ray_ind);
    c_dir = rays(:,2,ray_ind);
    
    scnd_border_position = c_candidate + borders(2)*c_dir;

    %Wenn du die letzte L�nge wiederverwendet hast, jedoch kein
    %Schnittpunkt mit dem Spiegel existiert, verwirf die Laenge und
    %mache eine Suche mit den min und max borders (0 und 2fache
    %Sonnenh�he).
%     if scnd_border_position(3) > mirror_handle(scnd_border_position(1),scnd_border_position(2))
%         borders = [0 2*sun_height];
%         scnd_border_position = c_candidate + borders(2)*c_dir;
%     end

    %Wenn der Strahl �ber dem Boden startet und nicht am Spiegel
    %vorbeifliegt, dann...
    if(c_candidate(3)>0 && scnd_border_position(3)<mirror_handle(scnd_border_position(1),scnd_border_position(2)))
        %in 10cm-Schritten ann�hern
        temp_length = borders(1);
        t_candidate = c_candidate;
        still_good = true;
        while(~(local_mirr_borders(1) < t_candidate(1) && t_candidate(1) < local_mirr_borders(2) &&...
                local_mirr_borders(3) < t_candidate(2) && t_candidate(2) < local_mirr_borders(4)) &&...
                temp_length < tol_interval)
            temp_length = temp_length + step_size;
            t_candidate = c_candidate + temp_length*c_dir;
        end
        if(temp_length > tol_interval)
            still_good = false;
        end
        
        
        
        while(still_good &&...
                t_candidate(3) > mirror_handle(t_candidate(1),t_candidate(2)))
            temp_length = temp_length + step_size;
            t_candidate = c_candidate + temp_length*c_dir;
        end
        temp_length = temp_length - step_size;
        borders(1) = temp_length;
        t_candidate = c_candidate + temp_length*c_dir;
        if(t_candidate(3) < mirror_handle(t_candidate(1),t_candidate(2)))
            still_good = false;
        end
        
        while(still_good &&...
                tol_interval > tol_mirr_distance)
            length_inbetween_borders = (borders(1)+borders(2))/2;
            middle_point = c_candidate + length_inbetween_borders*c_dir;
            %Wenn die Mitte des derzeitigen Intervalls �ber dem Spiegel
            %liegt, nimm nur noch die untere H�lfte als Suchraum, wenn si
            %eunter dem Spiegel liegt, nimm die obere H�lfte.
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
        if abs(coll_point(3)-mirror_handle(coll_point(1),coll_point(2))) > tol_mirr_distance
%             disp('Entfernung: ')
%             disp(norm(coll_point(3)-mirror_handle(coll_point(1),coll_point(2))))
%             disp('Strahlnummer: ')
%             disp(ray_ind)
            still_good = false;
%             too_far = true;
        end
        borders = [0 2*sun_height];
        
        %Wenn der Treffpunkt immernoch innerhalb der Grenzen: good ray!
        if(still_good &&...
            local_mirr_borders(1) < coll_point(1) && coll_point(1) < local_mirr_borders(2) &&...
            local_mirr_borders(3) < coll_point(2) && coll_point(2) < local_mirr_borders(4))
            %�berpr�fung, ob der Strahl den Spiegel auf der richtigen Seite trifft
%             normale = mirror_normal_calculator(mirror_handle,coll_point);
%             right_side=collision_direction(c_dir,normale);
            right_side = collision_direction_neu([coll_point c_dir],mirror_handle);
            if right_side 
                num_rays = num_rays+1;
                collision_points(:,num_rays) = coll_point;
                ind_of_rays_that_hit_it(num_rays) = ray_ind;
                
                %borders = [final_length-mirr_quadrat_equivalent/16 final_length+mirr_quadrat_equivalent/16];
            end
        end
    end
end
% if too_far
%     error('Zu weit weg! (Da stimmt was nicht...)');
% end
collision_points = collision_points(:,1:num_rays);
ind_of_rays_that_hit_it = ind_of_rays_that_hit_it(1:num_rays);

end