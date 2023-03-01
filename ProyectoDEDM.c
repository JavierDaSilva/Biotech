#include <xc.h> 
#include <math.h>
#pragma config LVP=OFF, WDTEN=OFF, FOSC=INTIO67,PBADEN=OFF
#define EV LATDbits.LATD5

static unsigned tempTMR3=0xd8f0, tempTMR0=0xc180;
//Variables para conteo TMR0
int contTMR0_1=0, contTMR0_2=0;

//Variables de transmision USART
char men_Pact[17]={'*','A','0','0','0','0','*'};
char men_PS[17]={'*','S','0','0','0','*'};
char men_PD[17]={'*','D','0','0','0','*'};
char men_Estado[17]={'*','E','0','*'};
char mensaje_R[17];
char *punt_Pact=&men_Pact[1];
char *punt_PS=&men_PS[1];
char *punt_PD=&men_PD[1];
char *punt_Estado=&men_Estado[1];
int mensaje=0;

//Variable de estado
char estado=0;

//Variables de las presiones
int Pmax=500;
int Pmin=50;
int Pact;
int Pant;
int Psist;
int Pdiast;

//Variables para control de funciones
int PS=0;
int contPD=0;
int unsigned aux1=0;
int primero=0;

//Variable for
int i=0;

void ini_TMR3(){ //Temporizador antirrebotes 5 ms
    T3CON=0;
    T3CONbits.RD16=1;
    T3CONbits.T3CKPS=3;
    IPR2bits.TMR3IP=1;
}

void ini_TMR0(){ //Temporizador muestreo de presion 1 ms 
    T0CON=0;
    T0CONbits.PSA=1;
    TMR0H=tempTMR0>>8;
    TMR0L=tempTMR0;
    INTCON2bits.TMR0IP=1;
    INTCONbits.TMR0IF=0;
    INTCONbits.TMR0IE=1;
    T0CONbits.TMR0ON=1;
}

void ini_PORTs(){ //LEDs, EV, MB, pulsador S1
    TRISD=0x00;
    LATD=0x20;
    TRISBbits.RB0=1;
    ANSELHbits.ANS12=0;
    INTCON2bits.INTEDG0=0;
    INTCONbits.INT0IF=0;
    INTCONbits.INT0IE=1;
}

void ini_USART(){ 
    BAUDCONbits.BRG16=1;
    TXSTAbits.BRGH=1;
    SPBRG=0x81;
    SPBRGH=0x06;
    
    TRISCbits.TRISC6=1;
    TRISCbits.TRISC7=1;
    
    TXSTAbits.SYNC=0;
    RCSTAbits.SPEN=1;
    
    TXSTAbits.TXEN=1;
    RCSTAbits.CREN=1;
    
    IPR1bits.RCIP=1;
    IPR1bits.TXIP=1;
    PIR1bits.RCIF=0;
    PIE1bits.RCIE=1;
}

void ini_CAD(){ 
    ADCON0=0;
    ADCON1=0;
    ADCON2=0;
    TRISAbits.TRISA1=1;
    ANSELbits.ANS1=1;
    ADCON0bits.CHS=1;
    ADCON0bits.ADON=1;
    ADCON1bits.VCFG0=0;
    ADCON1bits.VCFG1=1;
    ADCON2bits.ACQT=0b111;
    ADCON2bits.ADCS=0b110;
    ADCON2bits.ADFM=1;
    PIR1bits.ADIF=0;
    PIE1bits.ADIE=1;    
}

void ini_CVREF(){ //Pendiente preguntar como configurar VREF+
    CVRCON=0;
    CVRCONbits.CVRSS=0;
    CVRCONbits.CVRR=1;
    CVRCONbits.CVR=13; //1.787 VREF-
    CVRCONbits.CVROE=1;    
    CVRCONbits.CVREN=1;
    
}

void estado_5(){ //Pasar Psist y Pdist a mmHG y mandarlo a tablet
    if (primero==1){
        LATD=0x25;
        PS=0;
        primero=0;
        Psist=round((Psist*0.56)-14.09); //Psist a mmHg (a lo mejor los datos calculados estan mal) 
        Pdiast=round((Pdiast*0.56)-14.09); //Pdist a mmHg (pendiente ajustar)
        
        i=0;
        for(i=0;i<3;i++){ //Pasar a ASCII Psist y Pdist
            men_PS[4-i]=Psist%10+0x30;
            Psist=Psist/10;
            men_PD[4-i]=Pdiast%10+0x30;
            Pdiast=Pdiast/10;
        }
        TXREG=men_PS[0];
        punt_PS=&men_PS[1];
        PIE1bits.TXIE=1;
    }
}

void estado_4(){ //Desinfar del todo
    LATD=0x24;
    if (Pact<=Pmin){
        T0CONbits.TMR0ON=0;
        estado=5;          
    }           
}

void estado_3(){ //Desinflar a pocos y guardar datos sistolica y diastolica
    LATD=0x03;
    if (PS==0){ //Detectar sistolica
        if ((Pant<Pact)&&(Pact-Pant<400)){
            Psist=Pant;
            PS=1;
            contPD=0; //Incremento en TMR0             
        }
    }

    else { //Detectar diastolica
        if ((Pant<Pact)&&(Pact-Pant<400)){
            contPD=0;
            Pdiast=Pant;
        }
        else if (contPD==2000){
            estado=4;               
        }
    }        
}

