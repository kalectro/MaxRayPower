function [phi, theta] = make_phi_theta(number_Stuetzpunkte)
%Zeit von 5 Uhr bis 20 Uhr
t=linspace(5,20,number_Stuetzpunkte);

phi = 120*cos(pi*(t-5)/15);
theta = 90-59.3*sin(pi*(t-5)/15);
end