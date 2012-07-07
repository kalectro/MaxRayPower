function plot_all_the_rays(ray_paths, ind_of_valid_rays, ind_of_rays_that_are_absorbed, ind_of_rays_that_are_absorbed_second, handle_to_mirror_function, small_mirr_hand, focus, ellipt_parameters, plotmode,ind_of_big_mirror_rays)
%default parameters
if ~exist('plotmode','var')
    plotmode.smallmirr = true;
    plotmode.smallmirr_axissystem = true;
    
end

global mirr_borders half_mirr_edge_length
half_mirr_edge_length = sqrt(10)/2; %10qm Grundflaeche
mirr_borders = [-half_mirr_edge_length half_mirr_edge_length -half_mirr_edge_length half_mirr_edge_length];
%plot der Spiegeloberflaeche
% figure;
axis equal
axis([1.5*mirr_borders 0 3*half_mirr_edge_length])
[rays_x rays_y] = meshgrid(linspace(mirr_borders(1), mirr_borders(2), 10));
mirror_surface = zeros(10);
for x_ind = 1:10
    for y_ind = 1:10
        mirror_surface(x_ind,y_ind) = handle_to_mirror_function(rays_x(x_ind,y_ind),rays_y(x_ind,y_ind));
    end
end
hold on
surf(rays_x,rays_y,mirror_surface,'FaceColor','red','EdgeColor','none','FaceAlpha',0.8);
hold off

%debug
% pause

%plot der Absorberoberfläche
hold on
circle_coord = zeros(360,3);
r=ellipt_parameters(6);
for phi_circle = 1:360
    circle_coord(phi_circle,1) = r*cos(pi*phi_circle/180);
    circle_coord(phi_circle,2) = r*sin(pi*phi_circle/180);
    circle_coord(phi_circle,3) = handle_to_mirror_function(circle_coord(phi_circle,1),circle_coord(phi_circle,2));
end
patch(circle_coord(:,1),circle_coord(:,2),circle_coord(:,3),'b')
hold off

%debug
% pause

%plot reflection with latest phi and theta
if plotmode.smallmirr
  %the small mirror
    half_small_mirr_edge_length = sqrt(1)/2; %1qm Grundflaeche
    [rays_x rays_y] = meshgrid(linspace(-half_small_mirr_edge_length, half_small_mirr_edge_length, 10));
    small_mirror_surface = zeros(10);
    drehmatrix = transformation(focus);
    for x_ind = 1:10
        for y_ind = 1:10
            %Oberfläche berechnen
            small_mirror_surface(x_ind,y_ind) = small_mirr_hand(rays_x(x_ind,y_ind),rays_y(x_ind,y_ind));
            %rotation
            tmp = drehmatrix*[rays_x(x_ind,y_ind);rays_y(x_ind,y_ind);small_mirror_surface(x_ind,y_ind)];
            rays_x(x_ind,y_ind) = tmp(1);
            rays_y(x_ind,y_ind) = tmp(2);
            small_mirror_surface(x_ind,y_ind) = tmp(3);
        end
    end
    %translation
    rays_x = rays_x + focus(1);
    rays_y = rays_y + focus(2);
    small_mirror_surface = small_mirror_surface + focus(3);

    %plotten
hold on
    surf(rays_x,rays_y,small_mirror_surface,'FaceColor','red','EdgeColor','none','FaceAlpha',0.5);
hold off

%debug
% pause

end
  %the rays 
  if ~isempty(ind_of_valid_rays)
      if ~isempty(ind_of_rays_that_are_absorbed_second)
          hold on
        %mit smallmirror: nur die die auch den kleinen spiegel treffen
        if plotmode.smallmirr
            arrow3((permute(ray_paths(:,1,ind_of_rays_that_are_absorbed_second),[1 3 2]))',(permute(ray_paths(:,3,ind_of_rays_that_are_absorbed_second),[1 3 2]))','y',0.5,0.5)
%             pause
            arrow3((permute(ray_paths(:,3,ind_of_rays_that_are_absorbed_second),[1 3 2]))',(permute(ray_paths(:,5,ind_of_rays_that_are_absorbed_second),[1 3 2]))','y',0.5,0.5)
%             pause
        else
            %ohne smallmirror: alle die den grossen spiegel treffen
            arrow3((permute(ray_paths(:,1,ind_of_big_mirror_rays),[1 3 2]))',(permute(ray_paths(:,3,ind_of_big_mirror_rays),[1 3 2]))','y',0.5,0.5)
%             pause
            arrow3((permute(ray_paths(:,3,ind_of_big_mirror_rays),[1 3 2]))',20*(permute(ray_paths(:,4,ind_of_big_mirror_rays),[1 3 2]))','y',0.5,0.5)
%             pause
        end
          hold off
      end
      if ~isempty(ind_of_rays_that_are_absorbed)
          hold on
          %mit smallmirror: die plotten, die direkt den absorber treffen
          if plotmode.smallmirr
            arrow3((permute(ray_paths(:,5,ind_of_rays_that_are_absorbed),[1 3 2]))',permute(ray_paths(:,7,ind_of_rays_that_are_absorbed),[1 3 2])','y',0.5,0.5)
          end
          hold off
      end
  end
  %test fuer die Koordinaten des kleinen Spiegels
  if plotmode.smallmirr_axissystem
    ex=[1;0;0];
    ey=[0;1;0];
    ez=[0;0;1];
    e1=drehmatrix*ex+focus;
    e2=drehmatrix*ey+focus;
    e3=drehmatrix*ez+focus;
    hold on
    arrow3(focus',e1','r2',1,1)
    arrow3(focus',e2','b2',1,1)
    arrow3(focus',e3','m2',1,1)
    hold off
  end
xlabel('X-Achse')
ylabel('Y-Achse')
zlabel('Z-Achse')
end