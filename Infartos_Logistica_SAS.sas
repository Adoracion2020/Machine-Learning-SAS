data Infartos;set 'C:\Users\dory_\Desktop\Machine learning\Practica2\Infartos.sas7bdat';
run;
proc freq data=Infartos;run;
proc contents data=Infartos out=Pract2ml.sal;run;quit;
data;set Pract2ml.sal;put name @@;run;
options mprint=0;

/**************************************************************************************
/* MODELOS SIN INTERACCIONES 

PARA APUNTAR LOS MODELOS, DESGRACIADAMENTE HAY QUE PONER CABECERA 
ODS OUTPUT type3=parametros y el data mode POSTERIOR*/
/**************************************************************************************/

ods output type3=Pract2ml.parametros;
proc logistic data=Infartos namelen=20 descending ;
class DiabetesNo DiabetesSI EducInstituto EducOtros HipertensoNo HipertensoSI Hombre Mujer TomarMedicamNO TomarMedicamSI;
model TenYearCHD=Edad CigsPorDia Colesterol DiabetesNo DiabetesSI EducInstituto EducOtros Glucosa HipertensoNo HipertensoSI Hombre IMC Mujer PresionArterial PresionSanguinea RitmoCardiaco TomarMedicamNO TomarMedicamSI
/selection=stepwise;
run;quit;
data mode;length effect $20. modelo $ 20000;retain modelo " ";set parametros end=fin;effect=cat(' ',effect);
if _n_ ne 1 then modelo=catt(modelo,' ',effect);if fin then output;
run;
data ;set mode;put modelo;run;

/*MEJORES VARIABLES: EDAD, CIGSPORDIA, DIABETESNO, HIPERTENSONO, HOMBRE, PRESIONSANGUINEA*/

/* CON LA OPCIÓN selection=score SE UTILIZA ods output bestsubsets=modelos y se escogen los mejores modelos de k=1,2,...efectos .
El problema es que esta opción no permite meter variables de clase con más de 2 categorías
*/

ods output bestsubsets=Pract2ml.modelos;
proc logistic data=Infartos descending;
model TenYearCHD=Edad CigsPorDia Colesterol DiabetesNo DiabetesSI EducInstituto EducOtros Glucosa HipertensoNo HipertensoSI Hombre IMC Mujer PresionArterial PresionSanguinea RitmoCardiaco TomarMedicamNO TomarMedicamSI
/selection=score best=1 start=3 stop=7;
run;
data ;set Pract2ml.modelos;put variablesinmodel;run;

/*
1.Edad CigsPorDia PresionSanguinea
2.Edad CigsPorDia Hombre PresionSanguinea
3. Edad CigsPorDia DiabetesNO Hombre PresionSanguinea
*/

/*OTRA OPCION ES UTILIZAR LA MACRO RANDOMSELECTLOG */

%randomselectlog(data=Pract2ml.infartos,directorio=C:\Users\dory_\Desktop,
listclass=DiabetesNo DiabetesSI EducInstituto EducOtros HipertensoNo HipertensoSI Hombre Mujer TomarMedicamNO TomarMedicamSI,
vardepen=TenYearCHD,
modelo=Edad CigsPorDia Colesterol DiabetesNo DiabetesSI EducInstituto EducOtros Glucosa HipertensoNo HipertensoSI Hombre IMC Mujer PresionArterial PresionSanguinea RitmoCardiaco TomarMedicamNO TomarMedicamSI  ,
sinicio=12345,sfinal=12380,fracciontrain=0.8);

/*VARIABLES SELECCIONADAS: 
Obs    efecto                                                                                  COUNT    PERCENT

 1     CigsPorDia DiabetesNO Hombre PresionSanguinea                                             17     47.2222
 2     CigsPorDia DiabetesNO HipertensoNO Hombre PresionSanguinea                                 8     22.2222
 3     CigsPorDia DiabetesNO Hombre PresionSanguinea TomarMedicamNO                               6     16.6667
 4     CigsPorDia Colesterol DiabetesNO HipertensoNO Hombre PresionSanguinea                      2      5.5556
 5     CigsPorDia Colesterol DiabetesNO HipertensoNO Hombre PresionSanguinea TomarMedicamNO       1      2.7778
 6     CigsPorDia Colesterol HipertensoNO Hombre PresionSanguinea                                 1      2.7778
 7     CigsPorDia DiabetesNO HipertensoNO Hombre PresionSanguinea TomarMedicamNO                  1      2.7778
*/

/* PROBAMOS LOS mejores MODELOS CON LOGÍSTICA */

/*PROC LOGISTIC SIN INTERACCIONES. MEJORES VARIABLES: EDAD, CIGSPORDIA, DIABETESNO, HIPERTENSONO, HOMBRE, PRESIONSANGUINEA*/
%cruzadalogistica
(archivo=infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea ,
categor=DiabetesNo HipertensoNo Hombre ,
ngrupos=4,sinicio=12345,sfinal=12365);
data final1;set final;modelo=1;

/*PROC LOGISTIC SEGUNDO MODELO. VARIABLES: Edad CigsPorDia PresionSanguinea*/
%cruzadalogistica
(archivo=infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea ,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365);
data final2;set final;modelo=2;

/*PROC LOGISTIC SEGUNDO MODELO. VARIABLES: Edad CigsPorDia Hombre PresionSanguinea*/
%cruzadalogistica
(archivo=infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
ngrupos=4,sinicio=12345,sfinal=12365);
data final3;set final;modelo=3;


