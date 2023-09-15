import math
import datetime
import os
import firebase_admin
from firebase_admin import credentials
from google.cloud import firestore
from google.cloud import firestore_admin_v1
from firebase_admin import firestore


from sqlite3 import Date

def Grados(radiantes):
	grados = (radiantes * 180) / math.pi
	return grados

def Guardar(v,i,t,cap,vrms,irms,phi,fp,Srms,Qrms,Prms,estatus,numservicio):

	cred = credentials.Certificate('credenciales.json')
	firebase_admin.initialize_app(cred)

	db = firestore.client()

	fecha = firebase_admin.datetime.datetime.timestamp(datetime.datetime.today())
	print(fecha)

	dataconsumo = {'voltaje': v, 'corriente':i, 'tiempo':t, 'capacitores':cap, 'Vrms':vrms, 'Irms':irms, 'angulofase':phi,'FP':fp,'Srms':Srms, 'Qrms':Qrms,'Prms':Prms,'fechalectura': fecha, 'estatus':estatus, 'num_equipo':numservicio}
	#Especificamos en que documento y colleccion seran guardados los datos
	db.collection('consumos').document('1').set(dataconsumo, merge=True)
	print('Datos guardados')
