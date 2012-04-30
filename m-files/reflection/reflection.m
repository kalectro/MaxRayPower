function [rays] = reflection(rays, ind_of_rays_that_hit_it, verbosity)
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
diff_length = 0.1;

for good_ray = ind_of_rays_that_hit_it
    c_position = rays(1:2,3,good_ray); %x,y-position of current mirror collision
%     c_dir = rays(:,2,good_ray);
    
    x_grad = [ c_position(1)+diff_length/2
               c_position(2)
               mirr_func(c_position(1)+diff_length/2,c_position(2))] ...
               -...
             [ c_position(1)-diff_length/2
               c_position(2)
               mirr_func(c_position(1)-diff_length/2,c_position(2))];
    y_grad = [ c_position(1)
               c_position(2)+diff_length/2
               mirr_func(c_position(1),c_position(2)+diff_length/2)] ...
               -...
             [ c_position(1)
               c_position(2)-diff_length/2
               mirr_func(c_position(1),c_position(2)-diff_length/2)];
           
    c_plane_normal = cross(x_grad, y_grad);
    c_plane_normal = c_plane_normal / norm(c_plane_normal);

% % plot
% hold on
% arrow3(rays(:,3,good_ray)',rays(:,3,good_ray)'+5*c_plane_normal','b',1,1)
% hold off
    
    binormal = cross(c_plane_normal,rays(:,2,good_ray));
    binormal = binormal/norm(binormal);
    
    trinormal = cross(binormal, c_plane_normal);
    
    c_reflected_dir = -c_plane_normal * dot(c_plane_normal,rays(:,2,good_ray))...
        + trinormal*dot(trinormal, rays(:,2,good_ray));
    
    rays(:,4,good_ray) = c_reflected_dir;
    
% plot
if verbosity
arr_length = 0.2*mirr_quadrat_equivalent;
hold on
arrow3(rays(:,3,good_ray)'-arr_length*rays(:,2,good_ray)',rays(:,3,good_ray)','g',0.5,0.5)
arrow3(rays(:,3,good_ray)', rays(:,3,good_ray)'+arr_length*c_reflected_dir','y',0.5,0.5)
hold off
camlight
end

end

end