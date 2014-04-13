irr.z=function(cf.z,gips=FALSE) {
  irr.freq=365
  if(!is.zoo(cf.z)) {warning("cash flow must be zoo object"); return(NA)}
  if("Date"!=class(time(cf.z))) {warning("need Date class for zoo index"); return(NA)}
  if(any(is.na(cf.z))) return(NA)
  if(length(cf.z)<=1) return(NA)
  if(all(cf.z<=0)) return(NA)
  if(all(cf.z>=0)) return(NA)
  if(sum(cf.z)==0) return (0)
  if (sum(cf.z)<0) {
    rangehi=0
    rangelo=-.01
    i=0
    # low range on search for negative IRR is -100%
    while(i<100&(sign(npv.znoadjust(rangehi,cf.z))==sign(npv.znoadjust(rangelo,cf.z)))) {
      rangehi=rangelo
      rangelo=rangelo-.01
      i=i+1
    }} else {
      rangehi=.01
      rangelo=0
      i=0
      # while hi range on search for positive IRR is 100,000%
      while(i<100000&(sign(npv.znoadjust(rangehi,cf.z))==sign(npv.znoadjust(rangelo,cf.z)))) {
        rangelo=rangehi
        rangehi=rangehi+.01
        i=i+1
      }}
  npv1=npv.znoadjust(rangelo,cf.z)
  npv2=npv.znoadjust(rangehi,cf.z)
  if (sign(npv1)==sign(npv2)) return(NA)
  cf.n=as.numeric(cf.z)
  #calculate with uniroot if cash flow starts negative and ends positive otherwise do your own search
  if((cf.n[1]<0)&(cf.n[length(cf.n)]>0)) {
    ans=uniroot(npv.znoadjust,c(rangelo,rangehi),cf=cf.z)
    apr=ans$root } else {
      int1=rangelo
      int2=rangehi
      for (i in 1:40) {
        inta=mean(c(int1,int2))
        npva=npv.znoadjust(inta,cf.z)
        if(sign(npva)==sign(npv1)) {
          int1=inta
          npv1=npva
        } else {
          int2=inta
          npv2=npva
        }}
      apr=mean(int1,int2)  
    }
  # convert IRR to compounding at irr.freq interval
  ans=((1+(apr/irr.freq))^irr.freq)-1
  # convert IRR to GIPS compliant if requested
  if (gips) {
    if(cf.z[1]==0)  cf.z=cf.z[-1]
    dur=index(cf.z)[length(cf.z)]-index(cf.z)[1]
    if(dur<irr.freq) ans=(1+ans)^((as.numeric(dur))/irr.freq)-1
  }
  return (ans)
}
npv.znoadjust=function(i,cf.z) {
  freq=365
  if(!is.zoo(cf.z)) {warning("cash flow must be zoo object"); return(NA)}
  if("Date"!=class(time(cf.z))) {warning("need Date class for zoo index"); return(NA)}
  tdif=as.numeric(index(cf.z)-(index(cf.z)[1]))
  d=(1+(i/freq))^tdif
  sum(cf.z/d)
}
