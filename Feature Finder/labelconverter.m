function nlabels=labelconverter(olabels,srate)
stpoint=(find(olabels==1,1,'first')-1)./srate;
eppoint=(find(olabels==1,1,'last')-1)./srate;

time=0:1./srate:(length(olabels)-1)./srate;
average=mean([stpoint,eppoint]);
standarddev=0.8.*(eppoint-stpoint);

nlabels=normpdf(time,average,standarddev);

nlabels(stpoint*srate+1:eppoint*srate+1)=nlabels(stpoint*srate+1);
nlabels(eppoint*srate+1:end)=0;
nlabels=nlabels./max(nlabels);