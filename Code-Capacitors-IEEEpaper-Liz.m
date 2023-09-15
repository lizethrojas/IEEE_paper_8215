% Código para la simulación de 10000 usuarios residenciales
% con ángulo de fase calculado, factor de potencia corregido y el cálculo
% del capacitor que puede corregir FP>0.9

clc
clear all
close(figure(1))
close(figure(2))
close(figure(3))

% Declaración y cálculo de parámetros iniciales
f = 60;
V = 127;
Imax = 50;
I = 0 : (Imax / 100) : Imax;
TmaxFase = (1/60) * (1/4);
DeltaT = 0 : TmaxFase / 100 : TmaxFase;

% Cálculo de la capacitancia propia de los usuarios
for i = 1 : length(I);
    for t = 1 : length(DeltaT);
        C(i,t) = ( I(1,i) * sind( 21600 * DeltaT(1,t) ) ) / ( 120 * 360 * V );
    end
end

PhyMin=acosd(0.9);
PhyMax=acosd(0);
PasoPhy=(PhyMax-PhyMin)/7;

figure(2)
mesh(I,DeltaT,C);
xlabel('Current (A)'),ylabel('Phase time (s)'),zlabel('Capacitance (F)')
hold on

figure(3)
mesh(I,DeltaT,C);
xlabel('Current (A)'),ylabel('Phase time (s)'),zlabel('Capacitance (F)')
hold on

% Cálculo del capacitor comercial
AngxCap=PhyMin:PasoPhy:PhyMax;
PasoDeltaT=AngxCap/21600;
k=1;%capacitor comercial

    % Cálculo del capacitor ideal
    % CO(:,:,1) = 0.5*zeros(length(DeltaT)); % red
    % CO(:,:,2) = 0.5*zeros(length(DeltaT)); % green
    % CO(:,:,3) = 0.5*zeros(length(DeltaT)); % blue
ValCaps=(1e-6)*[1.5, 2, 3.5, 5, 6.5, 7, 8.5];

% Gráfica del capacitor comercial
for n=1:(length(PasoDeltaT)-1)
    Cpaso=(50*sind(AngxCap(1,n)))/(120*360*V);
    Cmesh=Cpaso*ones(length(I),length(DeltaT));
    
    ComCap=ValCaps(1,k)*ones(length(I),length(DeltaT));
    figure(2)
    mesh(I,DeltaT,Cmesh);%hiperplano del capacitor ideal
    figure(3)
    mesh(I,DeltaT,ComCap);%hiperplano del capacitor comercial
    hold on
    k=k+1;
end

axis([0 50 0 4.2e-3 0 9.2e-6]);

% Gráfica del capacitor ideal
% i=0:0.5:50;
% Cap=(i.*sind(25.84))/(2*pi*60*127);
% plot(i,Cap)
% grid on
% plot(i,Cap,'-ok','linewidth',2)
% hold on
% Cap=(i.*sind(35.007))/(2*pi*60*127);
% plot(i,Cap,'-ok','linewidth',2)
% plot3(i,0,Cap,'-ok','linewidth',2)
% Error using plot3
% Vectors must be the same length.
%  
% plot3(i,zeros(1,length(i)),Cap,'-ok','linewidth',2)
% Cap=(i.*sind(25.84))/(2*pi*60*127);
% plot3(i,zeros(1,length(i)),Cap,'-ok','linewidth',2)
% Cap=(i.*sind(44.1708))/(2*pi*60*127);
% plot3(i,zeros(1,length(i)),Cap,'-ok','linewidth',2)
% plot3(zeros(1,length(i)),i,Cap,'-ok','linewidth',2)
% plot3(zeros(1,length(i)),Cap,i,'-ok','linewidth',2)

