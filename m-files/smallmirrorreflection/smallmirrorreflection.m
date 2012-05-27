function [rays_from_mirror,ind_of_rays_from_small_mirror]=smallmirrorreflection(rays_to_mirror,focus,small_mirr_hand,ind_of_rays_that_hit_it,verbosity)
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

    % Transformationsmatrix für den kleinen Spiegel erzeugen
    [rot_matrix]=transformation(focus);

    % Strahlen in die Koordinaten des kleinen Spiegels transformieren
    for i=1:length(rays_to_mirror(1,1,:))
        %Matlab sagt ich soll mit A\b anstatt mit inv(A)*b invertieren...
        rays_to_mirror(:,1,i)=rot_matrix\(rays_to_mirror(:,1,i)-focus); % Stützvektor
        rays_to_mirror(:,2,i)=rot_matrix\rays_to_mirror(:,2,i); % Richtungsvektor
    end
    
    % Strahlen mit dem kleinen Spiegel kollidieren
    half_small_mirr_edge_length = sqrt(1)/2; %1qm Grundflaeche
    small_mirr_borders = [-half_small_mirr_edge_length half_small_mirr_edge_length -half_small_mirr_edge_length half_small_mirr_edge_length];
    
    %%%Hier tritt Fehler auf...
    [collision_points,ind_rays_that_hit_it]=collision_tracker_dychotom(rays_to_mirror,small_mirr_hand,small_mirr_borders);
    %%%
        %um die indces im Bezug auf die Sonne mitzuschleifen -> für
        %Backtracing!

        ind_of_rays_from_small_mirror = ind_of_rays_that_hit_it(ind_rays_that_hit_it);

    if verbosity
        %zwischendurch mal im small_mirror_KS den Stand plotten
        small_mirror_surface = zeros(10);
        [rays_x rays_y] = meshgrid(linspace(-half_small_mirr_edge_length, half_small_mirr_edge_length, 10));
        for x_ind = 1:10
            for y_ind = 1:10
                %Oberfläche berechnen
                small_mirror_surface(x_ind,y_ind) = small_mirr_hand(rays_x(x_ind,y_ind),rays_y(x_ind,y_ind));
            end
        end
        figure(2)
        hold on
        surf(rays_x,rays_y,small_mirror_surface,'FaceColor','red','EdgeColor','none','FaceAlpha',0.5);
        axis equal
        axis([-1 1 -1 1 -4 4])
        arrow3(permute(rays_to_mirror(:,1,:),[1 3 2])',permute(rays_to_mirror(:,1,:),[1 3 2])'+permute(rays_to_mirror(:,2,:),[1 3 2])','g',0.5,0.5)
        arrow3(permute(rays_to_mirror(:,1,ind_rays_that_hit_it),[1 3 2])',collision_points','y4',2,2)
        view(3)
        camlight
        hold off
        figure(1)
    end

    % Strahlen am kleinen Spiegel reflektieren
    tmp=zeros(3,2,length(ind_rays_that_hit_it)); % Matrix mit Strahlen, die reflektiert werden können
    for i=1:length(ind_rays_that_hit_it)
        tmp(:,1,i)=rays_to_mirror(:,1,ind_rays_that_hit_it(i)); % Stützvektor
        tmp(:,2,i)=rays_to_mirror(:,2,ind_rays_that_hit_it(i)); % Richtungsvektor
    end
    
    % etwas andere reflection-Funktion. Sonst verschwendet man vorhandenes Wissen%
%     rays_from_mirror=reflection_m(tmp,collision_points,small_mirr_hand);

    ray_dirs_from_mirror = reflection([tmp(:,2,:) permute(collision_points,[1 3 2])],small_mirr_hand);
    
    test=permute(ray_dirs_from_mirror,[1 3 2]);
  
    rays_from_mirror(:,1,:)=permute(collision_points,[1 3 2]);
    rays_from_mirror(:,2,:)=test;  
    
    % Strahlen in die ursprünglichen Koordinaten umrechnen
%     tmp=inv(rot_matrix);
    for i=1:length(rays_from_mirror(1,1,:))
        rays_from_mirror(:,1,i)=rot_matrix*rays_from_mirror(:,1,i)+focus;
        rays_from_mirror(:,2,i)=rot_matrix*rays_from_mirror(:,2,i);
    end
end
