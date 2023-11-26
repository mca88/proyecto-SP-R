#!/usr/bin/env python3

from sensor_msgs.msg import Image 
from cv_bridge import CvBridge
from threading import Thread, Lock
import socket
import math
import numpy as np
import cv2 
import rospy

amBajo = np.array([25,80,100],np.uint8)
amAlto = np.array([34,255,255],np.uint8)

verBajo = np.array([35,80,30],np.uint8)
verAlto = np.array([80,255,255],np.uint8)

morBajo = np.array([128,85,0],np.uint8)
morAlto = np.array([170,255,145],np.uint8)

global_info_points = 1
lock = Lock()

HOST = '10.0.2.15'
PORT = 8080
ADDR = (HOST,PORT)
BUFFER_SIZE = 1024 
ENCODING = 'utf-8'

num_range = ["0","1","2","3","4","5","6","7"]

def change_global_points(value):
    global global_info_points
    with lock:
        global_info_points = value


def callback_socket(conn, addr):
    with conn:
        print(f"Connected by {addr}")
        while True:
            try:
                data = conn.recv(BUFFER_SIZE).decode(ENCODING)

                if(data in num_range):
                    print(f"El servidor ha recibido: {data}")
                    pos = eval(data)
                    
                    x = global_info_points[pos][0]
                    y = global_info_points[pos][1]
                    conn.sendall(f"{x},{y}".encode(ENCODING))
                else:
                    print("no sé qué me has dado")
                    conn.close()
                    return

            except Exception:
                print("Cliente desconectado")
                return
            
def init_socket_server():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(ADDR)
        print("SERVER RUNNING")
        s.listen()

        while True:
            conn, addr = s.accept()
            thread = Thread(target=callback_socket, args=(conn,addr))
            thread.start()

def view_points(x,y,frame):
    cv2.circle(frame, (int(x), int(y)), 5, (0, 255, 0), -1) #para dibujar un punto en el centro del frame

def detcont(mask,color, frame):
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5,5))
    closing = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
    opening = cv2.morphologyEx(closing, cv2.MORPH_OPEN, kernel)
    contornos,_ = cv2.findContours(opening,cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    centro_x = 1
    centro_y = 1
    for contorno in contornos:
        area = cv2.contourArea(contorno)
        if area > 500 and area < 1300:
            x, y, w, h = cv2.boundingRect(contorno)
            cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0),2)

            centro_x = x + w // 2
            centro_y = y + h // 2
            cv2.circle(frame, (centro_x, centro_y), 5, (0, 255, 0), -1) #para dibujar un punto en el centro del frame
            coordenadas_texto_color = '{}'.format(color)
            font = cv2.FONT_HERSHEY_SIMPLEX
            cv2.putText(frame, coordenadas_texto_color, (x-10, y-5), font, 0.3, (0, 255, 0), 1, cv2.LINE_AA)
                
    return centro_x, centro_y

def calculate_equidistant_points(point2, point4, point7, distance):
    
    # Calcular el vector en la direccion de la linea
    dx = point7[0] - point2[0]
    dy = point7[1] - point2[1]
    magnitude = math.sqrt(dx**2 + dy**2)
    try:
        unit_vector = (dx / magnitude, dy / magnitude)
    except Exception as e:
        unit_vector = [0,0]
        print("no hay teclado!")

    # Calcular los puntos deseados
    point1 = (point2[0] - distance * unit_vector[0], point2[1] - distance * unit_vector[1])
    point3 = (point2[0] + distance * unit_vector[0], point2[1] + distance * unit_vector[1])         
    point5 = (point4[0] + distance * unit_vector[0], point4[1] + distance * unit_vector[1])         
    point6 = (point7[0] - distance * unit_vector[0], point7[1] - distance * unit_vector[1])         
    point8 = (point7[0] + distance * unit_vector[0], point7[1] + distance * unit_vector[1])     

    point1 = (int(point1[0]), int(point1[1]))
    point3 = (int(point3[0]), int(point3[1]))
    point5 = (int(point5[0]), int(point5[1]))
    point6 = (int(point6[0]), int(point6[1]))
    point8 = (int(point8[0]), int(point8[1]))

    return [point1, point2, point3, point4, point5, point6, point7, point8]
 
def callback(data):
    br = CvBridge()
    frame = br.imgmsg_to_cv2(data)

    frameHSV = cv2.cvtColor(frame,cv2.COLOR_BGR2HSV)

    maskam  = cv2.inRange(frameHSV,amBajo,amAlto)
    maskver = cv2.inRange(frameHSV, verBajo, verAlto)
    maskmor = cv2.inRange(frameHSV, morBajo, morAlto)

    point7x, point7y = detcont(maskam,"Tecla amarilla",frame)
    point4x, point4y = detcont(maskver,"Tecla verde", frame)
    point2x, point2y = detcont(maskmor,"Tecla morada", frame)

    point7 = (point7x, point7y)
    point4 = (point4x, point4y)
    point2 = (point2x, point2y)
    distance = 36

    equidistant_points = calculate_equidistant_points(point2, point4, point7, distance)
    change_global_points(equidistant_points)

    punto1 = equidistant_points[0]
    punto2 = equidistant_points[2]
    punto3 = equidistant_points[4]
    punto4 = equidistant_points[5]
    punto5 = equidistant_points[7]  

    view_points(int(punto1[0]),int(punto1[1]), frame)
    view_points(int(punto2[0]),int(punto2[1]), frame)
    view_points(int(punto3[0]),int(punto3[1]), frame)
    view_points(int(punto4[0]),int(punto4[1]), frame)
    view_points(int(punto5[0]),int(punto5[1]), frame)

    cv2.imshow('Webcam', frame)

    cv2.waitKey(1)
          
def receive_message():
  rospy.Subscriber('video_frames', Image, callback)
  rospy.spin()
  
if __name__ == '__main__':
    rospy.init_node('video_cons', anonymous=True)
    web_cam = Thread(target=receive_message)
    socket_server = Thread(target=init_socket_server)

    web_cam.start()
    socket_server.start()
