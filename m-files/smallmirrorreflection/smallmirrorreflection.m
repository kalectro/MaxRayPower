function [rays_from_mirror,new_focus]=smallmirrorreflection(rays_to_mirror,focus)
    % Transformationsmatrix für den kleinen Spiegel erzeugen
    [rot_matrix,small_mirror_pos]=transformation(focus);
    
    % Strahlen in die Koordinaten des kleinen Spiegels transformieren
    for i=1:length(rays_to_mirror(1,:))
        rays_to_mirror=rot_matrix*rays_to_mirror(:,i);
    end
    
    % Strahlen mit dem kleinen Spiegel kollidieren
    
    % Strahlen am kleinen Spiegel reflektieren
    
    % Strahlen in die ursprünglichen Koordinaten umrechnen
end