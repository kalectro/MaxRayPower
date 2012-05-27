function [num_rays,angle_rays,energy,collision_points,ind_of_rays_that_are_absorbed] = absorber(rays, ellipt_constants, mirror_handle,verbosity,ind_of_rays_from_small_mirror)
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
tol_mirr_distance = 1e-3;
collision_points=zeros(3,size(rays,3));
collector_of_angle_rays = zeros(1,size(rays,3));
num_rays = 0;
borders = [0 2*sun_height]; %grenzen den Suchraum in c_dir-Richtung ein

for ray_ind = 1:size(rays,3)

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
        final_length = mean([borders(1) borders(2)]);
        coll_point = c_candidate + final_length*c_dir;
        
        borders = [0 2*sun_height];

        %Wenn der Treffpunkt immernoch innerhalb der Grenzen: good ray!
        if(NONLCON_ellipse(coll_point,ellipt_constants) <= 0)
        
            num_rays = num_rays+1;
            collision_points(:,num_rays) = coll_point;
            ind_of_rays_that_hit_it(num_rays) = ray_ind;

            borders = [final_length-mirr_quadrat_equivalent/16 final_length+mirr_quadrat_equivalent/16];
            
            c_plane_normal = mirror_normal_calculator(mirror_handle,coll_point);
            collector_of_angle_rays(num_rays) = 180*acos(dot(c_plane_normal,-c_dir))/pi;
        end
    end
end

%Prunen der Ergebnisvektoren
collision_points = collision_points(:,1:num_rays);
ind_of_rays_that_hit_it = ind_of_rays_that_hit_it(1:num_rays);
angle_rays = collector_of_angle_rays(1:num_rays);

    %um die indces im Bezug auf die Sonne mitzuschleifen -> für
    %Backtracing!
    ind_of_rays_that_are_absorbed = ind_of_rays_from_small_mirror(ind_of_rays_that_hit_it);

%Berechnung der kumulativen Strahlenenergie
for i = 1:num_rays
    %In angle_rays steht der Winkel relativ zur Normalen des Spiegels.
    %Dieser wird in den radian-Wert umgerechnet und als cosinus zur Energie
    %hinzugefügt. Daraus ergibt sich, dass senkrechte Strahlen die Energie
    %1 und Strahlen parallel zur Spiegeloberfläche die Energie 0 besitzen.
    energy = energy + cos(pi*angle_rays(i)/180);
end


%plot a circle and hitting rays
if verbosity

end

end
