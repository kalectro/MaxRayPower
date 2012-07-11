function solar_intensity = solar_intensity(theta)
%Ausgabe: Watt pro qm

r = 708;
theta_rad = pi*theta/180;

airmass = sqrt((r*cos(theta_rad))^2 + 2* r + 1) - r*cos(theta_rad);
%Quelle:
%http://en.wikipedia.org/wiki/Air_mass_%28solar_energy%29#math_A.3

AM = airmass;
solar_intensity = 1.1 * 1353 * 0.7^(AM^(0.678));
%Quelle:
%http://en.wikipedia.org/wiki/Air_mass_%28solar_energy%29#equation_I.1
end