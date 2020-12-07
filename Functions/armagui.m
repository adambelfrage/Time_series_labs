function armagui(action)
% ARMAGUI
%
% armagui  öppnar ett fönster för ARMA(p,q)-modellering.
%
% Använd knapparna för att lägga till reella och komplexa
% poler och nollställen.
% Flytta omkring dem genom att dra med musen, med nedtryckt vänsterknapp.
% Enskilda poler/nollställen tas bort med höger musknapp.
%
% Om knappen "Kräv stabilitet" är markerad går det inte att
% flytta poler och nollställen utanför enhetscirkeln.
%
% Knappen "Simulera" ger en realisering av processen.
%
% Man kan läsa in färdiga A- och C-polynom till fönstret
% genom att tillverka en variabel enligt
%
% >> modell.A=[1 -0.5];
% >> modell.C=[1 0.4 0.7];
%
% (vilket ger en ARMA(1,2)-process) och skriva in namnet (dvs "modell")
% i "Import"-rutan och trycka på knappen.
%
% Kovariansfunktionen, spektraltätheten och realiseringen kan exporteras
% till Matlab-fönstret med "Export"-knappen.
% Då bildas en variabel med namnet som ges av "Export"-rutan,
% och som innehåller poler, nollställen, genererande polynom, osv.
%
% SARIMA(p,1,q)-processer kan modelleras genom att man sätter "Säsong"
% till ett heltal >0. Koefficienten kan ställas mellan -1 och +1.
% Om "SARIMA-kvf" är markerad visas kvf och spektrum för SARIMA-modellen,
% om den är stabil. Om knappen inte är markerad visas kvf och spektrum
% för ARMA-delen.

% Copyright Finn Lindgren 1998-02-13
%                         1998-04-20 (SARIMA(p,1,q), bättre hantering
%                                     av instabilitet)
%                         1998-04-21 Doublebuffer, kräver Matlab5.2.
%                         1999-01-25 Doublebuffer använs om det finns,
%                                    men krävs inte Matlab5.2.
%                         1999-01-25 Errordialogruta om importvariabeln
%                                    inte finns.
%                         1999-04-14 Versionskontroll för ver 5.2
%                         1999-12-29 Versionskontroll debuggad för R11

if nargin<1
  action='init';
end

plotdelay=0.01;

