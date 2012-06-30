function strahlendichte = Objective_function(A,modus)
% function strahlen_gesamt = Objective_function(A,modus)
% function zum Ausrechnen des Fokus fuer verschiedene Einstrahlwinkel
%  close all
    
    % Debugging
    ['Parametervektor dieser Iteration']
    A
    pauseButton();

% Parameter um den Ablauf zu beeinflussen
% theta_vector = -80:20:80;
% phi_vector = -80:20:80;
verbosity = 'nonverbose';

% Notwendige Initialisierungen
strahlen_gesamt = 0;
focus_line = [];
%mirr_borders are rectangular
global mirr_borders half_mirr_edge_length
half_mirr_edge_length = sqrt(10)/2; %10qm Grundflaeche
mirr_borders = [-half_mirr_edge_length half_mirr_edge_length -half_mirr_edge_length half_mirr_edge_length];
mirr_quadrat_equivalent = sqrt((mirr_borders(2)-mirr_borders(1))*(mirr_borders(4)-mirr_borders(3)));
[x,y,z] = sphere;
number_zeitpunkte=modus.number_zeitpunkte;
num_rays_per_row = modus.num_rays_per_row;
[phi_vector, theta_vector] = make_phi_theta(number_zeitpunkte);
sun_area = 8 * half_mirr_edge_length^2; %ist so
%Leistungsdichte fuer alle Zeitpunkte mit Hilfe von Wiki-Formel ausrechnen
%[Wdichte_vektor] = leistungsdichte(theta_vector);
%[W_vektor] = Wdichte_vektor*sun_area;
%[WperRay_vektor] = W_vektor / num_rays_per_row^2;
%In jedem Zeitschritt muss jetzt 
%WperRay_vektor(timestep_ind)*length(ind_of_rays_that_are_absorbed)
%hochgezaehlt werden.
%Die Tagesleistung ist dann jene Summe mal 15/number_zeitpunkte (=kWh/d).
%Diese negiert koennen wir dann als Rueckgabe an den optimizer geben.
%%%%%%%%

%Aufteilung von A:
% 1) Ellipsenparameter (6)
% 2) Grosser Spiegel (Ordnung+1)^2-1 (minus eins, da der Offset entfaellt)
% 3) Kleiner Spiegel (dito)
% 4) Focus-Entfernung (1)

ord = modus.ordnung;
num_mirr_param = (ord+1)^2-1;
    
% Parameter aufteilen 
if modus.absorber_optimieren
    if length(A) < 6
        error('A ist zu klein!')
    end
    ellipt_parameters = A(1:6);
    if length(A) > 6
        A = A(7:end);
    else
        A=[];
    end
else
    ellipt_parameters = [1 1 0 0 0 0.5];%Parameter fï¿½r die Form der Absorberellipse
end

if modus.grossen_spiegel_optimieren
    if length(A) < num_mirr_param
        error('A ist zu klein!')
    end
    spiegel_gross=A(1:num_mirr_param);
    if length(A) > num_mirr_param
        A=A(num_mirr_param+1:end);
    else
        A=[];
    end
else
    spiegel_gross=zeros(1,num_mirr_param);
end

if modus.kleinen_spiegel_optimieren
    if length(A) < num_mirr_param
        error('A ist zu klein!')
    end
    spiegel_klein=A(1:num_mirr_param);
    if length(A) > num_mirr_param
        A=A(num_mirr_param+1:end);
    else
        A=[];
    end
else
    spiegel_klein=zeros(1,num_mirr_param);
end

if modus.spiegelpfad_radius_optimieren
    if length(A) < 1
        error('A ist zu klein!')
    end
    radius = A(1);
    if length(A) > 1
        A=A(2:end);
    else
        A=[];
    end
else
    radius=mirr_quadrat_equivalent;
end

%Auffuellen
spiegel_gross = [spiegel_gross zeros(1,35-((ord+1)^2-1))];
spiegel_klein = [spiegel_klein zeros(1,35-((ord+1)^2-1))];

%Handles
handle_to_mirror_function = @(x,y)mirr_func2(x,y,spiegel_gross);
small_mirr_hand = @(x,y)mirr_func2(x,y,spiegel_klein);
small_mirr_hand_inv = @(x,y)mirr_func_small_inv(x,y,spiegel_klein);

