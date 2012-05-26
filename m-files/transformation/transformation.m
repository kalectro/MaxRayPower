function [drehmatrix,offset]=transformation(fokus)
    
    % neue z-Achse zeigt zum Ursprung
    z=-fokus/norm(fokus);
    
%     % neue x-Achse ist die Normale der ebene aus neuer und alter z-Achse
%     if abs(cross([0;0;1],z)) > 1e-3
%         x=cross([0;0;1],z)/norm(cross([0;0;1],z));
%     else
%         %Wenn Fokuspunkt direkt über [0;0;0] liegt, muss x festgelegt
%         %werden, weil cross(a,a)=0.
%         x = [1;0;0];
%     end
%     
%     % neue y-Achse ist die Normale der Ebene aus neuer x- und neuer z-Achse
%     y=cross(z,x);

    %Wenn man einen Spiegel an einer Schiene hat, ist die x*-Achse egtl
    %immer an der alten x-Achse ausgerichtet. Daher sollte die Berechnugen
    %von x* anders erfolgen als bisher.
    %zB
    %hilfskonstruktion über neues y
    if norm(cross(z,[1;0;0])) > 1e-3
        y = cross(z,[1;0;0])/norm(cross(z,[1;0;0]));
    else
        %das kann falsch sein, es ist nur damit cross keinen quatsch macht
        %und man einen definierten Wert hat
        y=[0;-1;0];
        disp('Rotationsmatrix für kleinen Spiegel ist schlecht konditioniert! Spiegelpfad zu nah überm Boden?')
    end
    x = cross(y,z);
    
    drehmatrix=[x y z];

    offset=fokus;
end