switch action
  case 'init',
    initarma;
    f=gcf;
    set(f,'Renderer','painters')
    data.db=set_doublebuffer(f);
    
    data.h_PN=findobj(f,'Tag','PN-axis');

    data.h_kvflength=findobj(f,'Tag','covflength');
    data.kvflength=100;
    set(data.h_kvflength,'String',int2str(data.kvflength));

    data.h_kvf=findobj(f,'Tag','Kvf-axis');
    data.tau=0:data.kvflength;
    data.h_kvfdata=line(data.tau,data.tau*0,'Parent',data.h_kvf);
    line(0,0,'Parent',data.h_kvf);

    data.h_spec=findobj(f,'Tag','Spec-axis');
    data.fr=linspace(0,0.5,2^11);
    data.h_specdata=line(data.fr,data.fr*0,'Parent',data.h_spec);
    line(0,0,'Parent',data.h_spec);

    data.h_simulationlength=findobj(f,'Tag','simulationlength');
    data.simulationlength=500;
    set(data.h_simulationlength,'String',int2str(data.simulationlength));

    data.h_real=findobj(f,'Tag','Real-axis');
    data.realt=0:data.simulationlength-1;
    data.real=zeros(size(data.realt));
    data.h_realdata=line(data.realt,data.real,'Parent',data.h_real);

    data.stabilityflag=1;
    data.h_stabilityflag=findobj(f,'Tag','stabilityflag');
    set(data.h_stabilityflag,'Value',data.stabilityflag);

    data.zoom=1;
    data.zoomwidth=data.simulationlength-1;
    data.h_zoom=findobj(f,'Tag','zoom');
    set(data.h_zoom,'Value',data.zoom);

    data.location=data.zoomwidth/2;
    data.h_location=findobj(f,'Tag','location');
    set(data.h_location,'Min',data.zoomwidth/2*(1-0.001),...
	                'Max',data.zoomwidth/2*(1+0.001),...
			'Value',data.location);

    data.h_importname=findobj(f,'Tag','importname');
    set(data.h_importname,'String','modell');

    data.h_exportname=findobj(f,'Tag','exportname');
    set(data.h_exportname,'String','data');

    data.S=0;
    data.h_season=findobj(f,'Tag','season');
    set(data.h_season,'String',int2str(data.S));
    data.aS=1;
    data.h_seasoncoeff=findobj(f,'Tag','seasoncoeff');
    set(data.h_seasoncoeff,'String',num2str(data.aS));
    data.Sshow=0;
    data.h_Sshow=findobj(f,'Tag','Sshow');
    set(data.h_Sshow,'Value',data.Sshow);


    data.scale=1;
    data.h_scale=findobj(f,'Tag','scale');
    set(data.h_scale,'Value',data.scale);
    if data.scale==1
      set(data.h_spec,'YScale','linear')
    else
      set(data.h_spec,'YScale','log')
    end

    data.selected=[];
    data.prevselected=[];
    data.h_selected=[];
    data.h_prevselected=[];
    data.poles=[];
    data.cpoles=logical([]);
    data.spoles=[];
    data.h_poles=[];
    data.h_spoles=[];
    data.zeros=[];
    data.czeros=logical([]);
    data.h_zeros=[];
    set(f,'UserData',data);
    set(f,'HandleVisibility','callback');
    
    updatekvfspec(f);
    updatePNtitle(f);
    updaterealfull(f);
  case 'fig_buttondown',
  case 'zoom',
    f=gcbf;
    data=get(f,'UserData');
    data.zoom=get(data.h_zoom,'Value');
    if data.zoom==1
      data.zoomwidth=data.simulationlength-1;
      data.location=data.zoomwidth/2;
    else
      data.zoomwidth=ceil((data.simulationlength-1)/2^(data.zoom-1));
    end
    if data.location-data.zoomwidth/2<0
      data.location=data.zoomwidth/2;
    elseif data.location+data.zoomwidth/2>data.simulationlength-1
      data.location=data.simulationlength-1-data.zoomwidth/2;
    end
    set(data.h_location,'Min',data.zoomwidth/2-1e-9,...
	                'Max',data.simulationlength-1-data.zoomwidth/2+1e-9,...
			'Value',data.location);
    set(f,'UserData',data);
    setzoompos(f);
  case 'location',
    f=gcbf;
    data=get(f,'UserData');
    data.location=get(data.h_location,'Value');
    set(f,'UserData',data);
    setzoompos(f);
  case 'scale',
    f=gcbf;
    data=get(f,'UserData');
    data.scale=get(data.h_scale,'Value');
    set(f,'UserData',data);
    if data.scale==1
      set(data.h_spec,'YScale','linear')
    else
      set(data.h_spec,'YScale','log')
    end
  case 'import',
    f=gcbf;
    data=get(f,'UserData');
    data.importname=get(data.h_importname,'String');
    evalin('base','global spekguitemp;');
    global spekguitemp;
    set(f,'UserData',data);
    er=0;
    evalin('base',['spekguitemp=' data.importname ';'],'er=1;');
    if er % Variable not found
       errordlg('Variable not found','Error')
       return;
    end
    armagui clear
    if isfield(spekguitemp,'A')
      A=spekguitemp.A;
    else
      A=[1];
    end
    if isfield(spekguitemp,'C')
      C=spekguitemp.C;
    else
      C=[1];
    end
    poles=roots(A);
    cpoles=(imag(poles)>=2*eps);
    rpoles=(imag(poles)>-2*eps)&~cpoles;
    cpoles=poles(cpoles);
    rpoles=poles(rpoles);
    for k=1:length(rpoles)
      addrealpole(f,rpoles(k));
    end
    for k=1:length(cpoles)
      addcomplexpole(f,cpoles(k));
    end
    poles=roots(C);
    cpoles=(imag(poles)>=2*eps);
    rpoles=(imag(poles)>-2*eps)&~cpoles;
    cpoles=poles(cpoles);
    rpoles=poles(rpoles);
    for k=1:length(rpoles)
      addrealzero(f,rpoles(k));
    end
    for k=1:length(cpoles)
      addcomplexzero(f,cpoles(k));
    end

    data=get(f,'UserData');
    if isfield(spekguitemp,'S')
      data.S=max(0,floor(spekguitemp.S));
    else
      data.S=0;
    end
    set(data.h_season,'String',num2str(data.S))
    if isfield(spekguitemp,'aS')
      data.aS=max(-1,min(1,spekguitemp.aS));
    else
      data.aS=1;
    end
    set(data.h_seasoncoeff,'String',num2str(data.aS))
    set(f,'UserData',data);

    ensurestability(f);
    updatekvfspec(f);
    updatePNtitle(f);
    updatereal(f);
  case 'export',
    f=gcbf;
    data=get(f,'UserData');
    data.exportname=get(data.h_exportname,'String');
    set(f,'UserData',data);
    thedata.poles=fullroots(data.poles,data.cpoles);
    thedata.zeros=fullroots(data.zeros,data.czeros);
    thedata.A=z2poly(data.poles,data.cpoles);
    thedata.C=z2poly(data.zeros,data.czeros);
    thedata.S=data.S;
    thedata.aS=data.aS;
    thedata.tau=data.tau;
    thedata.r=get(data.h_kvfdata,'YData');
    thedata.f=data.fr;
    thedata.R=get(data.h_specdata,'YData');
    thedata.t=data.realt;
    thedata.x=data.real;
    assignin('base',data.exportname,thedata);
  case 'stabilityflag',
    f=gcbf;
    data=get(f,'UserData');
    data.stabilityflag=~data.stabilityflag;
    set(data.h_stabilityflag,'Value',data.stabilityflag);
    set(f,'UserData',data);
    ensurestability(f);
    updatekvfspec(f);
  case 'simulationlength',
    f=gcbf;
    data=get(f,'UserData');
    value=str2num(get(data.h_simulationlength,'String'));
    if isempty(value)
      set(data.h_simulationlength,'String',int2str(data.simulationlength));
    else
      data.simulationlength=max(1,round(value(1)));
      set(data.h_simulationlength,'String',int2str(data.simulationlength));

      data.zoom=1;
      set(data.h_zoom,'Value',data.zoom);
      data.zoomwidth=data.simulationlength-1;
      data.location=data.zoomwidth/2;
      set(data.h_location,'Min',data.zoomwidth/2+1e-9,...
	  'Max',data.simulationlength-1-data.zoomwidth/2+1e-9,...
	  'Value',data.location);
      set(f,'UserData',data);
      updaterealfull(f);
    end
  case 'covflength',
    f=gcbf;
    data=get(f,'UserData');
    value=str2num(get(data.h_kvflength,'String'));
    if isempty(value)
      set(data.h_kvflength,'String',int2str(data.kvflength));
    else
      data.kvflength=max(0,round(value(1)));
      set(data.h_kvflength,'String',int2str(data.kvflength));
      set(f,'UserData',data);
      updatekvffull(f);
    end
  case 'axis_buttondown',
    f=gcbf;
    clear_select(f);
  case 'addrealpole',
    f=gcbf;
    clear_select(f);
    addrealpole(f,0);
    updatekvfspec(f);
    updatePNtitle(f);
    updatereal(f);
  case 'addrealzero',
    f=gcbf;
    clear_select(f);
    addrealzero(f,0);
    updatekvfspec(f);
    updatePNtitle(f);
    updatereal(f);
  case 'addcomplexpole',
    f=gcbf;
    clear_select(f);
    addcomplexpole(f,0.5i);
    updatekvfspec(f);
    updatePNtitle(f);
    updatereal(f);
  case 'addcomplexzero',
    f=gcbf;
    clear_select(f);
    addcomplexzero(f,0.5i);
    updatekvfspec(f);
    updatePNtitle(f);
    updatereal(f);
  case 'selectsPN',
  case 'selectPN',
    f=gcbf;
    clear_select(f);
    h=gcbo;
    data.h_selected=h;
    data=get(f,'UserData');
    set(h,'Selected','on')
    if data.db
      set(h,'EraseMode','normal'); % Use this if 'doublebuffer' is 'on'!
    else
      set(h,'EraseMode','xor');
    end
    data.pos=get(data.h_PN,'CurrentPoint');
    data.pos=data.pos(1,1:2);
    hpos=[get(h,'XData') get(h,'YData')];
    if abs(get(h,'UserData'))==2
      if data.pos(2).*hpos(3)>=0
        hpos=hpos([1 3]);
      else
        hpos=hpos([2 4]);
      end
    end
    data.posdiff=hpos-data.pos;
    tic;
    if get(h,'UserData')<0
      k=-find(data.h_poles==h);
    else
      k=find(data.h_zeros==h);
    end
    data.selected=k;
    data.h_selected=h;
    set(f,'UserData',data);
    if strcmp(get(f,'SelectionType'),'alt')
      clear_select(f);
      armagui deletePN
    else
      set(f,'WindowButtonMotionFcn','armagui winbuttonmotion');
      set(f,'WindowButtonUpFcn','armagui winbuttonup');
    end
  case 'winbuttonup',
    f=gcbf;
    clear_select(f);    
    set(f,'WindowButtonMotionFcn','');
    set(f,'WindowButtonUpFcn','');
    updatereal(f);
  case 'winbuttonmotion',
    f=gcbf;
    data=get(f,'UserData');
    if isempty(data.selected)
      armagui winbuttonup
    else
      data.pos=get(data.h_PN,'CurrentPoint');
      data.pos=data.pos(1,1:2);
      pos=data.pos+data.posdiff;
      q=get(data.h_selected,'UserData');
      if abs(q)==1
        pos(2)=0;
      end
      if data.stabilityflag
        d=sqrt(sum(pos.^2));
        if d>1
          pos=pos/d*(1-1e-7);
        end
      else
        d=max(abs(pos));
        if d>1.2
          pos=pos/d*1.2;
        end
      end
      if abs(q)==1
        if q<0
          data.poles(-data.selected)=pos(1);
        else
          data.zeros(data.selected)=pos(1);
        end
        set(data.h_selected,'XData',pos(1),'YData',0)
      else
        if q<0
          data.poles(-data.selected)=pos(1)+i*pos(2);
        else
          data.zeros(data.selected)=pos(1)+i*pos(2);
        end
        set(data.h_selected,'XData',pos([1 1]),'YData',[pos(2) -pos(2)])
      end
      set(f,'UserData',data);
      if toc>plotdelay
        updatekvfspec(f);
        tic;
      end
    end
  case 'deletePN',
    f=gcbf;
    clear_select(f);
    data=get(f,'UserData');
    if ~isempty(data.prevselected)
      if data.prevselected<0
        data.poles(-data.prevselected)=[];
        data.cpoles(-data.prevselected)=[];
        data.h_poles(-data.prevselected)=[];
      else
        data.zeros(data.prevselected)=[];
        data.czeros(data.prevselected)=[];
        data.h_zeros(data.prevselected)=[];
      end
      delete(data.h_prevselected);
      data.prevselected=[];
      data.h_prevselected=[];
      set(f,'UserData',data);
      updatekvfspec(f);
      updatePNtitle(f);
      updatereal(f);
    end
  case 'clear',
    f=gcbf;
    data=get(f,'UserData');
    data.selected=[];
    data.prevselected=[];
    data.h_selected=[];
    data.h_prevselected=[];
    data.poles=[];
    data.cpoles=logical([]);
    delete(data.h_poles);
    data.h_poles=[];
    data.aS=1;
    data.S=0;
    data.spoles=[];
    delete(data.h_spoles);
    data.h_spoles=[];
    set(data.h_seasoncoeff,'String','1');
    set(data.h_season,'String','0');
    data.zeros=[];
    data.czeros=logical([]);
    delete(data.h_zeros);
    data.h_zeros=[];
    set(f,'UserData',data);
    updatekvfspec(f);
    updatePNtitle(f);
    updatereal(f);
    updateseasonpoles(f);
  case 'simulate',
    f=gcbf;
    updatereal(f);
  case 'season',
    f=gcbf;
    data=get(f,'UserData');
    S=max(0,floor(str2num(get(data.h_season,'String'))));
    if isempty(S)
      S=data.S;
    end
    set(data.h_season,'String',int2str(S));
    if S~=data.S
      data.S=S;
      set(f,'UserData',data);
      updatereal(f);
      if data.Sshow
	updatekvfspec(f);
        updateseasonpoles(f);
      end
    else
      set(f,'UserData',data);
    end
  case 'seasoncoeff',
    f=gcbf;
    data=get(f,'UserData');
    aS=max(-1,min(1,str2num(get(data.h_seasoncoeff,'String'))));
    if isempty(aS)
      aS=data.aS;
    end
    set(data.h_seasoncoeff,'String',num2str(aS));
    if aS~=data.aS
      data.aS=aS;
      set(f,'UserData',data);
      updatereal(f);
      if data.Sshow
	updatekvfspec(f);
        updateseasonpoles(f);
      end
    else
      set(f,'UserData',data);
    end
  case 'Sshow'
    f=gcbf;
    data=get(f,'UserData');