% %plot der Spiegeloberflaeche
% [rays_x rays_y] = meshgrid(linspace(mirr_borders(1), mirr_borders(2), 10));
% mirror_surface = zeros(10);
% for x_ind = 1:10
%     for y_ind = 1:10
%         mirror_surface(x_ind,y_ind) = handle_to_mirror_function(rays_x(x_ind,y_ind),rays_y(x_ind,y_ind));
%     end
% end
% hold on
% surf(rays_x,rays_y,mirror_surface,'FaceColor','red','EdgeColor','none','FaceAlpha',0.8);
% hold off
% axis vis3d image


%%%%%
%FOR-Schleife (geht alle Einstrahlwinkel durch)
%%%%%

for timestep_ind = 1:length(phi_vector)

    theta = theta_vector(timestep_ind);
    phi = phi_vector(timestep_ind);

    if strcmp(verbosity,'verbose')
        disp(['Werte um ' num2str(5+(15/number_zeitpunkte)*(timestep_ind-1)) ' Uhr'])
    end
    %%%%%%%%%%%%%%%%%% Function call!
    % Strahlen generieren
    ray_paths = raymaker(phi, theta, num_rays_per_row,'nonverbose');
    %%%%%%%%%%%%%%%%%%

    %ZEITFRESSER (20sek bei 100 Strahlen)
    %Verbesserung 23.04. ->> 5,3sek bei 100 Strahlen
    %Verbesserung 20.05. ->> 0,1sek bei 100 Strahlen
    %Verbesserung 23.05. ->> 4  sek bei 16000 Strahlen (40*40 und 10 Zeitpkte)
    %Weitere Verbesserung moeglich:
    %   1. Spiegel-z-Hoehe begrenzen (28.06.: ca. 5 Meter)
    %   2. Analytische Loesung fuer t, erste Nullstele mit NewtonRaphson finden,
    %      und dann Treffer von oben/unten unterscheiden
    %%%%%%%%%%%%%%%%%% Function call!
    % Kollisionen mit Spiegel und boundaries checken.
    [collision_points, ind_of_valid_rays] = collision_tracker_dychotom(ray_paths(:,1:2,:), handle_to_mirror_function);
    if isempty(ind_of_valid_rays) % wenn kein Strahl mehr existiert
        if strcmp(verbosity,'verbose')
        disp('Anzahl direkt absorbierter Strahlen: 0')
        disp('Anzahl sekundï¿½r absorbierter Strahlen: 0')
        end
        continue  % naechster Winkel
    end
    ray_paths(:,3,ind_of_valid_rays) = collision_points;
    %%%%%%%%%%%%%%%%%%   
    
    %%%%%%%%%%%%%%%%%% Function call!
    % Reflektierte Richtung berechnen und in ray_paths eintragen.
    reflection1_direction = reflection(ray_paths(:,2:3,ind_of_valid_rays),handle_to_mirror_function, 'nonverbose');
    ray_paths(:,4,ind_of_valid_rays) = reflection1_direction;
    %%%%%%%%%%%%%%%%%%

    %Zeitfresser
    %Moeglichkeiten der Verbesserung:
    %1. Schnitte von Schlaeuchen in einer MxNxP - Matrix (Hough)
    %2. Gewichtung von Fokuspunkten nach: nahe Nachbarn: gut!, nachbarn weit
    %weg: boese! (z.B weight = sum(1/dist_to_neighbor_i)) over i
    %3. Gegen das Zeitfressen: jeder Strahl berechnet seinen Schnitt nur mit den
    %10 Strahlen, die ihm am nï¿½chsten sind, bzw die ihm nï¿½her als xy cm sind
    %%%%%%%%%%%%%%%%%% Function call!
    % Fokuspunkt berechnen
    focus = focus_of_rays_fast(ray_paths(:,3:4,ind_of_valid_rays),radius);
    %%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%
    % vom kleinen Spiegel geblockte Strahlen verwerfen
    ind_of_valid_rays=discard_rays_blocked_by_small_mirror(ray_paths(:,1:2,:),focus,small_mirr_hand_inv);
    %%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%% Function call!
    % Direktabsorbtion
    [num_rays,~,~,absorption_points,ind_of_rays_that_are_pre_absorbed] =...
        absorber(ray_paths(:,1:2,ind_of_valid_rays), ellipt_parameters, handle_to_mirror_function,'nonverbose',ind_of_valid_rays);
    ray_paths(:,5:6,ind_of_rays_that_are_pre_absorbed)=ray_paths(:,1:2,ind_of_rays_that_are_pre_absorbed);  % der Vollstï¿½ndigkeit halber, damit ein Plot mï¿½glich ist
    ray_paths(:,7,ind_of_rays_that_are_pre_absorbed)=absorption_points;
    if strcmp(verbosity,'verbose')
        disp(['Anzahl direkt absorbierter Strahlen: ' int2str(num_rays)])
    end
    %%%%%%%%%%%%%%%%%%
    
    % Kollisionen mit grossem Spiegel, die direkt absorbiert wurden nicht weiter beruecksichtigen.
    for ray_ind = 1:size(ind_of_rays_that_are_pre_absorbed,2)
        ind_of_valid_rays = ind_of_valid_rays(ind_of_valid_rays~=ind_of_rays_that_are_pre_absorbed(ray_ind)); 
    end
    %%%%%%%%%%%%%%%%%%   

    %%%%%%%%%%%%%%%%%% Function call!
    %kleiner Spiegel
    rays_to_mirror=ray_paths(:,3:4,ind_of_valid_rays);
    [rays_from_small_mirror,ind_of_rays_from_small_mirror]=...
        smallmirrorreflection(rays_to_mirror,focus,small_mirr_hand,ind_of_valid_rays,'nonverbose');
    ray_paths(:,5:6,ind_of_rays_from_small_mirror)=rays_from_small_mirror;
    %%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%% Function call!
    %sekundaere Absorption
    [num_rays,~,~,absorption_points,ind_of_rays_that_are_absorbed_second] =...
        absorber(rays_from_small_mirror, ellipt_parameters, handle_to_mirror_function,'nonverbose',ind_of_rays_from_small_mirror);
    ray_paths(:,7,ind_of_rays_that_are_absorbed_second)=absorption_points;
    ind_of_rays_that_are_absorbed = [ind_of_rays_that_are_absorbed_second ind_of_rays_that_are_pre_absorbed];
    if strcmp(verbosity,'verbose')
        disp(['Anzahl sekundï¿½r absorbierter Strahlen: ' int2str(num_rays)])
    end
    %%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%
    %%%ENDE der Kernfunktionen
    %%%%%%%%%%%%%%%%%%
    
    %Alle Fokuspunkte in einer Matrix speichern
    focus_line = [focus_line focus];
    
    %%% Es folgen schï¿½ne plots
    if strcmp(verbosity,'verbose')
        figure;
        % plot current focus position
        s_rad = 0.01*mirr_quadrat_equivalent;
        hold on
        surf(s_rad*x+focus(1),s_rad*y+focus(2),s_rad*z+focus(3),'EdgeColor', 'none', 'FaceColor', 'blue');
        hold off
        axis vis3d
        view(3)
        plot_all_the_rays(ray_paths, ind_of_valid_rays, ind_of_rays_that_are_absorbed, ind_of_rays_that_are_absorbed_second, handle_to_mirror_function, small_mirr_hand, focus,ellipt_parameters)
        disp(['Anzahl aller absorbierter Strahlen: ' int2str(length(ind_of_rays_that_are_absorbed))])
        disp('================================')
    end
    strahlen_gesamt = strahlen_gesamt + length(ind_of_rays_that_are_absorbed);
