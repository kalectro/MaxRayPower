function [num_rays,angle_rays,energy,collision_point,ind_of_rays_that_hit_it] = absorber(rays, ellipt_constants, mirr_func_handle)
if ~exist('ellipt_constants','var') || 
    ellipt_constants = [1 1 0 0 0 1]; %Kreis mit radius 1
end

energy = 0;
X = [0,0];
tol_mirr_distance = 10e-3;
collector_of_ind_of_rays_that_hit_it =  zeros(1,size(rays,3));
collector_of_collision_point = zeros(3,size(rays,3));
num_rays = 0;
collector_of_angle_rays = zeros(1,size(rays,3));

options = psoptimset('TolX',tol_mirr_distance,'MaxIter',500,'Display','off');


for ray_ind = 1:size(rays,3)   
    ray = rays(:,:,ray_ind);
    %elliptische borders
    [X,FVAL,~,OUTPUT] = patternsearch(@(x)distance_ray_mirror_anonym(x,ray,mirr_func_handle),...
        X,[],[],[],[],[],[],@(x)NONLCON_ellipse(x,ellipt_constants), options);

     
    if FVAL < tol_mirr_distance*2
        num_rays = num_rays+1;
        c_plane_normal = mirror_normal_calculator(mirr_func_handle,X);
        collector_of_angle_rays(num_rays) = 180*dot(c_plane_normal,-ray(:,2))/pi;
        collector_of_ind_of_rays_that_hit_it(num_rays) = ray_ind;
        collector_of_collision_point(:,num_rays) = [X(1);X(2);mirr_func_handle(X(1),X(2))];
    end
end

ind_of_rays_that_hit_it = collector_of_ind_of_rays_that_hit_it(1:num_rays);
angle_rays = collector_of_angle_rays(1:num_rays);
collision_point = collector_of_collision_point(:,1:num_rays);
end