%    if data.Sshow | ((~data.Sshow) & (data.S>0))
      data.Sshow=~data.Sshow;
      set(data.h_Sshow,'Value',data.Sshow);
      set(f,'UserData',data);
      updateseasonpoles(f);
      updatekvfspec(f);
%    else
%      set(data.h_Sshow,'Value',data.Sshow);
%    end
  case 'close',
    f=gcbf;
    close(f)
  otherwise,
    disp(['Unknown action: ' action])
end



function clear_select(f);
data=get(f,'UserData');
if ~isempty(data.selected)
  set(data.h_selected,'EraseMode','normal');
  set(data.h_selected,'Selected','off')
  data.prevselected=data.selected;
  data.h_prevselected=data.h_selected;
  data.selected=[];
  data.h_selected=[];
  set(f,'UserData',data);
end

function updatePNtitle(f);
data=get(f,'UserData');
txt='Poler och nollställen';
if (isempty(data.poles) & isempty(data.zeros))
  txt=[txt ' för vitt brus'];
else
  if isempty(data.poles)
    p=0;
  else
    p=length(data.poles)+sum(data.cpoles);
  end
  if isempty(data.zeros)
    q=0;
  else
    q=length(data.zeros)+sum(data.czeros);
  end
  if q==0
    txt=[txt ' för en AR(' int2str(p) ')-process'];
  else
    if p==0
      txt=[txt ' för en MA(' int2str(q) ')-process'];
    else
      txt=[txt ' för en ARMA(' int2str(p) ',' int2str(q) ')-process'];
    end
  end
