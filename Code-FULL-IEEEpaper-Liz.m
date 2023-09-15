% Código para la simulación de 10000 usuarios residenciales
% Generación de los parámetros iniciales con las 3 distribuciones aleatorias
% Comunicación usando la red Xbee
% Cálculo de la potencia reactiva por servicio
% Guarda los parámetros críticos para comunicación y visualización

clc
clear all
close ( figure( 1 ) )
close ( figure( 2 ) )
close ( figure( 3 ) )
close ( figure( 4 ) )
close ( figure( 5 ) )
close ( figure( 9 ) )
close ( figure( 10 ) )

f=60;                           %frecuencia en Hz

% Código para calcular N usuarios::
fprintf( '\n\tIngresa la cantidad de datos por generar: \n' )
    N = input( '>> ' );
% N = 500;

% PARÁMETRO Voltaje Pico::
fprintf( '\n\t¿Cuál será el porcentaje de variación del Vpico?: \n' )
    PorcentV = input( '>> ' );% 5% está bien
    PorcentV = 5;
% PARÁMETRO Perfil de la curva de corriente (Chi^2)
fprintf( '\n\t¿Grados de libertad del ajuste Chi cuadrada?: \n' )
    DOF = input( '>> ' );%6 Para ok
%         DOF = 6;
% Cálculo de la variación de voltaje por distribución normal::
VRMS = 127;                             %voltaje RMS óptimo
VpicoOp = VRMS * sqrt( 2 );             %voltaje pico óptimo

VariaV = VpicoOp * ( PorcentV / 100 );  % +- PorcentV% de variación respecto Vpico
SerieRand = randn( 1, N );
maximo = max( SerieRand );
minimo = min( SerieRand );
limites = abs( [ maximo, minimo ] );
FactorNormal = max ( limites );
VpicoRand = ( VariaV * (SerieRand / FactorNormal )) + VpicoOp;
% Gráfica de la distribución aleatoria de Voltaje pico
figure( 1 )
H = histogram( VpicoRand );
H.BinWidth = 0.05;
hold on
    xlabel( 'Voltaje Pico (V)' ),...
    ylabel('Número de usuarios'),...
    title('Distribución Normal de la variación del voltaje pico')
A=0;
for L = 1 : length(H.BinEdges) - 1;
    A=A+1;
    Vintermedio(1,A) = H.BinEdges(1,L) + ((H.BinEdges(1,L+1) - H.BinEdges(1,L)) / 2)
end

figure(1)
plot(Vintermedio,H.Values,'*r','linewidth',1.2)

% Código para calcular la distribución de la Corriente Pico
H2 = chi2rnd(DOF, 1, N);
maximo = max (H2);
minimo = min (H2);
m = 49 /( maximo - minimo );
DistCorr = m * H2 - ( m * minimo );
prom = num2str ( mean ( DistCorr ));

% Gráfica de la distribución aleatoria de la Corriente pico
figure( 2 )
CC = histogram( DistCorr );
CC.BinWidth = 1;
    xlabel('Corriente Pico (A)'),...
    ylabel('Número de usuarios'),...
    lgd = legend(prom);
    title(lgd,'Consumo promedio')
    legend(prom,{'Consumo promedio'}),...
    title('Distribución Chi^2 de la variación de la corriente pico')
    figure(10)
    plot(DistCorr)
    
% Código para calcular la distribución Weibull del tiempo de defasamiento 
u = rand ( N, 1 );%genera los num. aleatorios
x = wblinv ( u, 1, 1 );% los distribuye con Weibull
Tfase =( 1 / (4*f) ) * (x / max( x ));%los normaliza para un máximo de 4.1666X10^-3 segundos

% Gráfica de la distribución Weibull del tiempo de defasamiento
figure ( 3 )
histogram ( Tfase, 8 );
    xlabel('Distribución de intervalos de defasamiento (S)'),...
    ylabel('Número de usuarios'),...
    title('Distribución Weibull de la variación del tiempo de defasamiento')

% Cálculo del ángulo de fase a partir del tiempo de fase
Phy = 60 * Tfase * 360;% vector del ángulo de fase en grados 
prom = ones( 1 , N ) * mean ( Phy );
Media = num2str( prom ( 1, 1 ) );

figure ( 4 )
plot( Phy )
grid on
hold on
plot(prom, '-r', 'linewidth', 2)
    xlabel('Usuarios' ),...
    ylabel('Ángulo de fase en grados'),...
    title('Distribución Aleatoria Weibull del ángulo de fase por servicio')
