%Berechnung der verwendeten Intensitätskurve

[phi_vector, theta_vector] = make_phi_theta(100);

i=1;
for theta = theta_vector
intensity(i) = solar_intensity(theta);
i=i+1;
end
plot(intensity)