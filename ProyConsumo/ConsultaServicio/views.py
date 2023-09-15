from operator import truediv
from django import views
from django.shortcuts import render
from django.http import HttpResponse
from django.views.generic import View
import firebase_admin
from firebase_admin import credentials
from google.cloud import firestore
from google.cloud import firestore_admin_v1
from firebase_admin import firestore, initialize_app
import os
import datetime

from grpc import stream_stream_rpc_method_handler
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = r"credentials_Tests.json"

# Create your views here.

# Función que recopilará datos de los servicios

def Inicio(request):
   
    db = firestore.Client()
    
    servicios = db.collection('servicios').stream()
    DataServicios = {
    'servicios': [servicio.to_dict() for servicio in servicios]
    }
    return render(request,"index.html",DataServicios)


#Función que obtendrá las lecturas de todos los servicios
def ConsumoServicio(request):
    
    db = firestore.Client()
    ref_servicios=db.collection(u'servicios').document('2')
    ref_consumos = ref_servicios.collection(u'consumos').stream()

   
   # datos={'collConsumo':[consumo.to_dict() for consumo in ref_consumos]}
     #tam =len(datos['collConsumo'])
    #ref_consumos = ref_servicios.collection(u'consumos').stream()

    datos={consumo.id:consumo.to_dict() for consumo in ref_consumos}

    print(datos)

    for dato in datos:
        print(dato, ":",datos[dato]["FechaLectura"])
        fechatmstmp=datos[dato]["FechaLectura"]
        fechadtm=datetime.datetime.fromtimestamp(fechatmstmp)
        datos[dato]["Fecha"]=fechadtm
        print(dato, ":",datos[dato]["Fecha"])

       
    return render(request,"consumo.html", {'datos':datos})
   
 
    

   
    