/*PROC LOGISTIC SEGUNDO MODELO. VARIABLES: Edad CigsPorDia DiabetesNO Hombre PresionSanguinea*/
%cruzadalogistica
(archivo=infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=DiabetesNO Hombre,
ngrupos=4,sinicio=12345,sfinal=12365);
data final4;set final;modelo=4;

/*RANDOM SELECT. VARIABLES: CigsPorDia DiabetesNO Hombre PresionSanguinea*/
%cruzadalogistica
(archivo=infartos,vardepen=TenYearCHD,
conti=CigsPorDia PresionSanguinea,
categor=DiabetesNO Hombre,
ngrupos=4,sinicio=12345,sfinal=12365);
data final5;set final;modelo=5;

/*RANDOM SELECT. VARIABLES: CigsPorDia DiabetesNO HipertensoNO Hombre PresionSanguinea */
%cruzadalogistica
(archivo=infartos,vardepen=TenYearCHD,
conti=CigsPorDia PresionSanguinea,
categor=DiabetesNO HipertensoNO Hombre,
ngrupos=4,sinicio=12345,sfinal=12365);
data final6;set final;modelo=6;

/*RANDOM SELECT. VARIABLES: CigsPorDia DiabetesNO Hombre PresionSanguinea TomarMedicamNO */
%cruzadalogistica
(archivo=infartos,vardepen=TenYearCHD,
conti=CigsPorDia PresionSanguinea,
categor=DiabetesNO TomarMedicamNO,
ngrupos=4,sinicio=12345,sfinal=12365);
data final7;set final;modelo=7;

/*NODO SELECCIÓN DE VARIABLES EN E-MINER: DiabetesSI Edad HipertensoSI Hombre PresionSanguinea TomarMedicamNO  */
%cruzadalogistica
(archivo=infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=DiabetesSI HipertensoSI TomarMedicamNO,
ngrupos=4,sinicio=12345,sfinal=12365);
data final8;set final;modelo=8;

/*NODO ARBOL DE DESICION EN E-MINER*/
%cruzadalogistica
(archivo=infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea Colesterol IMC PresionArterial RitmoCardiaco Glucosa Colesterol,
categor=DiabetesNO HipertensoNO Hombre,
ngrupos=4,sinicio=12345,sfinal=12365);
data final9;set final;modelo=9;

data Pract2ml.union;set final1 final2 final3 final4 final5 final6 final7 final8 final9;
proc boxplot data=Pract2ml.union;plot media*modelo;run;

/*%neuralbinariabasica(archivo=Pract2ml.infartos,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,vardep=TenYearCHD,nodos=,corte=50,semilla=12345,porcen=0.80);*/

/* ESTUDIO DEL NUMERO DE NODOS Y EL PUNTO DE CORTE LEVMAR*/

%macro variar(seminicio=,semifin=,inicionodos=,finalnodos=,increnodos=);
title '';
data union;run;
%do semilla=&seminicio %to &semifin;
%do nodos=&inicionodos %to &finalnodos %by &increnodos;
   %neuralbinariabasica(archivo=Pract2ml.infartos,
   listconti=Edad CigsPorDia PresionSanguinea ,
   listclass=,vardep=TenYearCHD,nodos=&nodos,corte=50,semilla=&semilla,porcen=0.80,algo=levmar);
   data estadisticos;set estadisticos;nodos=&nodos;semilla=&semilla;run;
   data union;set union estadisticos;run;
%end;
%end;
proc sort data=union;by nodos;run;
proc boxplot data=union;plot (porcenVN porcenFN porcenVP porcenFP 
sensi especif tasafallos tasaciertos precision F_M)*nodos;run;
%mend;

%variar(seminicio=12345,semifin=12355,inicionodos=2,finalnodos=28,increnodos=2);

/* ESTUDIO DEL NUMERO DE NODOS Y EL PUNTO DE CORTE CONGRA*/

%macro variar(seminicio=,semifin=,inicionodos=,finalnodos=,increnodos=);
title '';
data union;run;
%do semilla=&seminicio %to &semifin;
%do nodos=&inicionodos %to &finalnodos %by &increnodos;
   %neuralbinariabasica(archivo=Pract2ml.infartos,
   listconti=Edad CigsPorDia PresionSanguinea ,
   listclass=,vardep=TenYearCHD,nodos=&nodos,corte=50,semilla=&semilla,porcen=0.80,algo=congra);
   data estadisticos;set estadisticos;nodos=&nodos;semilla=&semilla;run;
   data union;set union estadisticos;run;
%end;
%end;
proc sort data=union;by nodos;run;
proc boxplot data=union;plot (porcenVN porcenFN porcenVP porcenFP 
sensi especif tasafallos tasaciertos precision F_M)*nodos;run;
%mend;

%variar(seminicio=12345,semifin=12355,inicionodos=2,finalnodos=28,increnodos=2);

/* ESTUDIO DEL NUMERO DE NODOS Y EL PUNTO DE CORTE QUANEW*/

