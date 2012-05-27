function [valid_rays]=discard_rays_blocked_by_small_mirror(rays_to_mirror,focus,small_mirr_hand)
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
    
    rays_to_mirror(3,:,:)=-rays_to_mirror(3,:,:);
        
%         zwischendurch mal im small_mirror_KS den Stand plotten
%         small_mirror_surface = zeros(10);
%         [rays_x rays_y] = meshgrid(linspace(-half_small_mirr_edge_length, half_small_mirr_edge_length, 10));
%         for x_ind = 1:10
%             for y_ind = 1:10
%                 Oberfläche berechnen
%                 small_mirror_surface(x_ind,y_ind) = small_mirr_hand(rays_x(x_ind,y_ind),rays_y(x_ind,y_ind));
%             end
%         end
%         figure(2)
%         title('discard_rays_blocked_by_small_mirror')
%         hold on
%         surf(rays_x,rays_y,small_mirror_surface,'FaceColor','red','EdgeColor','none','FaceAlpha',0.5);
%         axis equal
%         axis([-1 1 -1 1 0 13])
%         arrow3(permute(rays_to_mirror(:,1,:),[1 3 2])',permute(rays_to_mirror(:,1,:),[1 3 2])'+permute(rays_to_mirror(:,2,:),[1 3 2])','g',0.5,0.5)
%         arrow3(permute(rays_to_mirror(:,1,ind_rays_that_hit_it),[1 3 2])',collision_points','y4',2,2)
%         view(3)
%         camlight
%         hold off
%         figure(1)
%     
%     rays_to_mirror(3,1,1)
    
    
    [~,ind_rays_that_hit_it]=collision_tracker_dychotom(rays_to_mirror,small_mirr_hand,small_mirr_borders);
    
%     ind_rays_that_hit_it
    
    valid_rays=1:size(rays_to_mirror,3);
%     binaer= ~(1:length(valid_rays) == )
    valid_rays(ind_rays_that_hit_it)=-1;
    valid_rays=valid_rays(valid_rays~=-1);
end