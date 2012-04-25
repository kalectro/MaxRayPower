function dist = distance_ray_mirror_anonym(X, ray, mirror)
    dist = point_to_line([X(1);X(2);mirror(X(1),X(2))],ray(:,1),ray(:,2));
end