end
set(get(data.h_PN,'title'),'string',txt);



function setzoompos(f);
data=get(f,'UserData');
set(data.h_real,'XLim',data.location+[-1 1]*data.zoomwidth/2);


function updatereal(f);
data=get(f,'UserData');
A=z2poly(data.poles,data.cpoles);
if data.S>0
  AS=[1,zeros(1,data.S-1),-data.aS];
  A=conv(A,AS);
end
C=z2poly(data.zeros,data.czeros);
e=randn(1,data.simulationlength);
data.real=filter(C,A,e);
set(data.h_realdata,'YData',data.real);
set(f,'UserData',data);


function updaterealfull(f);
data=get(f,'UserData');
set(data.h_location,'Min',data.zoomwidth/2-1e-9)
set(data.h_location,'Max',data.simulationlength-1-data.zoomwidth/2+1e-9)
data.realt=0:data.simulationlength-1;
data.real=data.realt*0;
set(data.h_realdata,'XData',data.realt,'YData',data.real);
set(f,'UserData',data);
updatereal(f);
setzoompos(f);



function updatekvfspec(f);
data=get(f,'UserData');

A=z2poly(data.poles,data.cpoles);
if (data.S>0) & data.Sshow
  AS=[1,zeros(1,data.S-1),-data.aS];
  A=conv(A,AS);
