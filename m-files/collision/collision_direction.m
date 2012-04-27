% gibt zurück, ob der Lichtstrahl aus der richtigen Richtung kommt

% Rückgabewert: -1 Strahl kam von der Rückseite
%                1 Strahl trifft richtig auf den Spiegel

% Parameter: strahl:  Richtungsvektor des Lichtstrahls
%            normale: Normalenvektor des Spiegels am Kollisionspunkt

function [out]=collision_direction(strahl,normale)
    out=-dot(strahl,normale)/abs(dot(strahl,normale));
end