end %fuer timestep-Schleife
% end %fuer phi-Schleife
% end %fuer theta-Schleife
%%%%%
%ENDE der for-Schleife
%%%%%

%%% Es folgen weitere schöene plots
%plot der Spiegeloberflaeche
if strcmp(verbosity,'verbose')
    figure;
    axis equal
    axis([1.5*mirr_borders 0 3*half_mirr_edge_length])
    [rays_x rays_y] = meshgrid(linspace(mirr_borders(1), mirr_borders(2), 10));
    mirror_surface = zeros(10);
    for x_ind = 1:10
        for y_ind = 1:10
            mirror_surface(x_ind,y_ind) = handle_to_mirror_function(rays_x(x_ind,y_ind),rays_y(x_ind,y_ind));
        end
    end
    hold on
    surf(rays_x,rays_y,mirror_surface,'FaceColor','red','EdgeColor','none','FaceAlpha',0.8);
    hold off
    % plot connecting line of all focus points
    hold on
    plot3(focus_line(1,:),focus_line(2,:),focus_line(3,:),'LineWidth', 4);
    hold off
    axis vis3d image
    view(3)
    lighting gouraud
    camlight
end

strahlen_gesamt = -strahlen_gesamt;
ell_area = elliptic_area(ellipt_parameters);
strahlendichte = strahlen_gesamt/ell_area %sagt noch nix aus

end