end
poles=roots(A);

if any(abs(poles)>=1-eps) | (data.Sshow & (data.S>0) & (abs(data.aS)>=1-eps))
  set(data.h_specdata,'XData',[],'YData',[])
  set(data.h_kvfdata,'XData',[],'YData',[]);
else
  fr=data.fr;
  if isempty(poles) & isempty(data.zeros)
    R=ones(size(fr));
  else
    R=ones(size(fr));
    e=exp(-i*2*pi*fr);
    for k=1:length(poles)
      Rk=e-poles(k);
      R=R./(Rk.*conj(Rk));
    end
    for k=1:length(data.zeros)
      Rk=e-data.zeros(k);
      R=R.*(Rk.*conj(Rk));
      if data.czeros(k)
        Rk=e-conj(data.zeros(k));
        R=R.*(Rk.*conj(Rk));
      end
    end
    R=real(R);
  end
  set(data.h_specdata,'XData',fr,'YData',R);

  tau=data.tau;
  if isempty(data.poles) & isempty(data.zeros)
    if isempty(poles)
      r=kovarians(1,1,length(tau)-1);
    else
      r=kovarians(1,A,length(tau)-1);
    end
  else
    C=z2poly(data.zeros,data.czeros);
    r=kovarians(C,A,length(tau)-1);
  end
  set(data.h_kvfdata,'XData',tau,'YData',r);
