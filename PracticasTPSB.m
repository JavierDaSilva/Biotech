%P2.1 (PRACTICA 1)
%{
n1=linspace(0,25,26);
x1=zeros(1,26);
for m=0:10
    x1=x1+(m+1)*(fDelta(n1,2*m)-fDelta(n1,2*m+1));
end

n2=linspace(-5,9,15);
x2=n2.^2.*(fEsc(n2,-5)-fEsc(n2,6))+10*fDelta(n2,0)+20*0.5.^n2.*(fEsc(n2,4)-fEsc(n2,10));

n3=linspace(0,20,21);
x3=0.9.^n3.*cos(0.2*pi.*n3+pi/3);

n4=linspace(0,100,101);
w4=randi([-1,1],1,101);
x4=10*cos(0.0008*pi.*n4.^2)+w4;

p5=[1,2,3,2];
x5=[p5,p5,p5,p5,p5];
%}

%P2.2
%{
x=[1,-2,4,6,-5,8,10];
n=linspace(0,length(x)-1,length(x));

[x11,n11]=fSigadd(3*x,n+2,x,n-4);
x1=fSigadd(x11,n11,-2*x,n);

n4=linspace(-10,10,21);
[x41,n41]=fSigmult(2*exp(0.5.*n4),n4,x,n);
[x42,n42]=fSigmult(cos(0.1*pi.*n4),n4,x,n+2);
x4=fSigadd(x41,n41,x42,n42);
%}

%P2.9
%{
n=linspace(0,100,101);
a1=2;
a2=-0.5;
x1=rand(1,101); %Modificar (1,102) para T3
x2=randn(1,101)*100;

T1=(2.^(a1*x1+a2*x2))-((a1*2.^x1)+(a2*2.^x2));
T2=(3.*(a1*x1+a2*x2)+4)-(3.*(a1*x1)+3.*(a2*x2)+4);
%}

%P2.15
%{
n=linspace(0,20,21);
x=0.8.^n.*fEsc(n,0);
y=conv(x,x);
yan=0.8.^n.*(n+1);
stem(y(1:21)-yan);
%}

%P3.2 (PRACTICA 2.1)
%{
w=linspace(-pi,pi,101);

n1=linspace(0,19,20);
x1=2*0.8.^n1.*(fEsc(n1,0)-fEsc(n1,20));
X1=fDTFT(x1,n1,w);

n2=linspace(-20,20,41);
x2=n2.*0.9.^n2.*(fEsc(n2,0)-fEsc(50,0));
X2=fDTFT(x2,n2,w);

x3=[4,3,2,1,2,3,4];
N3=length(x3);
n3=linspace(0,N3-1,N3);
X3=fDTFT(x3,n3,w);

x4=[4,3,2,1,1,2,3,4];
N4=length(x4);
n4=linspace(0,N4-1,N4);
X4=fDTFT(x4,n4,w);

x5=[4,3,2,1,0,-1,-2,-3,-4];
N5=length(x5);
n5=linspace(0,N5-1,N5);
X5=fDTFT(x5,n5,w);

plot(w,abs(X5),w,angle(X5));
%}

%P3.3
%{
w=linspace(-pi,pi,101);
n=linspace(-50,50,101);

x1=3*0.9^3.*fEsc(n,0);
X1=fDTFT(x1,n,w);
plot(w,X1)

x2=2*0.8.^(n+2).*fEsc(n,2);
X2=fDTFT(x2,n,w);

x3=n.*0.5.^n.*fEsc(n,0);
X3=fDTFT(x3,n,w);

x4=(n+2).*(-0.7).^(n-1).*fEsc(n,2);
X4=fDTFT(x4,n,w);

x5=5*(-0.9).^n.*cos(0.1*pi.*n).*fEsc(n,0);
X5=fDTFT(x5,n,w);

plot(w,abs(X5),w,angle(X5));
%}

%P3.4
%{
N=25;
n=linspace(-N,N,2*N+1);
r=fEsc(n,-N)-fEsc(n,N+1);

w=linspace(-pi,pi,101);
R=fDTFT(r,n,w);

%3.5
t=(1-abs(n)/N).*r;
T=fDTFT(t,n,w);

%3.6
c=(0.5+0.5*cos(pi*n/N)).*r;
C=fDTFT(c,n,w);
%}

