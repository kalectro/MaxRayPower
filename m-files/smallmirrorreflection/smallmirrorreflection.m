%% hier muss noch gecheckt werden, ob die funktionen richtig verwendet werden...

%% new_focus nicht initialisiert!!!


function [rays_from_mirror,ind_of_rays_from_small_mirror]=smallmirrorreflection(rays_to_mirror,focus,small_mirr_hand,ind_of_rays_that_hit_it)
    % Transformationsmatrix f�r den kleinen Spiegel erzeugen
    [rot_matrix]=transformation(focus);

    % Strahlen in die Koordinaten des kleinen Spiegels transformieren
    for i=1:length(rays_to_mirror(1,1,:))
        %Matlab sagt ich soll mit A\b anstatt mit inv(A)*b invertieren...
        rays_to_mirror(:,1,i)=rot_matrix\(rays_to_mirror(:,1,i)- focus); % St�tzvektor
        rays_to_mirror(:,2,i)=rot_matrix\rays_to_mirror(:,2,i); % Richtungsvektor
    end
    
    % Strahlen mit dem kleinen Spiegel kollidieren
    half_small_mirr_edge_length = sqrt(1)/2; %1qm Grundflaeche
    small_mirr_borders = [-half_small_mirr_edge_length half_small_mirr_edge_length -half_small_mirr_edge_length half_small_mirr_edge_length];
    [collision_points,ind_rays_that_hit_it]=collision_tracker_dychotom(rays_to_mirror,small_mirr_hand,small_mirr_borders);
        %um die indces im Bezug auf die Sonne mitzuschleifen -> f�r
        %Backtracing!
        ind_of_rays_from_small_mirror = ind_of_rays_that_hit_it(ind_rays_that_hit_it);
        
    % Strahlen am kleinen Spiegel reflektieren
    tmp=zeros(3,2,length(ind_rays_that_hit_it)); % Matrix mit Strahlen, die reflektiert werden k�nnen
    for i=1:length(ind_rays_that_hit_it)
        tmp(:,1,i)=rays_to_mirror(:,1,ind_rays_that_hit_it(i)); % St�tzvektor
        tmp(:,2,i)=rays_to_mirror(:,2,ind_rays_that_hit_it(i)); % Richtungsvektor
    end
    %[rays_from_mirror]=reflection(tmp,'verbose'); %% !!! Wo kann ich die Mirror-Funktion �bergeben ????
    
    % etwas andere reflection-Funktion. Sonst verschwendet man vorhandenes Wissen%
    rays_from_mirror=reflection_m(tmp,collision_points,small_mirr_hand);
    
    % Strahlen in die urspr�nglichen Koordinaten umrechnen
%     tmp=inv(rot_matrix);
    for i=1:length(rays_from_mirror(1,1,:))
        rays_from_mirror(:,1,i)=rot_matrix*rays_from_mirror(:,1,i)+focus;
        rays_from_mirror(:,2,i)=rot_matrix*rays_from_mirror(:,2,i);
    end
end