%macro variar(seminicio=,semifin=,inicionodos=,finalnodos=,increnodos=);
title '';
data union;run;
%do semilla=&seminicio %to &semifin;
%do nodos=&inicionodos %to &finalnodos %by &increnodos;
   %neuralbinariabasica(archivo=Pract2ml.infartos,
   listconti=Edad CigsPorDia PresionSanguinea ,
   listclass=,vardep=TenYearCHD,nodos=&nodos,corte=50,semilla=&semilla,porcen=0.80,algo=bprop mom=0.2 learn=0.1);
   data estadisticos;set estadisticos;nodos=&nodos;semilla=&semilla;run;
   data union;set union estadisticos;run;
%end;
%end;
proc sort data=union;by nodos;run;
proc boxplot data=union;plot (porcenVN porcenFN porcenVP porcenFP 
sensi especif tasafallos tasaciertos precision F_M)*nodos;run;
%mend;

%variar(seminicio=12345,semifin=12355,inicionodos=2,finalnodos=28,increnodos=2);

/*ESTUDIO DEL EARLY STOPPING METODO LEVMAR*/

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=10,meto=LEVMAR,acti=Tanh);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=12,meto=LEVMAR,acti=Tanh);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=24,meto=LEVMAR,acti=Tanh);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=10,meto=LEVMAR,acti=SOF);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=12,meto=LEVMAR,acti=SOF);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=24,meto=LEVMAR,acti=SOF);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=10,meto=LEVMAR,acti=LOG);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=12,meto=LEVMAR,acti=LOG);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=24,meto=LEVMAR,acti=LOG);

/*ESTUDIO EARLY STOPPING METODO CONGRA*/

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=12,meto=congra,acti=Tanh);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=20,meto=congra,acti=Tanh);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=22,meto=congra,acti=Tanh);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=12,meto=congra,acti=SOF);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=20,meto=congra,acti=SOF);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=22,meto=congra,acti=SOF);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=12,meto=congra,acti=LOG);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=20,meto=congra,acti=LOG);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442730,ocultos=22,meto=congra,acti=LOG);

/*ESTUDIO EARLY STOPPING MÉTODO QUANEW*/

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442711,ocultos=12,meto=quanew,acti=Tanh);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442711,ocultos=28,meto=quanew,acti=Tanh);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442711,ocultos=12,meto=quanew,acti=sof);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442711,ocultos=28,meto=quanew,acti=sof);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442711,ocultos=12,meto=quanew,acti=log);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442711,ocultos=28,meto=quanew,acti=log);

/*ESTUDIO EARLY STOPPING CON METODO BPROP*/

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442711,ocultos=12,meto=bprop mom=0.2 learn=0.1,acti=TANH);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442711,ocultos=22,meto=bprop mom=0.2 learn=0.1,acti=TANH);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442711,ocultos=12,meto=bprop mom=0.2 learn=0.1,acti=sof);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442711,ocultos=22,meto=bprop mom=0.2 learn=0.1,acti=sof);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442711,ocultos=12,meto=bprop mom=0.2 learn=0.1,acti=LOG);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442711,ocultos=22,meto=bprop mom=0.2 learn=0.1,acti=LOG);

/*REDES NEURONALES CON MÉTODO LEVMAR*/

%neuralbinariabasica(archivo=Pract2ml.infartos,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,vardep=TenYearCHD,nodos=10,corte=50,semilla=12345,porcen=0.80,algo=levmar);

%neuralbinariabasica(archivo=Pract2ml.infartos,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,vardep=TenYearCHD,nodos=12,corte=50,semilla=12345,porcen=0.80,algo=levmar);

%neuralbinariabasica(archivo=Pract2ml.infartos,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,vardep=TenYearCHD,nodos=24,corte=50,semilla=12345,porcen=0.80,algo=levmar);

/*REDES NEURONALES CON MÉTODO CONGRA*/

%neuralbinariabasica(archivo=Pract2ml.infartos,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,vardep=TenYearCHD,nodos=12,corte=50,semilla=12345,porcen=0.80,algo=congra);

%neuralbinariabasica(archivo=Pract2ml.infartos,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,vardep=TenYearCHD,nodos=20,corte=50,semilla=12345,porcen=0.80,algo=congra);

%neuralbinariabasica(archivo=Pract2ml.infartos,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,vardep=TenYearCHD,nodos=22,corte=50,semilla=12345,porcen=0.80,algo=congra);

/*REDES NEURONALES CON MÉTODO QUANEW*/

%neuralbinariabasica(archivo=Pract2ml.infartos,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,vardep=TenYearCHD,nodos=12,corte=50,semilla=12345,porcen=0.80,algo=quanew);

%neuralbinariabasica(archivo=Pract2ml.infartos,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,vardep=TenYearCHD,nodos=28,corte=50,semilla=12345,porcen=0.80,algo=quanew);

/*REDES NEURONALES CON MÉTODO BPROP*/

%neuralbinariabasica(archivo=Pract2ml.infartos,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,vardep=TenYearCHD,nodos=12,corte=50,semilla=12345,porcen=0.80,algo=bprop mom=0.2 learn=0.1);

%neuralbinariabasica(archivo=Pract2ml.infartos,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,vardep=TenYearCHD,nodos=22,corte=50,semilla=12345,porcen=0.80,algo=bprop mom=0.2 learn=0.1);

/*VALIDACION CRUZADA REPETIDA*/

