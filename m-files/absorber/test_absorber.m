%testskript
function test_absorber
global mirr_borders half_mirr_edge_length

half_mirr_edge_length = sqrt(10)/2; %10qm Grundfl�che
mirr_borders = [-half_mirr_edge_length half_mirr_edge_length -half_mirr_edge_length half_mirr_edge_length];

mirr_func_handle = @mirr_func;

ray_paths = raymaker(50,0);

[num_rays,angle_rays,~,collision_point,ind_of_rays_that_hit_it] = absorber(ray_paths, [1 1 0 0 0 10], mirr_func_handle)

end