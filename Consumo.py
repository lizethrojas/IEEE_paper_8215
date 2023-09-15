
#Define los atributos del servicio el[ectrico obtenido> voltaje, corriente, capacitores, vrms, prms, irms
import firebase_admin
from firebase_admin import credentials
from google.cloud import firestore
from google.cloud import firestore_admin_v1
from firebase_admin import firestore
from google.cloud.firestore_v1.field_path import FieldPath
import math
import datetime

class Consumo():

	def __init__(self, voltaje, corriente, tiempo, capacitores, vrms, irms, phi, fp, s, q, p) -> None:
		self.V = voltaje
		self.I = corriente
		self.T = tiempo
		self.C = capacitores
		self.Vrms = vrms
		self.Irms = irms
		self.AF = phi
		self.FP = fp
		self.S = s
		self.Q = q
		self.P = p

	#Limpia los datos de entrada, pero si no existen datos de entrada envía un mensaje y guarda en 0 toda la información
	def SeparaDatos(self, datosfuente):
		if len(datosfuente) ==0:
			print("SIN DATOS RECIBIDOS")
			return 0
		else:

			datos = datosfuente.split()
			self.V = datos[0]
			self.I = datos[1]
			self.T = datos[2]
			self.C = datos[3]
			return 1


	def CalculaParametros(self, service):
		#Calcula VRMS
		vrms = (((float(service.V) * 200)/1023))/math.sqrt(2)
		self.Vrms  = round(vrms,2)

		#Calcula IRMS
		irms = (((float(service.I) * 50)/1023))/math.sqrt(2)
		self.Irms = round(irms,2)

		#Calcula Angulo Fase
		self.AF = round((float(self.T) * (120 * math.pi)),2)

	        #Calcula Potencia Aparente (S)
		s = self.Vrms * self.Irms
		self.S = round(s,2)

	        #Calcula Factor de Potencia
		self.FP = round((math.cos(self.AF)),2)

	        #Calcula Potencia Reactiva (P)
		self.P = round((self.S * self.FP),2)

		#Calcula Potencia Activa (Q)
		self.Q = round((self.S * math.sin(self.AF)),2)

	#Convierte a grados el AF
	def Grados(self, radianes):
		grados=(radianes * 180)/math.pi
		return grados


	#Guarda datos en la nube
	def GuardaConsumo(self, service, estatus, idservicio):

#		cred = credentials.Certificate('credenciales.json')
#		firebase_admin.initialize_app(cred)

		print(idservicio)

		db = firestore.client()

		fecha = firebase_admin.datetime.datetime.timestamp(datetime.datetime.today())

		hoy = datetime.datetime.now()       #OBTIENE LA FECHA DE HOY PARA CONCATETAR AL ID DEL SERVICIO

		if (len(str(hoy.month)) == 1):
			mes = '0'+ str(hoy.month)
		else:
			mes=str(hoy.month)

		if (len(str(hoy.day)) == 1):
			dia = '0'+ str(hoy.day)
		else:
			dia=str(hoy.day)

		if (len(str(hoy.hour)) == 1):
			hor = '0'+ str(hoy.hour)
		else:
			hor=str(hoy.hour)

		if (len(str(hoy.minute)) == 1):
			min = '0'+ str(hoy.minute)
		else:
			min = str(hoy.minute)


		if (len(str(hoy.second)) == 1):
			sec = '0'+ str(hoy.second)
		else:
			sec =str(hoy.second)
		idfecha = str(hoy.year)+ mes + dia + hor + min + sec
		id_lectura =  idfecha + idservicio[8:12]

		consumo={
			'Vrms': service.Vrms,
			'Irms': service.Irms,
			'Capacitores': service.C,
			'AnguloFase': service.AF,
			'FP': service.FP,
			'P': service.P,
			'Q': service.Q,
			'S': service.S,
			'FechaLectura': fecha,
			'estatus': estatus,
			'id_lectura': id_lectura
		}
#		print('ID funcion guardar: '+ idservicio)
		#idservicio =u''+idservicio
		consumo_ref = db.collection(u'servicios').document(idservicio)
		lectura = consumo_ref.collection(u'consumos').document(id_lectura).set(consumo, merge = True)

		print('¡Datos de consumo guardados exitosamente')


	def LeeIdServicios(self):
		try:
#			cred = credentials.Certificate('credenciales.json')
#			firebase_admin.initialize_app(cred)

			db = firestore.client()

#			servicios = db.collection('servicios').stream()   #OBTIENE TODOS LOS SERVICIOS

#			servicios = db.collection(u'servicios')
#			query = servicios.order_by(u'id,direction = firestore.Query.ASCENDING).limit(10)
#			resultados = query.stream()

			servicios = db.collection(u'servicios').order_by(FieldPath.document_id())
			query = servicios.limit(10000)
			resultados = query.stream()

			return resultados

		except (RuntimeError, TypeError, ValueError, NameError):
			print("ERROR EN LEE IDSERVICIOS:{0}".format(err))
