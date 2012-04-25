function [rays, ind_of_rays_that_hit_it] = collision_tracker(rays, mirr_func)
global mirr_borders

ind_of_rays_that_hit_it = [];

for ray_ind = 1:size(rays,3)
    c_candidate = rays(:,1,ray_ind);
    c_dir = rays(:,2,ray_ind);
    c_length = 0;
    
    % Gleich bis zu den mirror borders gehen:
    
    % Wenn der Strahl außerhalb startet:
    if ~(mirr_borders(1) < c_candidate(1) && c_candidate(1) < mirr_borders(2) &&...
    mirr_borders(3) < c_candidate(2) && c_candidate(2) < mirr_borders(4))
        %wenn man links/rechts vom Spiegel startet        
        %trifft der Strahl die Spiegel-Grenzen links/rechts?
        c_cut_plane_normal = [1;0;0];
        if c_candidate(1)<=mirr_borders(1)
            %s = schnittpunkt gerade mit linker Grenze
            c_distance_of_plane = mirr_borders(1);
        elseif c_candidate(1)>=mirr_borders(2)
            %s = schnittpunkt gerade mit rechter Grenze
            c_distance_of_plane = mirr_borders(2);
        %wenn man überm/unterm Spiegel startet
        %trifft der Strahl die Spiegel-Grenzen oben/unten?
        else
            c_cut_plane_normal = [0;1;0];
            if c_candidate(2)<=mirr_borders(3)
                %s = schnittpunkt gerade mit unterer Grenze
                 c_distance_of_plane = mirr_borders(3);
            elseif c_candidate(2)>=mirr_borders(4)
                %s = schnittpunkt gerade mit oberer Grenze
                 c_distance_of_plane = mirr_borders(4);
            end
        end
        s = c_candidate + (...
            (c_distance_of_plane...
            - dot(c_cut_plane_normal,c_candidate))...
            / dot(c_cut_plane_normal,c_dir))...
            * c_dir;
            
            % nein, er trifft die Grenzen nicht:
            if ~(...
                    (mirr_borders(3) < s(2) && s(2) < mirr_borders(4))...
                    ||...
                    (mirr_borders(1) < s(1) && s(1) < mirr_borders(2))...
                )
            c_length = 500;
            %doch, und er trifft den Spiegel überm Boden
            elseif s(3)>0
                c_candidate=s;
            %doch, und unterm Boden
            else
                c_length = 500;
            end     
    %Wenn innerhalb, und unterm Boden
    elseif c_candidate(3)<0
        c_length = 500;
    end
    
    %Jetzt ist man mindestens an den mirror borders
    
    %geh den Strahl entlang, bis du zum ersten Mal auf den Spiegel triffst
    while(mirr_func(c_candidate(1),c_candidate(2)) < c_candidate(3)...
            && c_length < 500) %random value!
        c_candidate = c_candidate + 0.1*c_dir;
        c_length = c_length + 0.1;
    end
    c_candidate = c_candidate - 0.05*c_dir;
    c_length = c_length - 0.05;
    
    %Wenn der Treffpunkt immernoch innerhalb der Grenzen: good ray!
    if(mirr_borders(1) < c_candidate(1) && c_candidate(1) < mirr_borders(2) &&...
        mirr_borders(3) < c_candidate(2) && c_candidate(2) < mirr_borders(4) &&...
        c_length < 500)
        rays(:,3,ray_ind) = c_candidate;
        ind_of_rays_that_hit_it = [ind_of_rays_that_hit_it ray_ind];
%         hold on
%         surf(x+c_candidate(1), y+c_candidate(2), z+c_candidate(3),...
%             'FaceColor', 'blue', 'EdgeColor', 'none');
%         hold off
    end
end

end