%cruzadalogistica
(archivo=infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea ,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365);
data final2;set final;modelo=2;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=24,algo=levmar,acti=LOG);
data final3;set final;modelo=3;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=24,algo=levmar,acti=LOG,early=2);
data final4;set final;modelo=4;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=12,algo=congra,acti=tanh);
data final5;set final;modelo=5;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=20,algo=congra,acti=tanh);
data final6;set final;modelo=6;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=22,algo=congra,acti=tanh);
data final7;set final;modelo=7;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=20,algo=congra,acti=SOF);
data final8;set final;modelo=8;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=12,algo=congra,acti=LOG);
data final9;set final;modelo=9;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=20,algo=congra,acti=LOG);
data final10;set final;modelo=10;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=22,algo=congra);
data final11;set final;modelo=11;


data Pract2ml.union2;set final2 final3 final4 final5 final6 final7 final8 final9 final10 final11;
proc boxplot data=Pract2ml.union2;plot media*modelo;run;

/*%cruzadalogistica
(archivo=infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea ,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365);
data final2;set final;modelo=2;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=10,algo=levmar);
data final3;set final;modelo=3;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=12,algo=levmar);
data final4;set final;modelo=4;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=24,algo=levmar);
data final5;set final;modelo=5;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=24,algo=levmar,early=2);
data final6;set final;modelo=6;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=12,algo=congra);
data final7;set final;modelo=7;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=20,algo=congra);
data final8;set final;modelo=8;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=22,algo=congra);
data final9;set final;modelo=9;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=12,algo=quanew);
data final10;set final;modelo=10;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=28,algo=quanew);
data final11;set final;modelo=11;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=12,algo==bprop mom=0.8 learn=0.1);
data final12;set final;modelo=12;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=22,algo=bprop mom=0.8 learn=0.1);
data final13;set final;modelo=13;


data Pract2ml.union2;set final2 final3 final4 final5 final6 final7 final8 final9 final10 final11 final12 final13;
proc boxplot data=Pract2ml.union2;plot media*modelo;run;*/

/************************************SET DE VARIABLES DEL MODELO 3: EDAD, CIGSPORDIA, PRESIONSANGUINEA, HOMBRE***************************/

/*BUSQUEDA DEL NODO CON EL METODO BPROP*/
%macro variar(seminicio=,semifin=,inicionodos=,finalnodos=,increnodos=);
title '';
data union;run;
%do semilla=&seminicio %to &semifin;
%do nodos=&inicionodos %to &finalnodos %by &increnodos;
   %neuralbinariabasica(archivo=Pract2ml.infartos,
   listconti=Edad CigsPorDia PresionSanguinea ,
   listclass=Hombre,vardep=TenYearCHD,nodos=&nodos,corte=50,semilla=&semilla,porcen=0.80,algo=bprop mom=0.2 learn=0.1);
   data estadisticos;set estadisticos;nodos=&nodos;semilla=&semilla;run;
   data union;set union estadisticos;run;
%end;
%end;
proc sort data=union;by nodos;run;
proc boxplot data=union;plot (porcenVN porcenFN porcenVP porcenFP 
sensi especif tasafallos tasaciertos precision F_M)*nodos;run;
%mend;

%variar(seminicio=12345,semifin=12355,inicionodos=2,finalnodos=23,increnodos=2);

/*BUSQUEDA DEL NODO CON EL METODO LEVMAR*/
%macro variar(seminicio=,semifin=,inicionodos=,finalnodos=,increnodos=);
title '';
data union;run;
%do semilla=&seminicio %to &semifin;
%do nodos=&inicionodos %to &finalnodos %by &increnodos;
   %neuralbinariabasica(archivo=Pract2ml.infartos,
   listconti=Edad CigsPorDia PresionSanguinea ,
   listclass=Hombre,vardep=TenYearCHD,nodos=&nodos,corte=50,semilla=&semilla,porcen=0.80,algo=levmar);
   data estadisticos;set estadisticos;nodos=&nodos;semilla=&semilla;run;
   data union;set union estadisticos;run;
%end;
%end;
proc sort data=union;by nodos;run;
proc boxplot data=union;plot (porcenVN porcenFN porcenVP porcenFP 
sensi especif tasafallos tasaciertos precision F_M)*nodos;run;
%mend;

%variar(seminicio=12345,semifin=12355,inicionodos=2,finalnodos=23,increnodos=2);

/*BUSQUEDA DEL NODO CON EL METODO quanew*/
%macro variar(seminicio=,semifin=,inicionodos=,finalnodos=,increnodos=);
title '';
data union;run;
%do semilla=&seminicio %to &semifin;
%do nodos=&inicionodos %to &finalnodos %by &increnodos;
   %neuralbinariabasica(archivo=Pract2ml.infartos,
   listconti=Edad CigsPorDia PresionSanguinea ,
   listclass=Hombre,vardep=TenYearCHD,nodos=&nodos,corte=50,semilla=&semilla,porcen=0.80,algo=quanew);
   data estadisticos;set estadisticos;nodos=&nodos;semilla=&semilla;run;
   data union;set union estadisticos;run;
%end;
%end;
proc sort data=union;by nodos;run;
proc boxplot data=union;plot (porcenVN porcenFN porcenVP porcenFP 
sensi especif tasafallos tasaciertos precision F_M)*nodos;run;
%mend;

%variar(seminicio=12345,semifin=12355,inicionodos=2,finalnodos=23,increnodos=2);