end


function updatekvffull(f);
data=get(f,'UserData');
data.tau=0:data.kvflength;
set(data.h_kvfdata,'XData',data.tau,'YData',data.tau*0);
set(f,'UserData',data);
updatekvfspec(f);



function Z=fullroots(z,cz);
if isempty(z)
  Z=[];
else
  Z=[z(~cz);z(cz);conj(z(cz))];
end

function P=z2poly(z,cz);
if isempty(z)
  P=1;
else
  P=poly(fullroots(z,cz));
end



function updateseasonpoles(f);
data=get(f,'UserData');
if (data.S>0)
  data.spoles = data.aS^(1/data.S)*...
      exp(2*(0:(data.S-1))/data.S*i*pi);
else
  data.spoles = [];
end
if data.Sshow & (data.S>0)
  if isempty(data.h_spoles)
    data.h_spoles = line(real(data.spoles),imag(data.spoles),...
	'Parent',data.h_PN,...
	'MarkerSize',10,...
	'Marker','o',...
	'Color',[1 0 0],...
	'LineStyle','none',...
	'ButtonDownFcn','armagui selectsPN',...
	'UserData',-2);
  else
    set(data.h_spoles,...
	'XData',real(data.spoles),...
	'YData',imag(data.spoles));
  end
else
  if ~isempty(data.h_spoles)
    delete(data.h_spoles);
    data.h_spoles=[];
  end
end
set(f,'UserData',data);

    


function addrealpole(f,Z)
    data=get(f,'UserData');
    h=line(real(Z),0,...
           'Parent',data.h_PN,...
           'MarkerSize',40,...
           'Marker','.',...
           'Color',[1 0 0],...
           'LineStyle','none',...
           'ButtonDownFcn','armagui selectPN',...
           'UserData',-1);
    data.poles=[data.poles;real(Z)];
    data.cpoles=[data.cpoles;logical(0)];
    data.h_poles=[data.h_poles;h];
    set(f,'UserData',data);


