% Testroutine für reflection_m.m

function []=reflection_m_test()
    rays=[0,0;-2,2;2,-2]
    collision_point=[0;0;0];
    
    reflected_rays=reflection_m(rays,collision_point,@mirr_func_dummy)
    
    % alles plotten
    figure
    hold on
    axis([-1 1 -4 4 -1 4])
    axis image vis3d
    arrow3(rays(:,1)',(rays(:,1)+rays(:,2))','',1,1);  % Strahl
    arrow3(reflected_rays(:,1)',(reflected_rays(:,1)+reflected_rays(:,2))','r',1,1);  % reflektierter Strahl
    hold off
    camlight
    lighting gouraud
    view(3)
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
end