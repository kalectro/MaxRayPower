function [rays, ind_of_rays_that_hit_it] = collision_tracker(rays, mirr_func)
global ray
ind_of_rays_that_hit_it = [];
X = [0,0];
for ray_ind = 1:size(rays,3)
     ray = rays(:,1:2,ray_ind);
     [X,~,~,OUTPUT] = patternsearch(@distance_ray_mirror,X);
     X
     OUTPUT
end