%P3.11 (PRACTICA 2.2)
%{
nx=linspace(0,20,21);
xa=(0.75+1.3*j)*exp(0.5*j*pi.*nx);
xb=(0.75-1.3*j)*exp(-0.5*j*pi*nx);
xc=-j*exp(0.3*j*pi*nx);
xd=j*exp(-0.3*j*pi*nx);

nh=linspace(-11,11,23);
h=0.5.^abs(nh).*cos(0.1*pi*nh);
H=fDTFT(h,nh,[0.5*pi,-0.5*pi,0.3*pi,-0.3*pi]); %basicamente los exponentes

y=xa*H(1)+xb*H(2)+xc*H(3)+xd*H(4);
%}

%P5.1
%{
x=[j,j,-j,-j];
X=fft(x);
%}

%P5.2
%{
X=[1,2,3,4,5];
x=ifft(X);
%}

%P DTFT DFT
%{
n=linspace(0,9,10);
x=2*cos(0.27*pi.*n).*(fEsc(n,0)-fEsc(n,10));

N=101;
w=linspace(0,2*pi,N);
XDTFT=fDTFT(x,n,w);
XDFT=fft(x,N);

k=linspace(0,N-1,N); %haces la secuencia de XDFT
kw=k*2*pi/N; %y la pasas a periodica multiplicar 2pi dividir N 
%Es por el rollo este raro de tener cuidado con que se queda uno por detras
%y cosa de esas
plot(w,abs(XDTFT),kw,abs(XDFT),'o');
%}

%Problema diferenciador (PRACTICA 2.3-4)
%{
x=[0,1,2,3,2,1,0,0,0,1,2,4,2,1,0,0,0,1,2,3];
Nx=length(x);
h=[1,-1];
Nh=length(h);
Ne=Nx+Nh-1;

n=linspace(0,Ne-1,Ne);
yteo=[x,0]-[0,x];

ylConv=conv(x,h);
%stem(n,yteo-ylConv);

ycConv=cconv(x,h,Ne);
%stem(n,yteo); hold on; stem(n,ycConv); hold off;

yDFT=ifft(fft(x,Ne).*fft(h,Ne));
%stem(n,yteo); hold on; stem(n,yDFT); hold off;

ybloq=fbConv(x,h,10);
%stem(n,yteo); hold on; stem(n,ybloq); hold off;
%}

%Problema con coseno
%{
N=40;
n=linspace(0,N-1,N);
x=cos(0.1*pi*n);
h=[1,-1];
Nh=length(h);
Ne=N+Nh-1;

x1=cos(0.1*pi*(n-1));
yteo=x-x1;

%yteo2=fSigadd(x,n,-x,n-1); %si haces esto te quedan dos puntos mal IMP

n2=linspace(-Nh+1,N-1,Ne); %para ajutar y que de bien, sino el primer valor da mal siempre
x2=cos(0.1*pi*n2);
ylConv=conv(x2,h); 
ylConv=ylConv(Nh:Ne); %Esto creo que seria asi pero comprobarlo, eliminas primeros valores malos, y ajustas para misma longitud
%stem(n,yteo-ylConv);

ycConv=cconv(x2,h,Ne); 
ycConv=ycConv(Nh:Ne);
%stem(n,yteo); hold on; stem(n,ycConv); hold off;

yDFT=ifft(fft(x2,Ne).*fft(h,Ne));
yDFT=yDFT(Nh:Ne);
%stem(n,yteo); hold on; stem(n,yDFT); hold off;

z=fft(x2,Ne).*fft(h,Ne);
nrep=n2+Nh-1; %Asegurarse que el primer valor cae en x=0
%stem(nrep,abs(z)) %para ver donde estan los picos

[amax,imax]=max(abs(z(1:N/2)));
frecuencia=nrep(imax)*2*pi/N+1; %Si quieres en funcion de pi, no lo pongas y ya
amplitud=amax*2/(N+1); %%%%dividir entre el numero de muestras que en este caso es N+1 que es Ne, sino N IMPORTANTE
resolucion=2*pi/(N+1);

%Para el bloques hacer lo de abajo, ya que la funcion solo vale para
%secuencias definados 
Nb=15;
na=linspace(1-Nh,Nb-1,Nb+Nh-1);
nb=na+Nb;
nc=nb+Nb;
xa=cos(0.1*pi*na);
xb=cos(0.1*pi*nb);
xc=cos(0.1*pi*nc);
ybloqA=ifft(fft(xa).*fft(h,Nb+Nh-1));
ybloqB=ifft(fft(xb).*fft(h,Nb+Nh-1));
ybloqC=ifft(fft(xc).*fft(h,Nb+Nh-1));
ybloq=[ybloqA(Nh:Nh+Nb-1),ybloqB(Nh:Nh+Nb-1),ybloqC(Nh:Nh-1+N-2*Nb)];
stem(n,yteo-ybloq);
%}

