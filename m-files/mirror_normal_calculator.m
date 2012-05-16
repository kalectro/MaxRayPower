function c_plane_normal = mirror_normal_calculator(mirr_func,c_position)
diff_length = 0.1;

x_grad = [ c_position(1)+diff_length/2
           c_position(2)
           mirr_func(c_position(1)+diff_length/2,c_position(2))] ...
           -...
         [ c_position(1)-diff_length/2
           c_position(2)
           mirr_func(c_position(1)-diff_length/2,c_position(2))];
y_grad = [ c_position(1)
           c_position(2)+diff_length/2
           mirr_func(c_position(1),c_position(2)+diff_length/2)] ...
           -...
         [ c_position(1)
           c_position(2)-diff_length/2
           mirr_func(c_position(1),c_position(2)-diff_length/2)];

c_plane_normal = cross(x_grad, y_grad);
c_plane_normal = c_plane_normal / norm(c_plane_normal);
    
end