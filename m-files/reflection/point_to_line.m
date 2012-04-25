function d = point_to_line(punkt, aufpunkt, richtung)
d = norm(cross(richtung,punkt - aufpunkt)) / norm(richtung);
end