function focus = focus_of_rays(rays, ind_of_rays_that_hit_it)
% 'rays' must be in the form described by "Datenformate.odt"

global mirr_radius
[x,y,z] = sphere;
num_refl_rays = length(ind_of_rays_that_hit_it);
focus_pts = zeros(3,num_refl_rays*(num_refl_rays-1)/2); %gauss-summe! (minus letztes Element) :) 

for ray_ind = 1:num_refl_rays
    
    good_ray = ind_of_rays_that_hit_it(ray_ind);
    
    % cut ray ist der Strahl, mit dem jetzt alle anderen geschnitten
    % werden. (Andere Strahlen = cutted rays)
    c_cut_ray = rays(:,4,good_ray);
    c_base_of_cut_ray = rays(:,3,good_ray);
    
    %Alle mit einem h�heren index (ray_ind+1) als der aktuelle cut ray werden mit ihm
    %geschnitten.
%     for cutted_rays_ind_ind = (ray_ind+1):num_refl_rays
     for j_index = 1:(num_refl_rays - ray_ind)   
        
        cutted_rays_ind_ind = j_index + ray_ind;
        
        c_cutted_ray = rays(:,4,ind_of_rays_that_hit_it(cutted_rays_ind_ind));
        c_base_of_cutted_ray = rays(:,3,ind_of_rays_that_hit_it(cutted_rays_ind_ind));
        
        % Vektor, der senkrecht auf beden Geraden steht, finden
        c_connecting_normal = cross(c_cut_ray, c_cutted_ray);
        c_connecting_normal = c_connecting_normal / norm(c_connecting_normal);
        % Hilfsebene bilden (aus Wiki)
        c_cut_plane_normal = cross(c_connecting_normal, c_cut_ray);
        c_distance_of_plane = dot(c_cut_plane_normal, c_base_of_cut_ray);
        % p auf Ebene: erf�llt n(ormal) * p(oint) = d(istance)
        
        % Jetzt cutted ray mit Hilfsebene schneiden. Dies gibt den Aufpunkt
        % f�r die connecting normal.
        % Formel resultiert durch Gleichsetzen von Ebenen- u. Geradengleichung
        c_cutted_ray_pt = c_base_of_cutted_ray + (...
            (c_distance_of_plane...
            - dot(c_cut_plane_normal,c_base_of_cutted_ray))...
            / dot(c_cut_plane_normal,c_cutted_ray))...
            * c_cutted_ray;
        
        c_dist_of_rays = dot(c_connecting_normal,c_base_of_cut_ray)...
            - dot(c_connecting_normal,c_base_of_cutted_ray);

%         c_dist_of_rays = -c_dist_of_rays;
        
        %Fokuspunkt in der Mitte zwischen den beiden Strahlen
        c_focus_pt = c_cutted_ray_pt + c_connecting_normal*c_dist_of_rays/2;
        
        
%         plot
%         hold on
%         surf(x+c_focus_pt(1), y+c_focus_pt(2), z+c_focus_pt(3),...
%             'FaceColor', 'yellow', 'EdgeColor', 'none');
%         hold off
        
        %�ble Indizierung mit find(), geht das nicht besser?
%         focus_pts(:,find(~any(abs(focus_pts),1),1,'first')) = c_focus_pt;

        focus_ind = ray_ind - 1 + j_index +  num_refl_rays*(ray_ind-1) - (ray_ind*(ray_ind-1))/2; %ADVANCED GAUSS!!!
        
        %Begrenzung der Entfernung des zweiten Spiegels.
        if norm(c_focus_pt) > 2*mirr_radius
            c_focus_pt = (c_focus_pt / norm(c_focus_pt) ) * 2 * mirr_radius;
        end
        focus_pts(:,focus_ind) = c_focus_pt;
    end
end

focus = mean(focus_pts,2);

end