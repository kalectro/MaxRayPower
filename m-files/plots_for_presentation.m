%%Mirror Surface with Sunrays over Time
close all
%mirr surface
global mirr_borders half_mirr_edge_length
half_mirr_edge_length = sqrt(10)/2; %10qm Grundflaeche
mirr_borders = [-half_mirr_edge_length half_mirr_edge_length -half_mirr_edge_length half_mirr_edge_length];
ord=2;
spiegel_gross = [[0 0.0353 0 1/20 1/20 0 0 0] zeros(1,35-((ord+1)^2-1))];
handle_to_mirror_function = @(x,y)mirr_func2(x,y,spiegel_gross);
figure;
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
    axis vis3d image off
    axis([-7 7 -10 5 -1 8])
    view(-160,30)
    camlight
    lighting gouraud
    view(-139,48)
    
%beschriftung
hold on
arrow3([5 4 -3],[5 -8 -3],'k2.5',5,10)
text(4,3,-3,'Süden')
cs_source = [-6 -5 -1];
arrow3(cs_source,cs_source+[2 0 0],'r')
text(cs_source(1)+3,cs_source(2),cs_source(3),'x')
arrow3(cs_source,cs_source+[0 2 0],'g')
text(cs_source(1),cs_source(2)+3,cs_source(3),'y')
arrow3(cs_source,cs_source+[0 0 2],'b')
text(cs_source(1),cs_source(2),cs_source(3)+3,'z')
hold off

%Sunrays
[x,y,z] = sphere;
[phivec,thetvec] = make_phi_theta(15);
for time = 1:15
    phi = phivec(time);
    theta=thetvec(time);
rays = raymaker(phi,theta,10, 'nonverbose');
raystartpts=zeros(3,100);
raystartpts(:,:) = rays(:,1,:);
% break
sunpoint = mean(raystartpts,2)/2;
sunray = rays(:,2,1);
colormap(hot)
caxis([-1 6])
hold on
surf(x+sunpoint(1),y+sunpoint(2),z+sunpoint(3),'EdgeColor','none')
arrow3(sunpoint' + sunray',sunpoint' + 2*sunray','y',1,1,[])
hold off
pause
namestring = sprintf('../../sunpath_%d',time);
saveas(gcf, namestring, 'png')
end

