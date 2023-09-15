import serial
import time
import math
import re
import os
import Consumo
import firebase_admin
from firebase_admin import credentials
from google.cloud import firestore
from google.cloud import firestore_admin_v1
from firebase_admin import firestore


print('Iniciando ... Presiones CTRL-C para salir.')
with serial.Serial("/dev/ttyS0",9600,timeout=1,write_timeout=1.0) as puerto:
	#time.sleep(0.3)
	if puerto.isOpen():
		print("{} Puerto abierto...".format(puerto.port))
		try:
			cred = credentials.Certificate(r'/home/pi/AMI/credentials_Tests.json')
#			os.environ["GOOGLE_APPLICATION_CREDENTIALS"] =r"/home/pi/AMI/credentials_B.json"
			firebase_admin.initialize_app(cred)
			db = firestore.client()
			service = Consumo.Consumo(0,0,0,0,0,0,0,0,0,0,0)
#			id = input("Escriba un ID de equipo: ")
			servicios = list(service.LeeIdServicios())   #LEE LOS SERVICIOS DISPONIBLES EN LA NUBE

#			if len(servicios)==0:
#				print('NO EXISTEN SERVICIOS EN LA BASE DE DATOS')
#				exit()
#			else:
#				print(len(servicios))
#				exit()

			while True:
				for serv in servicios:
#				for i in range (1,11):
					#id = str(i)+'\n'
#					print(id)
					print(f'{serv.id}')
					id_servicio= serv.id + '\n'
					puerto.write(id_servicio.encode())		#DATOS ENVIADOS
#					puerto.write(id.encode())

					while puerto.inWaiting() == 1: pass

					answer = str(puerto.readline().decode()) #DATOS RECIBIDOS POR LINEA Y NO POR CARACTER
					print(f"{answer}")
					answer = re.sub("~","",answer)


					#SINO  SE OBTIENE RESPUESTA SE GUARDARAN EN 0 LOS VALORES
					if service.SeparaDatos(answer)==1:
						service.CalculaParametros(service)
						estatus=1
					else:
						estatus=0

#					f=open(datos.txt, service.V)
#					print("VOLTAJE ",service.V)
#					print("CORRIENTE ",service.I)
#					print("TIEMPO ",service.T)
#					print("CAPACITORES: ",service.C)
#					print("VRMS ", service.Vrms)
#					print("IRMS ",service.Irms)
#					print("ANGULO FASE",service.AF)
#					print("ANGULO FASE EN GRADOS ",service.Grados(service.AF))
#					print("FP ",service.FP)
#					print("S",service.S)
#					print("Q",service.Q)
#					print("P",service.P)
					print('id antes de guardar:'+ serv.id)
					service.GuardaConsumo(service,estatus,serv.id)


					puerto.flushInput()

				id = input(" Almacenamiento de datos terminado ")
		except serial.SerialTimeoutException:
			print("Tiempo de respuesta agotado")
		except KeyboardInterrupt:
			print(" Ha pulsado CTRL-C para salir")
			puerto.close()
		except serial.SerialException:
			print("PUERTO NO DISPONIBLE")
#	else:
#		print('No se ha logrado la comunicación...')

