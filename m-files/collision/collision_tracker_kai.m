function [rays, ind_of_rays_that_hit_it] = collision_tracker_kai(rays, mirror)
global mirr_borders
ind_of_rays_that_hit_it = [];
X = [0,0];
options = psoptimset('TolX',0.01,'MaxIter',500,'Display','off');
% options = psoptimset('MaxIter',50,'Display','off');
tol_mirr_distance = 0.1;
A=[ 1  0
   -1  0
    0  1
    0 -1    
  ];
b=repmat(mirr_borders(2),4,1);

for ray_ind = 1:size(rays,3)
     ray = rays(:,1:2,ray_ind);
     %kreisförmige borders
%      [X,FVAL,~,OUTPUT] = patternsearch(@(x)distance_ray_mirror_anonym(x,ray,mirror),...
%          X,[],[],[],[],[],[],@NONLCON, options);

     %quadratische borders
     [X,FVAL,~,OUTPUT] = patternsearch(@(x)distance_ray_mirror_anonym(x,ray,mirror),...
         X,A,b,[],[],[],[],[], options);
     %      X
%      OUTPUT
%      FVAL
     
     if FVAL < tol_mirr_distance
         ind_of_rays_that_hit_it = [ind_of_rays_that_hit_it ray_ind];
         rays(:,3,ray_ind) = [X(1);X(2);mirror(X(1),X(2))];
     end
end