function A = optimizer_kai()
    % Ordnung der 'groben' Optimierung
    modus.ordnung = 2;

    %  Modus einstellen
    modus.absorber_optimieren = false;
    modus.kleinen_spiegel_optimieren = true;
    modus.grossen_spiegel_optimieren = true;
    modus.spiegelpfad_radius_optimieren = true;
    modus.num_rays_per_row = 100;
    modus.number_zeitpunkte = 15;
    
    % Anzahl 'grober' Optimierungen
    numGrob = 10;
    
    % Länge des Startvektors für die Optimierung berechnen
    randomNum = modus.absorber_optimieren*6 + ...
                modus.grossen_spiegel_optimieren* (modus.ordnung+1)^2-1 + ...
                modus.kleinen_spiegel_optimieren*(modus.ordnung+1)^2-1;
                
    % Startvektoren erstellen
    A = zeros(numGrob,randomNum+1);
    % Speicherort für Ergebnisse
    Ergebnisse = zeros(numGrob, randomNum);
    
    for i = 1:numGrob
        % Zufälligen Startvektor erstellen und auf Ellipseneigenschft
        % überprüfen
        C = 1;
        while(C>0)
            A(i,:) = [randi(1000,1,randomNum)/1000 , (randi(45,1,1)/10 + .5)];

            % checken, ob der Absirber eine Ellipse ist
            a=A(i,1);
            b=A(i,2);
            c=A(i,3);
            C = -(4*b*a - c^2) + 1e-6;
        end

        % Debugging-Ausgabe in Datei
        fid = fopen('optimization_start.txt','a+');
        fprintf(fid, '##########################\n');
        fprintf(fid, 'Parameter der Optimierung für %d. grobe Optimierung:\n',i);
        fprintf(fid, '--------------------------\n');
        fprintf(fid, 'modus.ordnung: %d\n', modus.ordnung);
        fprintf(fid, 'modus.absorber_optimieren: %d\n', modus.absorber_optimieren);
        fprintf(fid, 'modus.grossen_spiegel_optimieren: %d\n', modus.grossen_spiegel_optimieren);
        fprintf(fid, 'modus.kleinen_spiegel_optimieren: %d\n', modus.kleinen_spiegel_optimieren);
        fprintf(fid, 'modus.spiegelpfad_radius_optimieren: %d\n', modus.spiegelpfad_radius_optimieren);
        fprintf(fid, 'modus.num_rays_per_row: %d\n', modus.num_rays_per_row);
        fprintf(fid, 'modus.number_zeitpunkte: %d\n', modus.number_zeitpunkte);
        fprintf(fid, 'A = [ ');
        fprintf(fid,'%f ',A(i,:));

        % Optimierer-Parameter festlegen
        options = optimset('PlotFcns',@optimplotfval,'Display','iter','MaxFunEvals',1000);
        lower_bounds = -Inf(size(A(1,:))); 
        lower_bounds(6,end) = 1e-6;
        upper_bounds = Inf(size(A(1,:))); 
        upper_bounds(6) = 3;
        upper_bounds(end) = 5;
    
        tic;
        % Optimierer starten
        [Ergebnisse(i,:), FVAL] = fmincon(@(x)Objective_function(x,modus),A(i,:),[],[],[],[],lower_bounds,upper_bounds,@(x)elliptic_constraints(x,modus),options);
        tstop = toc;
    
        % Ergebnisse in die Datei schreiben
        fprintf(fid, 'optimiertes A = [ ');
        fprintf(fid,'%f ',Ergenisse(i,:));
        fprintf(fid,']\n');
        fprintf(fid, 'Laufzeit: %d min %d sec',floor((tstop/60)),floor(mod(tstop,60)));
        fprintf(fid,'##########################\n\n');
        fclose(fid);
    end
end

