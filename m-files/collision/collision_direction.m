% gibt zurück, ob der Lichtstrahl aus der richtigen Richtung kommt

% Rückgabewert: -1 Strahl kam von der Rückseite
%                1 Strahl trifft richtig auf den Spiegel
%                0 bei parallelem Auftreffen auf die Spiegeloberfl�che

% Parameter: strahl:  Richtungsvektor des Lichtstrahls
%            normale: Normalenvektor des Spiegels am Kollisionspunkt

function [out]=collision_direction(strahl,normale)
    out=-sign(dot(strahl,normale));
end