function [num_rays,angle_rays,energy,collision_point,ind_of_rays_that_hit_it] = absorber(rays, ellipt_constants)
if ~exist('ellipt_constants','var')
    ellipt_constants = [1 1 0 0 0 0.1]; %Kreis mit radius 0.1
end

X = [0,0];
collector_of_ind_of_rays_that_hit_it =  zeros(1,size(rays,3));
collision_point = zeros(3,size(rays,3));
num_rays = 0;
angle_rays = zeros(1,size(rays,3));

options = psoptimset('TolX',10e-3,'MaxIter',500,'Display','off');
tol_mirr_distance = 10e-3;

% A=[ 1  0
%    -1  0
%     0  1
%     0 -1    
%   ];
% b = [ mirr_borders(2)
%       mirr_borders(2)
%       mirr_borders(4)
%       mirr_borders(4)
%     ];


for ray_ind = 1:size(rays,3)   
    ray = rays(:,:,ray_ind);
    %kreisfoermige borders
    [X,FVAL,~,OUTPUT] = patternsearch(@(x)distance_ray_mirror_anonym(x,ray,mirror),...
        X,[],[],[],[],[],[],@(x)NONLCON(x,ellipt_constants), options);

%     %quadratische borders
%     [X,FVAL,~,OUTPUT] = patternsearch(@(x)distance_ray_mirror_anonym(x,ray,mirror),...
%         X,A,b,[],[],[],[],[], options);

%      X
%     OUTPUT
%     FVAL
     
    if FVAL < tol_mirr_distance
        num_rays = num_rays+1;
        angle_rays(num_rays) = 
        collector_of_ind_of_rays_that_hit_it(num_rays) = ray_ind;
        collision_point(:,ray_ind) = [X(1);X(2);mirror(X(1),X(2))];
    end
end

ind_of_rays_that_hit_it = collector_of_ind_of_rays_that_hit_it(1:num_rays);

end