/*BUSQUEDA DEL NODO CON EL METODO quanew*/
%macro variar(seminicio=,semifin=,inicionodos=,finalnodos=,increnodos=);
title '';
data union;run;
%do semilla=&seminicio %to &semifin;
%do nodos=&inicionodos %to &finalnodos %by &increnodos;
   %neuralbinariabasica(archivo=Pract2ml.infartos,
   listconti=Edad CigsPorDia PresionSanguinea ,
   listclass=Hombre,vardep=TenYearCHD,nodos=&nodos,corte=50,semilla=&semilla,porcen=0.80,algo=congra);
   data estadisticos;set estadisticos;nodos=&nodos;semilla=&semilla;run;
   data union;set union estadisticos;run;
%end;
%end;
proc sort data=union;by nodos;run;
proc boxplot data=union;plot (porcenVN porcenFN porcenVP porcenFP 
sensi especif tasafallos tasaciertos precision F_M)*nodos;run;
%mend;

%variar(seminicio=12345,semifin=12355,inicionodos=2,finalnodos=23,increnodos=2);

///**************EARLY STOPPING PARA EL MODELO 3*************/////

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=Hombre,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442711,ocultos=14,meto=levmar,acti=TANH);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=Hombre,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442711,ocultos=14,meto=levmar,acti=LOG);

%redneuronalbinaria(archivo=Pract2ml.infartos,listclass=Hombre,
listconti=Edad CigsPorDia PresionSanguinea,
vardep=TenYearCHD,porcen=0.80,semilla=442711,ocultos=14,meto=levmar,acti=SOF);

/************REDES NEURONALES MODELO 3*****************///

%neuralbinariabasica(archivo=Pract2ml.infartos,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=Hombre,vardep=TenYearCHD,nodos=14,corte=50,semilla=12345,porcen=0.80,algo=Levmar);

/**********VALIDACION CRUZADA REPETIDA*******************/

%cruzadalogistica
(archivo=infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
ngrupos=4,sinicio=12345,sfinal=12365);
data final3;set final;modelo=3;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=14,algo=Levmar,acti=Tanh);
data final4;set final;modelo=4;

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=14,algo=Levmar,acti=Tanh,early=2);
data final5;set final;modelo=5;

data Pract2ml.union3;set final3 final4 final5;
proc boxplot data=Pract2ml.union3;plot media*modelo;run;

/*************************************************************************
**************************************************************************
**************************BAGGING*****************************************
**************************************************************************
*************************************************************************/

/************************************BAGGING MODELO 2********************/

/***Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
1	0.80	5	100	2	10	0.1***/


%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=100,variables=3,porcenbag=0.80,maxbranch=2,tamhoja=5,maxdepth=10,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final1;set final;modelo=1;

/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
2	0.80	10	50	2	6	0.2*/


%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=50,variables=3,porcenbag=0.80,maxbranch=2,tamhoja=10,maxdepth=6,pvalor=0.2,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final2;set final;modelo=2;


/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
3	0.80	2	80	2	8	0.3
*/

%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=80,variables=3,porcenbag=0.80,maxbranch=2,tamhoja=2,maxdepth=8,pvalor=0.3,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final3;set final;modelo=3;

/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
4	0.80	4	100	2	10	0.6
*/

%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=100,variables=3,porcenbag=0.80,maxbranch=2,tamhoja=4,maxdepth=10,pvalor=0.6,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final4;set final;modelo=4;

/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
5	0.80	8	60	2	3	0.7
*/

%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=60,variables=3,porcenbag=0.80,maxbranch=2,tamhoja=8,maxdepth=3,pvalor=0.7,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final5;set final;modelo=5;

/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
6	0.70	5	50	2	10	0.1
*/

%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=50,variables=3,porcenbag=0.70,maxbranch=2,tamhoja=5,maxdepth=10,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final6;set final;modelo=6;

/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
7	0.70	10	100	2	12	0.1
*/

%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=100,variables=3,porcenbag=0.70,maxbranch=2,tamhoja=10,maxdepth=12,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final7;set final;modelo=7;

/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
8	0.70	2	80	2	6	0.8
*/
%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=80,variables=3,porcenbag=0.70,maxbranch=2,tamhoja=2,maxdepth=6,pvalor=0.8,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final8;set final;modelo=8;

/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
9	0.70	4	60	2	10	0.4
*/
%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=60,variables=3,porcenbag=0.70,maxbranch=2,tamhoja=4,maxdepth=10,pvalor=0.4,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final9;set final;modelo=9;

/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
10	0.70	8	100	2	2	0.1
*/
%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=100,variables=3,porcenbag=0.70,maxbranch=2,tamhoja=8,maxdepth=2,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final10;set final;modelo=10;



data bagging.union4;set final1 final2 final3 final4 final5 final6 final7 final8 final9 final10;
proc boxplot data=bagging.union4;plot media*modelo;run;


/************************************BAGGING MODELO 3********************/

/***Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
1	0.80	15	100	2	10	0.2***/


%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=100,variables=4,porcenbag=0.80,maxbranch=2,tamhoja=15,maxdepth=10,pvalor=0.2,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final1;set final;modelo=1;

/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
2	0.80	10	50	2	6	0.1*/


%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=50,variables=4,porcenbag=0.80,maxbranch=2,tamhoja=10,maxdepth=6,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final2;set final;modelo=2;


/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
3	0.80	6	80	2	8	0.3
*/

%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=80,variables=4,porcenbag=0.80,maxbranch=2,tamhoja=6,maxdepth=8,pvalor=0.3,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final3;set final;modelo=3;

