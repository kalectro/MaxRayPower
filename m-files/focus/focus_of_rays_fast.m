function focus = focus_of_rays_fast(rays)
global mirr_borders
mirr_quadrat_equivalent = sqrt((mirr_borders(2)-mirr_borders(1))*(mirr_borders(4)-mirr_borders(3)));

a(:,:) = rays(:,1,:);
b(:,:) = rays(:,2,:);
aufpunkt = mean(a,2);
direction = mean(b,2);
temp = dot(aufpunkt,direction)/norm(direction)^2;
t = -temp + sqrt(temp^2 + ((mirr_quadrat_equivalent^2)/2 - norm(aufpunkt)^2)/norm(direction)^2);
direction = direction * t;
focus = aufpunkt + direction;
if norm(focus) > mirr_quadrat_equivalent/sqrt(2)+0.01
    focus = [0;0;0];
end
end