% Funktion liefert Stütz- und Richtungsvektoren reflektierter Strahlen

% Parameter:
%             rays             : Stütz- und Richtungsvektoren einfallender Strahlen
%             collision_points : Treffpunkte am Spigel
%             mirr_func        : Handler der Spiegelfunktion
% Rückgabe:
%             reflected_rays   : Stütz- und Richtungsvektoren reflektierter Strahlen

function [reflected_rays]=reflection_m(rays, collision_points, mirr_func)
    reflected_rays=zeros(3,2,length(rays(1,1,:))); % Ausgabe vorbereiten
    
    for i=1:length(rays(1,1,:))
        c_plane_normal = mirror_normal_calculator(mirr_func,collision_points(1:2,i)); % Normale im Kollisionspunkt
        
        % ab hier aus der reflection-Funktion von Felix übernommen (ohne gegencheck)
        % @FELIX: habe jedoch aus 1 überall 2 gemacht, da ich den
        %         Richtungsvektor spiegeln will
        binormal = cross(c_plane_normal,rays(:,2,i));  
        binormal = binormal/norm(binormal);
    
        trinormal = cross(binormal, c_plane_normal);
    
        c_reflected_dir = -c_plane_normal * dot(c_plane_normal,rays(:,2,i))...
                          + trinormal*dot(trinormal, rays(:,2,i));
                      
        % Rückgabe etwas angepasst
        reflected_rays(:,1,i) = collision_points(:,i); % Stützvektor
        reflected_rays(:,2,i) = c_reflected_dir;       % Richtungsvektor
    end
end