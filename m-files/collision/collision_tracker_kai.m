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

%plot der Spiegeloberfläche
[rays_x rays_y] = meshgrid(linspace(mirr_borders(1), mirr_borders(2), 10));
mirror_surface = zeros(10);
for x_ind = 1:10
    for y_ind = 1:10
        mirror_surface(x_ind,y_ind) = mirror(rays_x(x_ind,y_ind),rays_y(x_ind,y_ind));
    end
end
hold on
surf(rays_x,rays_y,mirror_surface,'FaceColor','red','EdgeColor','none','FaceAlpha',0.5);
hold off
camlight
end