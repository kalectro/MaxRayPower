function [collision_points, ind_of_rays_that_hit_it] = collision_tracker_fibonacci(rays, mirror_handle)
global mirr_borders
mirr_quadrat_equivalent = sqrt((mirr_borders(2)-mirr_borders(1))*(mirr_borders(4)-mirr_borders(3)));
sun_height = 4*mirr_quadrat_equivalent;
ind_of_rays_that_hit_it = zeros(1,size(rays,3));
tol_mirr_distance = 10e-3;
collision_points=zeros(3,size(rays,3));
num_rays = 0;

for ray_ind = 1:size(rays,3)
    c_candidate = rays(:,1,ray_ind);
    c_dir = rays(:,2,ray_ind);
    c_length = 2*sun_height;
    mirror_geschnitten = false;
    fibo=[0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765 10946 17711 28657 46368 75025 121393 196418 317811 514299 832040];
    borders = [0 c_length];
    genauigkeit = 30;
    
    if(c_candidate(3)>0)
        %h�pf den Strahl entlang, bis du um die toleranz nah dran bist
        %while((borders(2)-borders(1)) > tol_mirr_distance)
        while genauigkeit > 3
            split = fibo(genauigkeit)/fibo(genauigkeit+1);
            c_length1 = borders(2) - (borders(2)-borders(1))*split;
            c_length2 = borders(1) + (borders(2)-borders(1))*split;
            c_candidate1 = c_candidate + c_dir * c_length1;
            c_candidate2 = c_candidate + c_dir * c_length2;
            a = mirror_handle(c_candidate1(1),c_candidate1(2));
            b = mirror_handle(c_candidate2(1),c_candidate2(2));
            if(abs(a - c_candidate1(3)) > abs(b - c_candidate2(3)))
                borders(1) = c_length1;
            else
                borders(2) = c_length2;
            end
            genauigkeit = genauigkeit - 1;
        end
        
        %Wenn der Treffpunkt immernoch innerhalb der Grenzen: good ray!
        if(mirr_borders(1) < c_candidate1(1) && c_candidate1(1) < mirr_borders(2) &&...
            mirr_borders(3) < c_candidate1(2) && c_candidate1(2) < mirr_borders(4))
            %�berpr�fung, ob der Strahl den Spiegel auf der richtigen Seite trifft
            strahl = c_dir;
            normale = mirror_normal_calculator(mirror_handle,c_candidate1);
            right_side=collision_direction(strahl,normale);
            if right_side 
                num_rays = num_rays+1;
                collision_points(:,num_rays) = c_candidate1;
                ind_of_rays_that_hit_it(num_rays) = ray_ind;
            end
        end
        collision_points = collision_points(:,1:num_rays);
        ind_of_rays_that_hit_it = ind_of_rays_that_hit_it(1:num_rays);
    end
end

%plot der Spiegeloberfl�che
[rays_x rays_y] = meshgrid(linspace(mirr_borders(1), mirr_borders(2), 10));
mirror_surface = zeros(10);
for x_ind = 1:10
    for y_ind = 1:10
        mirror_surface(x_ind,y_ind) = mirror_handle(rays_x(x_ind,y_ind),rays_y(x_ind,y_ind));
    end
end
hold on
surf(rays_x,rays_y,mirror_surface,'FaceColor','red','EdgeColor','none','FaceAlpha',0.8);
hold off
camlight

end