function spekplot(Pw)
%spekplot(Pw)
%Plottar kolumn 2 mot kolumn 1 i en spektraltethetsfil som ges av
%spa eller trf

SITver=ver('ident');
if(str2num(SITver.Version(1))<5)
  plot(Pw(2:129,1)/2/pi,Pw(2:129,2));
else
  if(isempty(Pw.ResponseData))
    plot(Pw.Frequency/2/pi,squeeze(Pw.SpectrumData(1,1,:)));
  else
    plot(Pw.Frequency/2/pi,abs(squeeze(Pw.ResponseData(1,1,:)))).^2;
  end
end;