%     legend('Individual');
    lgd = legend(Media);
    title(lgd,'Ángulo promedio')
    legend('Individual',Media);

figure ( 5 )
FP = 100 * cosd(Phy);
prom = ones( 1 , N ) * mean ( FP );
Media = num2str( prom ( 1, 1 ) );
plot( FP )
hold on
plot(prom, '-r', 'linewidth', 2)
grid on
    xlabel('Usuarios' ),...
    ylabel('Factor de potencia (%)'),...
    title('Distribución Aleatoria Weibull del factor de potencia por servicio')
    lgd = legend(Media);
    title(lgd,'FP promedio')
    legend('Individual',Media,'Location','southwest');
    
% Calculo de la corrección del FP
% Potencia activa

VrmsRand = VpicoRand / sqrt ( 2 );% cálculo del voltaje RMS con base en el VpicoRAND
IrmsRand = DistCorr / sqrt( 2 );% cálculo de la corriente RMS con base el IpicoRAND
Potencia = VrmsRand .* IrmsRand; 
P_activa = Potencia .* (cosd(Phy))';%watts
Q_react = Potencia .* (sind(Phy))';%VAR

CapRad = Q_react / (2*pi*f*sqrt(VrmsRand))%<-No puede ser porque Phy está en degree
CapDeg = Q_react ./ (360*f*sqrt(VrmsRand));

CapMaxi=max(CapDeg);
CapMini=min(CapDeg);

RangoXcap=(CapMaxi-CapMini)/8;

for i=1:length(CapDeg)
    if 0 <= CapDeg(1,i) && CapDeg(1,i) <= RangoXcap
        CapON(1,i)=0;
    elseif RangoXcap <= CapDeg(1,i) && CapDeg(1,i) <= 2*RangoXcap
        CapON(1,i)=1;
    elseif 2*RangoXcap <= CapDeg(1,i) && CapDeg(1,i) <= 3*RangoXcap
        CapON(1,i)=2;
    elseif 3*RangoXcap <= CapDeg(1,i) && CapDeg(1,i) <= 4*RangoXcap
        CapON(1,i)=3;
    elseif 4*RangoXcap <= CapDeg(1,i) && CapDeg(1,i) <= 5*RangoXcap
        CapON(1,i)=4;
    elseif 5*RangoXcap <= CapDeg(1,i) && CapDeg(1,i) <= 6*RangoXcap
        CapON(1,i)=5;
    elseif 6*RangoXcap <= CapDeg(1,i) && CapDeg(1,i) <= 7*RangoXcap
        CapON(1,i)=6;
    else 
        CapON(1,i)=7;
    end
end
CapON;

CapON=round(7*rand(1,N));
 CapONsin=zeros(1,N);

figure(9)
plot(CapON, '-r', 'linewidth', 2)
    xlabel('Usuarios' ),...
    ylabel('Capacitores activos'),...
    title('Distribución Aleatoria de capacitores activados por servicio')

figure(10)
subplot(3,1,1)
plot(VrmsRand)
subplot(3,1,2)
plot(IrmsRand)
subplot(3,1,3)
plot(Q_react)
%###############################################################

Corriente ( 1, : ) = '0000';%<--Inicializa a 4 caracteres cada dato de corriente
for i = 1 : N
    VectVolt ( 1, i ) = round ( ( ( VpicoRand( 1, i ) * 1022 ) / 200 ) );
    Voltaje ( i, : ) = sprintf ( '%04d', VectVolt ( 1, i ) );%<--Vector de voltaje tipo string
    
    VectCorr ( 1, i ) = round ( ( ( DistCorr ( 1, i ) * 1022 ) / 50 ) );
    Corriente ( i, : ) = sprintf ( '%04d', VectCorr ( 1, i ) );%<--Vector de corriente tipo string
    
    Tiempo ( i, : ) = sprintf ( '%01.4f', Tfase ( i, 1 ) );
    
    Capacitores ( i, : ) = sprintf ( '%d', CapONsin ( 1, i ) );
end

%###############################################################
%matriz de datos SIN CORRECCIÓN

Datos ( :, 1:4 ) = Voltaje;
Datos ( :, 5 ) = ' ';
Datos ( :, 6:9 ) = Corriente;
Datos ( :, 10 ) = ' ';
Datos ( :, 11:16 ) = Tiempo;
Datos ( :, 17 ) = ' ';
Datos ( :, 18 ) = Capacitores;

