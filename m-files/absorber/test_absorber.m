%testskript
function test_absorber
global mirr_borders half_mirr_edge_length

half_mirr_edge_length = sqrt(10)/2; %10qm Grundfl�che
mirr_borders = [-half_mirr_edge_length half_mirr_edge_length -half_mirr_edge_length half_mirr_edge_length];

mirr_func_handle = @mirr_func;

ray_paths = raymaker(0,0,20);

[num_rays,angle_rays,energy,collision_point,ind_of_rays_that_hit_it] = absorber(ray_paths, [1 1 0 0 0 0.5], mirr_func_handle)

end