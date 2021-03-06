read.table("http://kingaa.github.io/short-course/stochsim/bsflu_data.txt") -> bsflu

rproc <- Csnippet("
  double N = 763;
  double t1 = rbinom(S,1-exp(-Beta*I/N*dt));
  double t2 = rbinom(I,1-exp(-mu_I*dt));
  double t3 = rbinom(R1,1-exp(-mu_R1*dt));
  double t4 = rbinom(R2,1-exp(-mu_R2*dt));
  S  -= t1;
  I  += t1 - t2;
  R1 += t2 - t3;
  R2 += t3 - t4;
")

init <- Csnippet("
  S = 762;
  I = 1;
  R1 = 0;
  R2 = 0;
")

dmeas <- Csnippet("
  lik = dpois(B,rho*R1+1e-6,give_log);
")

rmeas <- Csnippet("
  B = rpois(rho*R1+1e-6);
")

pomp(subset(bsflu,select=-C),
		 times="day",t0=0,
		 rprocess=euler(rproc,delta.t=1/5),
		 rinit=init,rmeasure=rmeas,dmeasure=dmeas,
		 statenames=c("S","I","R1","R2"),
		 paramnames=c("Beta","mu_I","mu_R1","mu_R2","rho")) -> flu

simulate(flu,params=c(Beta=.1,mu_I=1/2,mu_R1=1/4,mu_R2=1/1.8,rho=0.9),
				 nsim=5000,states=TRUE) -> x
x[[2]]@states
matplot(time(flu),t(x["R1",1:50,]),type='l',lty=1,
				xlab="time",ylab=expression(R[1]),bty='l',col='blue')
lines(time(flu),obs(flu,"B"),lwd=2,col='black')
x@.Data[[1]]@states

