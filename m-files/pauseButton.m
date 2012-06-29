function keyComm = pauseButton(bHandle,bSize,posx,posy)
%  function pauseButton(handle,size,xPosition,yPosition)
%  default arguments:    121,  192, 50,       50
%
%  call frequently (say.., more than every 300ms?)
%
%  (c) Murphy O'Brien. 2004-2006
%   all rights unreserved
%
% Displays a button which, if clicked, causes MATLAB to pause and ask for an expression to be
% entered. This expression is evaluated in the calling functions workspace, the result is displayed
% and then MATLAB continues running its script/simulation. 
%
%pauseButton should be called often from inside a loop in a simulation which the user may want to
%pause. After the first call, it takes almost zero processing time.
%
%Useful if e.g. you are running a long simulation and suddenly decide you want to know how many five
%card poker hands are in a pack.
%
%Click the pause button, enter nchoosek(52,5) at the command window prompt then press return. 
% Matlab displays 
% ans =
%     2598960
%and continues the simulation.
%
%example usage:
%
%for ii=1:50000
%   pauseButton;
%   for jj=1:1000
%     dummy=randn(100)*randn(100);
%   end
%end

if (nargin<1)
    bHandle=121;
end
if ishandle(bHandle)
    handles=findall(bHandle,'userData','pauseButton');
else
    handles=[];
end
if any(handles==bHandle)
        firstTime=0;
else
        firstTime=1;
end

% 
if firstTime
    if nargin<4
        posx=50;posy=50;
    end
    if (nargin<2) || (bSize<4)
        bSize=192;
    end
    figure(bHandle);
    clf;
    set(bHandle,'userData','pauseButton')
    set(bHandle,'position',[posx,posy,bSize,bSize]);
    set(bHandle,'NumberTitle','off')
    set(gcf,'Name','Pause Button')
    edgeSize=10;
    z=zeros(bSize);m=1+z;
    m(:,1:edgeSize)=0.6;m(1:edgeSize,:)=0.6;                  % shaded edges
    m(end-edgeSize+1:end,:)=0.4;m(:,end-edgeSize+1:end)=0.4;  % shaded edges
    m=cat(3,m,m,z);                                           % a yellow button
    image(m);
    text(bSize/2-54,bSize/2,['Click here';' to pause '],'FontSize',16)
    set(bHandle,'SelectionType','extend')                     % start with extend
    axis off
    set(bHandle,'HandleVisibility','off')
    drawnow;
end
drawnow    
try
    st=get(bHandle,'SelectionType');
catch
    return
end
if st(1)=='e'
  % return if the button hasn't been clicked  
  keyComm='';
  return                                                    
end
set(bHandle,'SelectionType','extend')
pause(0.1)
% otherwise wait for a command
keyComm=input('Type an expression to evaluate or press ENTER to continue.\n','s');      
% and execute it, and display the error if there is one
%evalin('caller',estring,'disp(lasterr)')                      