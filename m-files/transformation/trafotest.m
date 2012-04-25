function trafotest
    fokus = [5;10;7];
    
    [drehmatrix,offset] = transformation(fokus);
    
    o=[0;0;0];
    ex=[1;0;0]*4;
    ey=[0;1;0]*4;
    ez=[0;0;1]*4;
    
    e1=drehmatrix*ex+offset;
    norm(e1)
    e2=drehmatrix*ey+offset;
    norm(e2)
    e3=drehmatrix*ez+offset;
    norm(e3)
    
    figure
    hold on
    axis([-1 2*offset(1) -1 2*offset(2) -1 2*offset(3)])
    arrow3(o',ex','',1,1);
    arrow3(o',ey','',1,1);
    arrow3(o',ez','',1,1);
    arrow3(offset',e1','r',1,1);
    arrow3(offset',e2','r',1,1);
    arrow3(offset',e3','r',1,1);
    arrow3(o',offset','g',1,1);
    hold off
    camlight
    lighting gouraud
    axis image vis3d
        
end