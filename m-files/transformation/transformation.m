function [drehmatrix,offset]=transformation(fokus)
    % Drehwinkel um die x-Achse berechnen
    if (fokus(2) > 0 && fokus(3) > 0) % Quadrant I
        alpha_x = pi + atan(abs(fokus(3)/fokus(2)));
    elseif (fokus(2) > 0 && fokus(3) < 0) % Quadrant II
        alpha_x = pi - atan(abs(fokus(3)/fokus(2)));
    elseif (fokus(2) < 0 && fokus(3) < 0) % Quadrant III
        alpha_x = pi - atan(abs(fokus(3)/fokus(2)));
    elseif (fokus(2) < 0 && fokus(3) > 0) % Quadrant IV
        alpha_x = pi + atan(abs(fokus(3)/fokus(2)));
    else alpha_x = 2*pi; %  auf einer der Achsen
    end
    
    % Drehwinkel um die y-Achse berechnen
    if (fokus(1) > 0 && fokus(2) > 0) % Quadrant I
        alpha_z = atan(abs(fokus(2)/fokus(1)));
    elseif (fokus(1) > 0 && fokus(2) < 0) % Quadrant II
        alpha_z = 2*pi - atan(abs(fokus(2)/fokus(1)));
    elseif (fokus(1) < 0 && fokus(2) < 0) % Quadrant III
        alpha_z = 3*pi - atan(abs(fokus(2)/fokus(1)));
    elseif (fokus(1) < 0 && fokus(2) > 0) % Quadrant IV
        alpha_z = 3*pi + atan(abs(fokus(2)/fokus(1)));
    else alpha_z = 2*pi;
    end    

    drehmatrix=... %[1 0 0;0 cos(alpha_x) -sin(alpha_x); 0 sin(alpha_x) cos(alpha_x)];
        [cos(alpha_z) -sin(alpha_z) 0; sin(alpha_z) cos(alpha_z) 0; 0 0 1];
    offset=fokus;
end