void estado_2(){ //Esperar estabilidad de tension
    LATD=0x02; 
    if (Pant=Pact){
        estado=3;           
    }
}

void estado_1(){ //Hinchar manguito hasta Pmax
    LATD=0x41; 
    if (Pact>=Pmax){ 
        estado=2;
    }    
}

void estado_0(){ //Valvula abierta, y Motobomba apagada
    if (primero==0){
        LATD=0x20;
        TMR0H=tempTMR0>>8;
        TMR0L=tempTMR0;
        T0CONbits.TMR0ON=1;
        primero=1;
        PS=0;
    }
}

void estados(){
    switch (estado){
        case 0:
            estado_0();
            break;
        case 1:
            estado_1();
            break; 
        case 2:
            estado_2();
            break;
        case 3:
            estado_3();
            break;
        case 4:
            estado_4();
            break;
        case 5:
            estado_5();
            break;            
    }
}

void interrupt high_priority iHP(){
    if ((INTCONbits.INT0IF==1)&&(INTCONbits.INT0IE==1)){ //Pulsador iniciar toma de tension
        TMR3H=tempTMR3>>8;
        TMR3L=tempTMR3;
        PIR2bits.TMR3IF=0;
        PIE2bits.TMR3IE=1;
        T3CONbits.TMR3ON=1;
        INTCONbits.INT0IF=0;
        INTCONbits.INT0IE=0;
    }
    
    if ((PIR2bits.TMR3IF==1)&&(PIE2bits.TMR3IE==1)){ //Antirrebotes
        PIR2bits.TMR3IF=0;
        PIE2bits.TMR3IE=0;
        T3CONbits.TMR3ON=0;
        if (PORTBbits.RB0==0){
            if (estado==0) {
                estado=1;
            }
            else {
                estado=0;
                primero=0;
            }
        }
        INTCONbits.INT0IF=0;
        INTCONbits.INT0IE=1;
    }
    
    if ((PIR1bits.RCIF==1)&&(PIE1bits.RCIE==1)){ //Detectar señal entrante boton
        if(RCREG=='D'){
            if (estado==0) {
                estado=1;
            }
            else {
                estado=0;
                primero=0;
            }
        }
    }
    
    if ((INTCONbits.TMR0IF==1)&&(INTCONbits.TMR0IE==1)){ //Temp sensor y valvula
        TMR0H=tempTMR0>>8;
        TMR0L=tempTMR0;
        INTCONbits.TMR0IF=0;
        estado();
        
        contPD++;//Contador para ver cuando ya no hay pulsos
        
        contTMR0_1++; //Disinflar despacio
        if (estado==3){ 
            if (contTMR0_1<7) EV=1;
            else {
                EV=0;
                if (contTMR0_1>=500){
                    contTMR0_1=0;
                    EV=1;
                }
            }    
        }
        
        
        contTMR0_2++; //Medir Pact
        if (contTMR0_2==15){
            PIR1bits.ADIF=0;
            PIE1bits.ADIE=1;
            ADCON0bits.GO=1;
            contTMR0_2=0;
            Pant=Pact;
        }        
    }
    
    if((PIR1bits.ADIF==1)&&(PIE1bits.ADIE==1)){ //Sensor
        PIR1bits.ADIF=0;
        Pact=(256*ADRESH)+ADRESL;
        aux1=Pact;
        if (PIE1bits.TXIE==0){
            i=0;
            for (i=0;i<4;i++){
                men_Pact[5-i]=aux1%10+0x30;
                aux1=aux1/10;
            }
            TXREG=men_Pact[0];
            punt_Pact=&men_Pact[1];
            PIE1bits.TXIE=1;
        }
    }
    
    if (PIR1bits.TXIF && PIE1bits.TXIE){ //Por el momento envia la Pact
        if (estado==5){ //Enviar Psist y Pdist
            if (PS==0){
                TXREG=*punt_PS;
                if (*punt_PS=='*'){
                    PS=1;
                    TXREG=men_PD[0];
                    punt_PD=&men_PD[1];
                }
                else punt_PS++;
            }
            else {
                TXREG=*punt_PD;
                if (*punt_PD=='*'){
                    PIE1bits.TXIE=0;
                    estado=0;
                }
                else punt_PD++;
            }            
        }
        
        
        else{ //Enviar Pact
            if (mensaje==0){
                TXREG=*punt_Pact;
                if (*punt_Pact=='*') {
                    mensaje=1;
                    TXREG=men_Estado[0];
                    punt_Estado=&men_Estado[1];
                }
                else punt_Pact++;
            }
            else {
               TXREG=*punt_Estado;
               if (*punt_Estado=='*'){
                   mensaje=0;
                   PIE1bits.TXIE=0;
               }
               else punt_Estado++;
            }
        }
    }             
}

void main(){
    //Config vel. osciloscopio
    OSCCONbits.IRCF=7;
    OSCTUNEbits.PLLEN=1;
    OSCCONbits.SCS=0;
    
    //Habilitar interrupciones
    RCONbits.IPEN=0;
    INTCONbits.GIEH=1;
    INTCONbits.GIEL=1;    
    
    //Inicializar
    ini_CVREF();
    ini_CAD();
    ini_USART();
    ini_PORTs();
    ini_TMR0();
    ini_TMR3();
    
    while(1){
        Nop();
    } 
}