/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
4	0.80	2	100	2	10	0.6
*/

%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=100,variables=4,porcenbag=0.80,maxbranch=2,tamhoja=2,maxdepth=10,pvalor=0.6,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final4;set final;modelo=4;

/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
5	0.70	4	100	2	2	0.1
*/
%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=100,variables=4,porcenbag=0.70,maxbranch=2,tamhoja=4,maxdepth=2,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final5;set final;modelo=5;
/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
6	0.70	4	50	2	10	0.1
*/

%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=50,variables=4,porcenbag=0.70,maxbranch=2,tamhoja=4,maxdepth=10,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final6;set final;modelo=6;

/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
7	0.70	10	100	2	12	0.1
*/

%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=100,variables=4,porcenbag=0.70,maxbranch=2,tamhoja=10,maxdepth=12,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final7;set final;modelo=7;

/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
8	0.70	6	80	2	6	0.8
*/
%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=80,variables=4,porcenbag=0.70,maxbranch=2,tamhoja=6,maxdepth=6,pvalor=0.8,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final8;set final;modelo=8;

/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
9	0.70	12	60	2	10	0.4
*/
%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=60,variables=4,porcenbag=0.70,maxbranch=2,tamhoja=12,maxdepth=10,pvalor=0.4,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final9;set final;modelo=9;

/*
Modelo	Porcenbag	Tamhoja	Maxtress	Maxbranch	Maxdepth	pvalor
10	0.80	8	60	2	3	0.7
*/

%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=60,variables=4,porcenbag=0.80,maxbranch=2,tamhoja=8,maxdepth=3,pvalor=0.7,
ngrupos=4,sinicio=13345,sfinal=13355,objetivo=tasafallos);
data final10;set final;modelo=10;


data Pract2ml.union5;set final1 final2 final3 final4 final5 final6 final7 final8 final9 final10;
proc boxplot data=Pract2ml.union5;plot media*modelo;run;

/**********************************************************************************************
***********************************RANDOM FOREST***********************************************
**********************************************************************************************/

/********************************SET DEL MODELO 2********************************************/
%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=100,variables=2,porcenbag=0.80,maxbranch=2,tamhoja=15,maxdepth=3,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final1;set final;modelo=1;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=100,variables=2,porcenbag=0.80,maxbranch=2,tamhoja=8,maxdepth=2,pvalor=0.05,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final2;set final;modelo=2;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=200,variables=2,porcenbag=0.80,maxbranch=2,tamhoja=20,maxdepth=2,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final3;set final;modelo=3;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=200,variables=1,porcenbag=0.80,maxbranch=2,tamhoja=30,maxdepth=4,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final4;set final;modelo=4;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=150,variables=2,porcenbag=0.80,maxbranch=2,tamhoja=10,maxdepth=6,pvalor=0.05,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final5;set final;modelo=5;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=120,variables=1,porcenbag=0.70,maxbranch=2,tamhoja=15,maxdepth=4,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final6;set final;modelo=6;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=200,variables=2,porcenbag=0.70,maxbranch=2,tamhoja=20,maxdepth=4,pvalor=0.05,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final7;set final;modelo=7;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=200,variables=2,porcenbag=0.70,maxbranch=2,tamhoja=25,maxdepth=5,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final8;set final;modelo=8;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=100,variables=1,porcenbag=0.70,maxbranch=2,tamhoja=4,maxdepth=3,pvalor=0.05,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final9;set final;modelo=9;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=120,variables=2,porcenbag=0.70,maxbranch=2,tamhoja=20,maxdepth=8,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final10;set final;modelo=10;

data Pract2ml.union6;set final1 final2 final3 final4 final5 final6 final7 final8 final9 final10;
proc boxplot data=Pract2ml.union6;plot media*modelo;run;

/********************************SET DEL MODELO 3********************************************/

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=100,variables=3,porcenbag=0.80,maxbranch=2,tamhoja=10,maxdepth=15,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final1;set final;modelo=1;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=100,variables=3,porcenbag=0.80,maxbranch=2,tamhoja=8,maxdepth=10,pvalor=0.05,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final2;set final;modelo=2;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=200,variables=2,porcenbag=0.80,maxbranch=2,tamhoja=15,maxdepth=5,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final3;set final;modelo=3;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=200,variables=3,porcenbag=0.80,maxbranch=2,tamhoja=20,maxdepth=20,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final4;set final;modelo=4;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=150,variables=3,porcenbag=0.80,maxbranch=2,tamhoja=30,maxdepth=8,pvalor=0.05,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final5;set final;modelo=5;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=120,variables=2,porcenbag=0.70,maxbranch=2,tamhoja=15,maxdepth=6,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final6;set final;modelo=6;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=200,variables=2,porcenbag=0.70,maxbranch=2,tamhoja=4,maxdepth=20,pvalor=0.05,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final7;set final;modelo=7;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=200,variables=3,porcenbag=0.70,maxbranch=2,tamhoja=20,maxdepth=4,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final8;set final;modelo=8;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=100,variables=2,porcenbag=0.70,maxbranch=2,tamhoja=10,maxdepth=5,pvalor=0.05,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final9;set final;modelo=9;

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
maxtrees=120,variables=2,porcenbag=0.70,maxbranch=2,tamhoja=20,maxdepth=20,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13356,objetivo=tasafallos);
data final10;set final;modelo=10;

