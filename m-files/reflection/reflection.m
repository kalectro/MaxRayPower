function [reflected_rays] = reflection(rays, verbosity)
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
global mirr_borders
mirr_quadrat_equivalent = sqrt((mirr_borders(2)-mirr_borders(1))*(mirr_borders(4)-mirr_borders(3)));
sun_height = 4*mirr_quadrat_equivalent;
reflected_rays = zeros(3,size(rays,3));

axis equal
axis(1.1*[-sun_height sun_height -sun_height mirr_borders(2) -0.5*sun_height sun_height])
    
for ind_ray = 1:size(rays,3)
    %this used to be horribly wrong! it was c_position = rays(1:2,2,ind_ray);
    %that means it ... ah moment deutsch geht ja auch! Er hat hier immer
    %Spalte 2 genommen, also die Richtung anstatt der Kollisionsposition...
    %He moment, der letzte der an reflection was gemacht hat war doch...
    %der kai! zeige dich! :-P
    %ah nee moment es werden ja nciht die paths übergeben sondern ein
    %ray... aber trotzdem sollte dann die erste Spalte genommen werden
    %oder?
    %Ah wait, es wird ja im Spiegelung_Fokustest als erste Spalte die
    %Richtung und als Zweite Spalte die Kollisionsposition übergeben...
    %oookay ;) dann stimmt ja Spalte 2. Scheint so als müsste ich jetzt
    %einen riesigen Kommentar commiten ;)
    c_position = rays(1:2,2,ind_ray); %x,y-position of current mirror collision
%     c_dir = rays(:,2,good_ray);
    c_plane_normal = mirror_normal_calculator(@mirr_func,c_position);

% % plot
% hold on
% arrow3(rays(:,3,good_ray)',rays(:,3,good_ray)'+5*c_plane_normal','b',1,1)
% hold off
    
    binormal = cross(c_plane_normal,rays(:,1,ind_ray));
    binormal = binormal/norm(binormal);
    
    trinormal = cross(binormal, c_plane_normal);
    
    c_reflected_dir = -c_plane_normal * dot(c_plane_normal,rays(:,1,ind_ray))...
        + trinormal*dot(trinormal, rays(:,1,ind_ray));
    reflected_rays(:,ind_ray) = c_reflected_dir;
    
% plot
if verbosity
arr_length = 0.2*mirr_quadrat_equivalent;
hold on
arrow3(rays(:,2,ind_ray)'-arr_length*rays(:,1,ind_ray)',rays(:,2,ind_ray)','g',0.5,0.5)
arrow3(rays(:,2,ind_ray)', rays(:,2,ind_ray)'+arr_length*c_reflected_dir','y',0.5,0.5)
hold off
% camlight
end

end

end