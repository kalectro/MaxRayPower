%testskript
function test_absorber
global mirr_borders half_mirr_edge_length

half_mirr_edge_length = sqrt(10)/2; %10qm Grundflï¿½che
mirr_borders = [-half_mirr_edge_length half_mirr_edge_length -half_mirr_edge_length half_mirr_edge_length];

mirr_func_handle = @mirr_func;

energies = zeros(1,19);
numbers = zeros(1,19);
i = 0;
for phi = -90:10:90
    i = i+1;
    ray_paths = raymaker(phi,0,40);
    [num_rays,angle_rays,energy,collision_point,ind_of_rays_that_hit_it] = absorber(ray_paths, [1 1 0 0 0 1], mirr_func_handle);

%     disp(['bei phi = ' int2str(phi) '°:'])
    energies(i)=energy;
    numbers(i) = num_rays;

end

figure
subplot(2,1,1)
plot(-90:10:90,energies,'r','LineWidth',4)
title('Absorbierte Energie über dem Einstrahlwinkel')
% xlabel('phi')
ylabel('Energie')
subplot(2,1,2)
plot(-90:10:90,numbers,'b*','LineWidth',4)
title('Anzahl der treffenden Strahlen über dem Einstrahlwinkel')
xlabel('phi')
ylabel('Anzahl der Strahlen')
end