data Pract2ml.union7;set final1 final2 final3 final4 final5 final6 final7 final8 final9 final10;
proc boxplot data=Pract2ml.union7;plot media*modelo;run;

/*********************************************************************************************
**********************************GRADIENT BOOSTING*******************************************
*********************************************************************************************/

/*********************************************SET 2 DE VARIABLES*****************************/

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=5,
iteraciones=300,shrink=0.03,maxbranch=2,maxdepth=12,mincatsize=15,minobs=20,objetivo=tasafallos);
data final1;set final;modelo=1;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=5,
iteraciones=300,shrink=0.1,maxbranch=2,maxdepth=8,mincatsize=15,minobs=20,objetivo=tasafallos);
data final2;set final;modelo=2;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=5,
iteraciones=300,shrink=0.2,maxbranch=2,maxdepth=20,mincatsize=15,minobs=20,objetivo=tasafallos);
data final3;set final;modelo=3;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=10,
iteraciones=300,shrink=0.03,maxbranch=2,maxdepth=4,mincatsize=15,minobs=30,objetivo=tasafallos);
data final4;set final;modelo=4;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=10,
iteraciones=300,shrink=0.02,maxbranch=2,maxdepth=6,mincatsize=15,minobs=30,objetivo=tasafallos);
data final5;set final;modelo=5;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=10,
iteraciones=300,shrink=0.1,maxbranch=2,maxdepth=4,mincatsize=15,minobs=20,objetivo=tasafallos);
data final6;set final;modelo=6;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=10,
iteraciones=300,shrink=0.01,maxbranch=2,maxdepth=8,mincatsize=15,minobs=30,objetivo=tasafallos);
data final7;set final;modelo=7;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=10,
iteraciones=300,shrink=0.02,maxbranch=2,maxdepth=6,mincatsize=15,minobs=30,objetivo=tasafallos);
data final8;set final;modelo=8;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=10,
iteraciones=300,shrink=0.03,maxbranch=2,maxdepth=4,mincatsize=15,minobs=30,objetivo=tasafallos);
data final9;set final;modelo=9;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=10,
iteraciones=300,shrink=0.01,maxbranch=2,maxdepth=10,mincatsize=15,minobs=30,objetivo=tasafallos);
data final10;set final;modelo=10;


data Pract2ml.union8;set final1 final2 final3 final4 final5 final6 final7 final8 final9 final10;
proc boxplot data=Pract2ml.union8;plot media*modelo;run;

/*********************************************SET 3 DE VARIABLES*****************************/

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=Hombre,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=15,
iteraciones=300,shrink=0.05,maxbranch=2,maxdepth=12,mincatsize=15,minobs=20,objetivo=tasafallos);
data final1;set final;modelo=1;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=Hombre,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=15,
iteraciones=300,shrink=0.1,maxbranch=2,maxdepth=20,mincatsize=15,minobs=20,objetivo=tasafallos);
data final2;set final;modelo=2;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=Hombre,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=15,
iteraciones=300,shrink=0.2,maxbranch=2,maxdepth=10,mincatsize=15,minobs=20,objetivo=tasafallos);
data final3;set final;modelo=3;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=Hombre,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=5,
iteraciones=200,shrink=0.03,maxbranch=2,maxdepth=6,mincatsize=15,minobs=30,objetivo=tasafallos);
data final4;set final;modelo=4;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=Hombre,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=5,
iteraciones=200,shrink=0.1,maxbranch=2,maxdepth=4,mincatsize=15,minobs=30,objetivo=tasafallos);
data final5;set final;modelo=5;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=Hombre,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=5,
iteraciones=200,shrink=0.2,maxbranch=2,maxdepth=8,mincatsize=15,minobs=30,objetivo=tasafallos);
data final6;set final;modelo=6;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=Hombre,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=20,
iteraciones=300,shrink=0.01,maxbranch=2,maxdepth=6,mincatsize=15,minobs=20,objetivo=tasafallos);
data final7;set final;modelo=7;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=Hombre,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=20,
iteraciones=300,shrink=0.2,maxbranch=2,maxdepth=10,mincatsize=15,minobs=30,objetivo=tasafallos);
data final8;set final;modelo=8;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=Hombre,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=20,
iteraciones=300,shrink=0.25,maxbranch=2,maxdepth=15,mincatsize=15,minobs=30,objetivo=tasafallos);
data final9;set final;modelo=9;

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=Hombre,ngrupos=4,sinicio=12345,sfinal=12355,leafsize=20,
iteraciones=300,shrink=0.03,maxbranch=2,maxdepth=20,mincatsize=15,minobs=30,objetivo=tasafallos);
data final10;set final;modelo=10;

data Pract2ml.union9;set final1 final2 final3 final4 final5 final6 final7 final8 final9 final10;
proc boxplot data=Pract2ml.union9;plot media*modelo;run;

/******************************************************************************************************
*******************************************************************************************************
**********************************************SVM******************************************************
******************************************************************************************************
*******************************************************************************************************/

/*************************SET 2
***************************************
*********************************/

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=linear, c=10);
data final1;set final;modelo='SVM-Linear';

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=polynom k_par=2, c=10);
data final2;set final;modelo='SVM-poly1';


%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=polynom k_par=3, c=10);
data final3;set final;modelo='SVM-poly2';