Datos;

    Falla=0;
    tEnd =0;

formatOut = 'yyyymmmdd_HH-MM-SS';
Nombre = strcat ( datestr ( now, formatOut ), 'SIN.mat' );
% Nombre='Pruebas_1000';
%                       fig1        fig2     fig3  fig4  fig5   fig6    
save(Nombre,'Datos','VpicoRand','DistCorr','Tfase','Phy','FP','CapONsin',...
                    'VrmsRand','IrmsRand','Q_react','tEnd','Falla','prom')
%                    ----------   fig7   ----------

% ###############################################################
% matriz de datos ****CON CORRECCIÓN****


CorrCorreg=Potencia./VrmsRand;
X=rand ( N, 1 );
TfaseCON =( 1 / (64*f) ) * (x / max( x ));
Phy2 = 60 * TfaseCON * 360;% vector del ángulo de fase CORREGIDO en grados 

CorrCON ( 1, : ) = '0000';%<--Inicializa a 4 caracteres cada dato de corriente
for i = 1 : N
%     VectVolt ( 1, i ) = round ( ( ( VpicoRand( 1, i ) * 1022 ) / 200 ) );
%     Voltaje ( i, : ) = sprintf ( '%04d', VectVolt ( 1, i ) );%<--Vector de voltaje tipo string
    
    VectCorr ( 1, i ) = round ( ( ( CorrCorreg ( 1, i ) * 1022 ) / 50 ) );
    CorrCON ( i, : ) = sprintf ( '%04d', VectCorr ( 1, i ) );%<--Vector de corriente tipo string
    
    Tiempo ( i, : ) = sprintf ( '%01.4f', TfaseCON ( i, 1 ) );
    
    Capacitores ( i, : ) = sprintf ( '%d', CapON ( 1, i ) );
end

Datos2 ( :, 1:4 ) = Voltaje;
Datos2 ( :, 5 ) = ' ';
Datos2 ( :, 6:9 ) = CorrCON;
Datos2 ( :, 10 ) = ' ';
Datos2 ( :, 11:16 ) = Tiempo;
Datos2 ( :, 17 ) = ' ';
Datos2 ( :, 18 ) = Capacitores;

Datos2;


formatOut = 'yyyymmmdd_HH-MM-SS';
Nombre = strcat ( datestr ( now, formatOut ), 'CON.mat' );
%             fig1       fig2     fig3        fig4      fig5   fig6    
save(Nombre,'Datos2','VpicoRand','CorrCON','TfaseCON','CapON','Phy2',...
                    'VrmsRand','CorrCorreg','tEnd','Falla')
%                    ----------   fig7   ----------

% ###############################################################
% comunicación

Puerto = serialport('COM4',...
                    9600,...
                    'timeout', 60,...
                    'databits', 8,...
                    'stopbits', 1,...
                    'parity', 'none');
    configureTerminator(Puerto,"LF");

    i=1
    tStart=tic; 
while 1
    data = readline(Puerto);
    
    if isempty (data)
        fprintf('Última petición SIN\n');
        Falla=1
        break
    end
    writeline(Puerto,Datos(i,:))
    i=i+1
    
    if i > N
        break
    end
end
tEnd = toc(tStart) 
%                       fig1        fig2     fig3  fig4  fig5   fig6    
save(Nombre,'Datos','VpicoRand','DistCorr','Tfase','Phy','FP','CapON',...
                    'VrmsRand','IrmsRand','Q_react','tEnd','Falla','prom')
%                    ----------   fig7   ----------
fprintf('Terminado SIN corrección\n');
beep

% SEGUNDA CORRIDA+++++++++++++++++++++++++++++++++++++++
i=1
tStart=tic;    
while 1
    data = readline(Puerto);
    
    if isempty (data)
        fprintf('Última petición CON\n');
        Falla=1
        break
    end
    writeline(Puerto,Datos2(i,:))
    i=i+1
    
    if i > N
        break
    end
end
tEnd = toc(tStart) 
%                           fig1     fig2     fig3  fig4  fig5   fig6    
save('Prueba2','Datos2','VpicoRand','CorrCON','TfaseCON','CapON','Phy2',...
                    'VrmsRand','CorrCorreg','tEnd','Falla')
%                    ----------   fig7   ----------
fprintf('Terminado CON corrección\n');
beep









