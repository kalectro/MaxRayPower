function dist = distance_ray_mirror(X)
    global ray
    dist = point_to_line([X(1);X(2);mirr_func(X(1),X(2))],ray(:,1),ray(:,2));
end