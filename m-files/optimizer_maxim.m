function finally = optimizer_maxim()
    % Ordnung der Spiegelfunktion
    modus.ordnung = 5;

    %  Modus einstellen
    modus.absorber_optimieren = true;
    modus.kleinen_spiegel_optimieren = true;
    modus.grossen_spiegel_optimieren = true;
    modus.spiegelpfad_radius_optimieren = true;
    modus.num_rays_per_row = 100;
    modus.number_zeitpunkte = 15;

    % Zufälligen Startvektor erstellen
    randomNum = 0;

    if modus.absorber_optimieren
        randomNum = randomNum + 6;
    end

    if modus.grossen_spiegel_optimieren
        randomNum = randomNum + (modus.ordnung+1)^2-1;
    end

    if modus.kleinen_spiegel_optimieren
        randomNum = randomNum + (modus.ordnung+1)^2-1;
    end

    A = [randi(1000,1,randomNum)/1000 , (randi(45,1,1)/10 + .5)];

    % Debugging-Ausgabe in Datei
    fid = fopen('optimization_start.txt','a+');
    fprintf(fid, '##########################\n');
    fprintf(fid, 'Parameter der Optimierung:\n');
    fprintf(fid, '--------------------------\n');
    fprintf(fid, 'modus.ordnung: %d\n', modus.ordnung);
    fprintf(fid, 'modus.absorber_optimieren: %d\n', modus.absorber_optimieren);
    fprintf(fid, 'modus.grossen_spiegel_optimieren: %d\n', modus.grossen_spiegel_optimieren);
    fprintf(fid, 'modus.kleinen_spiegel_optimieren: %d\n', modus.kleinen_spiegel_optimieren);
    fprintf(fid, 'modus.spiegelpfad_radius_optimieren: %d\n', modus.spiegelpfad_radius_optimieren);
    fprintf(fid, 'modus.num_rays_per_row: %d\n', modus.num_rays_per_row);
    fprintf(fid, 'modus.number_zeitpunkte: %d\n', modus.number_zeitpunkte);
    fprintf(fid, 'A = [ ');
    fprintf(fid,'%f ',A);

    % Optimierer-Parameter festlegen
    options = optimset('PlotFcns',@optimplotfval,'Display','iter','MaxFunEvals',1000);
    lower_bounds = -Inf(size(A)); 
    lower_bounds(6,end) = 1e-6;
    upper_bounds = Inf(size(A)); 
    upper_bounds(6) = 3;
    upper_bounds(end) = 5;
    
    tic;
    % Optimierer starten
    [A, FVAL] = fmincon(@(x)Objective_function(x,modus),A,[],[],[],[],lower_bounds,upper_bounds,@(x)elliptic_constraints(x,modus),options);
    tstop = toc;
    
    % Ergebnisse in die Datei schreiben
    fprintf(fid, 'optimiertes A = [ ');
    fprintf(fid,'%f ',A);
    fprintf(fid,']\n');
    fprintf(fid, 'Laufzeit: %d min %d sec',floor((tstop/60)),floor(mod(tstop,60)));
    fprintf(fid,'##########################\n\n');
    fclose(fid);
end