%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=polynom k_par=2, c=20);
data final4;set final;modelo='SVM-poly3';

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=rbf k_par=10, c=15);
data final5;set final;modelo='SVM-RBF1';

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=rbf k_par=5, c=8);
data final6;set final;modelo='SVM-RBF2';

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=rbf k_par=15, c=10);
data final7;set final;modelo='SVM-RBF3';

data Pract2ml.union10;length modelo $ 40;set final1 final2 final3 final4 final5 final6 final7;
ods graphics off;
proc boxplot data=Pract2ml.union10;plot media*modelo;run;

/*%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=rbf k_par=10,c=10);

data final7;set final;modelo='SVM-RBF';

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=polynom k_par=2,c=10);

data final8;set final;modelo='SVM-poly';


%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=polynom k_par=3,c=10);

data final9;set final;modelo='SVM1';

options notes;

data Pract2ml.union12;length modelo $ 40;set final7 final8 final9;
ods graphics off;
proc boxplot data=Pract2ml.union12;plot media*modelo;run;*/

/*************************SET 3
***************************************
*********************************/

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=linear, c=0.1);
data final1;set final;modelo='SVM-Linear';

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=polynom k_par=2, c=0.1);
data final2;set final;modelo='SVM-poly1';


%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=polynom k_par=3, c=0.01);
data final3;set final;modelo='SVM-poly2';


%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=polynom k_par=2, c=0.001);
data final4;set final;modelo='SVM-poly3';

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=rbf k_par=10, c=0.1);
data final5;set final;modelo='SVM-RBF1';

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=rbf k_par=5, c=0.001);
data final6;set final;modelo='SVM-RBF2';

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=rbf k_par=15, c=0.01);
data final7;set final;modelo='SVM-RBF3';

data Pract2ml.union18;length modelo $ 40;set final1 final2 final3 final4 final5 final6 final7;
ods graphics off;
proc boxplot data=Pract2ml.union18;plot media*modelo;run;

/*otra prueba del set 3

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=Hombre,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=linear, c=10);
data final1;set final;modelo='SVM-Linear';

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=Hombre,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=polynom k_par=2, c=0.001);
data final2;set final;modelo='SVM-poly1';


%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=Hombre,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=polynom k_par=3, c=0.01);
data final3;set final;modelo='SVM-poly2';


%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=Hombre,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=polynom k_par=2, c=0.1);
data final4;set final;modelo='SVM-poly3';

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=Hombre,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=rbf k_par=10, c=0.001);
data final5;set final;modelo='SVM-RBF1';

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=Hombre,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=rbf k_par=5, c=0.01);
data final6;set final;modelo='SVM-RBF2';

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=Hombre,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=rbf k_par=15, c=0.1);
data final7;set final;modelo='SVM-RBF3';

options notes;

data Pract2ml.union17;length modelo $ 40;set final1 final2 final3 final4 final5 final6 final7;
ods graphics off;
proc boxplot data=Pract2ml.union17;plot media*modelo;run;*/

/*************************************************************************************
************************BOX PLOT MODELOS GANADORES SET 2******************************
**************************************************************************************/

/*PROC LOGISTIC SEGUNDO MODELO. VARIABLES: Edad CigsPorDia PresionSanguinea*/
%cruzadalogistica
(archivo=infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea ,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365);
data final1;set final;modelo='Log';

%cruzadabinarianeural(archivo=Pract2ml.infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
ngrupos=4,sinicio=12345,sfinal=12365,nodos=20,algo=congra,acti=LOG);
data final2;set final;modelo='Red';

%cruzadarandomforestbin(archivo=Pract2ml.infartos,vardep=TenYearCHD,conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=100,variables=3,porcenbag=0.70,maxbranch=2,tamhoja=8,maxdepth=2,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13365,objetivo=tasafallos);
data final3;set final;modelo='Bagging';

%cruzadarandomforestbin(
archivo=Pract2ml.Infartos,vardep=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=,
maxtrees=200,variables=2,porcenbag=0.80,maxbranch=2,tamhoja=20,maxdepth=2,pvalor=0.1,
ngrupos=4,sinicio=13345,sfinal=13365,objetivo=tasafallos);
data final4;set final;modelo='Rf';

%cruzadatreeboostbin(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,categor=,ngrupos=4,sinicio=12345,sfinal=12365,leafsize=10,
iteraciones=300,shrink=0.03,maxbranch=2,maxdepth=4,mincatsize=15,minobs=30,objetivo=tasafallos);
data final5;set final;modelo='Gb';

%cruzadaSVMbin
(archivo=Pract2ml.Infartos,vardepen=TenYearCHD,
listconti=Edad CigsPorDia PresionSanguinea,
listclass=,
ngrupos=4,sinicio=12345,sfinal=12365,kernel=linear, c=10);
data final6;set final;modelo='SVM-Linear';

data Pract2ml.unionset2;set final1 final2 final3 final4 final5 final6;
proc boxplot data=Pract2ml.unionset2;plot media*modelo;run;

/*************************************************************************************
************************BOX PLOT MODELOS GANADORES SET 3******************************
**************************************************************************************/

/*PROC LOGISTIC SEGUNDO MODELO. VARIABLES: Edad CigsPorDia Hombre PresionSanguinea*/
%cruzadalogistica
(archivo=infartos,vardepen=TenYearCHD,
conti=Edad CigsPorDia PresionSanguinea,
categor=Hombre,
ngrupos=4,sinicio=12345,sfinal=12365);
data final3;set final;modelo=3;