%P3.11
%{
Nx=40; %40 porque si, por poner un numero
n=linspace(0,Nx-1,Nx);
x=3*cos(0.5*pi.*n+pi/3)+2*sin(0.3*pi.*n);

M=13;
Nh=2*M+1;
nh=linspace(-M,M,Nh);
h=0.5.^abs(nh).*cos(0.1*pi.*nh);
%stem(nh,h); %fijarse en el stem para considerar si Nh es suficiente

yteo=1.92*cos(0.5*pi*n+pi/3)+2.5*sin(0.3*pi*n)

%Como no es una secuencia recordar hacer x2 IMPORTANTE
Ne=Nx+Nh-1;
n2=linspace(-Nh+1,N-1,Ne);
x2=3*cos(0.5*pi.*n2+pi/3)+2*sin(0.3*pi.*n2);

Y=fft(x2).*fft(h,Ne);
y=ifft(Y);
y=y(Nh:Ne); %recuerda lo de recortar, y tener en cuenta que al no ser causal el filtro, la salida esta desplaza M
%stem(n+M,yteo); hold on; stem(n,real(y)); hold off; %poner el 0 en y, y mover yteo M a la derecha

%para el coseno
[amax,imax]=max(abs(Y(1:Ne/2)));
nrep=n2+Nh-1;
frecuencia=nrep(imax)*2*pi/(Ne);
amplitud=amax*2/(Ne);
resolucion=2*pi/(Ne);

%para la del seno pillar el siguiente pico
[amax2,imax2]=max(abs(Y(imax+1:Ne/2)));
frecuencia2=nrep(imax2+imax)*2*pi/(Ne); %la imax2 la hace mal, hay que sumarle imax1
amplitud2=amax2*2/(Ne);
resolucion2=2*pi/(Ne);

%Comprobar con h causal
h0=0.5.^abs(nh).*cos(0.1*pi.*nh).*fEsc(nh,0);
Nh0=length(h0);

Ne0=Nh0+N-1;
ne0=linspace(-Nh0+1,N-1,Ne0);
x0=3*cos(0.5*pi.*ne0+pi/3)+2*sin(0.3*pi.*ne0);
y0=ifft(fft(x0).*fft(h0,Ne0));
y0=y0(Nh0:Ne0);
%stem(n,yteo); hold on; stem(n,real(y)); hold off;
%}

%5.11
%{
X=[0.25,0.125-0.3*j,0,0.125-0.06*j,0.5,0.125+0.06*j,0,0.125+0.3*j];
N=length(X);
n=linspace(0,N-1,N);
x=ifft(X);

%x[-n]
x1=circshift(flip(x),1);
X1an=X(mod(-n,8)+1); %mod devuelve el resto de -n/8, otra forma de hacerlo
X1=fft(x1);
stem(n,abs(X1-X1an));

%x[n+5]
x2=circshift(x,-5);
X2=fft(x2);
X2an=X.*exp(2*pi*j/N*n*5);
stem(n,abs(X2-X2an));

%x^2[n]
x3=x.*x;
X3=fft(x3);
X3an=cconv(X,X,8)/N;
stem(n,abs(X3-X3an));

%x[n]*x[-n]
x4=cconv(x,x1,8);
X4=fft(x4);
X4an=X.*X1an;
stem(n,abs(X4-X4an));

%x[n]*exp(1j*pi/4*n)
x5=x.*exp(j*pi*n/4);
X5=fft(x5);
X5an=circshift(X,1);
stem(n,abs(X5-X5an));
%}
