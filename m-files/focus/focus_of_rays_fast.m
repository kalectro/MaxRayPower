% berechnet den Fokuspunkt von allen Strahlen mit festem Abstand zum
% Ursprung (alle Fokuspunkte liegen auf einer Halbkugel um den Ursprung
% herum)
function focus = focus_of_rays_fast(rays,mirr_quadrat_equivalent)
% global mirr_borders
% mirr_quadrat_equivalent = sqrt((mirr_borders(2)-mirr_borders(1))*(mirr_borders(4)-mirr_borders(3)));

a(:,:) = rays(:,1,:);   % alle Aufpunkte
b(:,:) = rays(:,2,:);   % alle Richtungen
aufpunkt = mean(a,2);   % Mittelpunkt der Aufpunkte
direction = mean(b,2);  % Richtungsmittel
temp = dot(aufpunkt,direction)/norm(direction)^2;   % Rechenzeitbeschleunigung
t = -temp + sqrt(temp^2 + ((mirr_quadrat_equivalent^2)/2 - norm(aufpunkt)^2)/norm(direction)^2);    % Skalar mit dem der Richtungsvektor gestreckt werden muss um richtige Entfernung zum Ursprung zu erhalten
direction = direction * t;  % Verlängerung der Richtung
focus = aufpunkt + direction;   % Berechung des Fokus
if norm(focus) > mirr_quadrat_equivalent/sqrt(2)+0.01   % Überprüfung ob Fokus innerhalb der Halbkugel liegt
    focus = [0;0;0];
end
end