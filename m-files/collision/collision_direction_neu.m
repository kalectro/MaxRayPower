function [right_side]=collision_direction_neu(ray,handle_to_mirr)
    
vorher = ray(:,1) - ray(:,2)*1e-3;
right_side = handle_to_mirr(vorher(1),vorher(2)) < vorher(3);  % Strahl kommt von unten
end