function addrealzero(f,Z)
    data=get(f,'UserData');
    h=line(real(Z),0.0,...
           'Parent',data.h_PN,...
           'MarkerSize',40,...
           'Marker','.',...
           'Color',[0 0 1],...
           'LineStyle','none',...
           'ButtonDownFcn','armagui selectPN',...
           'UserData',1);
    data.zeros=[data.zeros;real(Z)];
    data.czeros=[data.czeros;logical(0)];
    data.h_zeros=[data.h_zeros;h];
    set(f,'UserData',data);


function addcomplexpole(f,Z)
    data=get(f,'UserData');
    h=line([real(Z) real(Z)],[imag(Z) -imag(Z)],...
           'Parent',data.h_PN,...
           'MarkerSize',40,...
           'Marker','.',...
           'Color',[1 0 0],...
           'LineStyle','none',...
           'ButtonDownFcn','armagui selectPN',...
           'UserData',-2);
    data.poles=[data.poles;Z];
    data.cpoles=[data.cpoles;logical(1)];
    data.h_poles=[data.h_poles;h];
    set(f,'UserData',data);


function addcomplexzero(f,Z)
    data=get(f,'UserData');
    h=line([real(Z) real(Z)],[imag(Z) -imag(Z)],...
           'Parent',data.h_PN,...
           'MarkerSize',40,...
           'Marker','.',...
           'Color',[0 0 1],...
           'LineStyle','none',...
           'ButtonDownFcn','armagui selectPN',...
           'UserData',2);
    data.zeros=[data.zeros;Z];
    data.czeros=[data.czeros;logical(1)];
    data.h_zeros=[data.h_zeros;h];
    set(f,'UserData',data);




function ensurestability(f)

data=get(f,'UserData');
chtot=0;

for k=1:length(data.zeros)
  ch=0;
  pos=data.zeros(k);
  q=data.czeros(k);
  if ~q
    if imag(pos)~=0
      ch=1;
      pos=real(pos);
    end
  end
  if data.stabilityflag
    d=abs(pos);
    if d>1
      ch=1;
      pos=pos/d*(1-1e-7);
    end
  else
    d=max(abs([real(pos) imag(pos)]));
    if d>1.2
      ch=1;
      pos=pos/d*1.2;
    end
  end
  data.zeros(k)=pos;
  if ch
    if ~q
      set(data.h_zeros(k),'XData',real(pos),'YData',0)
    else
      set(data.h_zeros(k),'XData',[real(pos) real(pos)],...
                          'YData',[imag(pos) -imag(pos)])
    end
  end
  chtot=chtot|ch;
end

for k=1:length(data.poles)
  ch=0;
  pos=data.poles(k);
  q=data.cpoles(k);
  if ~q
    if imag(pos)~=0
      ch=1;
      pos=real(pos);
    end
  end
  if data.stabilityflag
    d=abs(pos);
    if d>1
      ch=1;
      pos=pos/d*(1-1e-7);
    end
  else
    d=max(abs([real(pos) imag(pos)]));
    if d>1.2
      ch=1;
      pos=pos/d*1.2;
    end
  end
  data.poles(k)=pos;
  if ch
    if ~q
      set(data.h_poles(k),'XData',real(pos),'YData',0)
    else
      set(data.h_poles(k),'XData',[real(pos) real(pos)],...
	                  'YData',[imag(pos) -imag(pos)]);
    end
  end
  chtot=chtot|ch;
end

set(f,'UserData',data);
if chtot
  updatereal(f);
end  




function ok=set_doublebuffer(f)

v=version;
i=[0,sort([findstr(v,'.'),findstr(v,' ')]),length(v)+1];
for k=1:length(i)-1
  vv{k}=v(i(k)+1:i(k+1)-1);
end
if (num2str(vv{1})>5) | ((num2str(v{1})==5) & (num2str(v{2})>=2))
  set(f,'doublebuffer','on') % Undocumented feature in Matlab5.2!
			     % Documented in Matlab5.3!
  ok=1;
else
  ok=0;
end
