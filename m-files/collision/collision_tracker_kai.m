function [rays, ind_of_rays_that_hit_it] = collision_tracker(rays, mirror)
% global ray
ind_of_rays_that_hit_it = [];
X = [0,0];
for ray_ind = 1:size(rays,3)
     ray = rays(:,1:2,ray_ind);
     
     [X,~,~,OUTPUT] = patternsearch(@(x)distance_ray_mirror_anonym(x,ray,mirror),X);
     X
     OUTPUT
end