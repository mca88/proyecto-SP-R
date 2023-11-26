Estructura de códigos

código-robot-studio:
    Programa realizado en RAPID conformado por todas las variables y funciones. Para abir los archivos .mod se puede usar un editor de texto o el propio robot studio

nodos-opencv-ros:
    Códigos pertenecientes al sistema de Ubuntu. Aquí encontraremos tanto el funcionamiento de ROS como la lógica al tratar las imágenes.

    webcam-publisher.py: Nodo de ROS encargado de ir publicando los frames de una webcam a un tópico

    webcam-consumer.py: Consume los frames obtenidos del tópico, los procesa y se encarga de transmitir la información a través de un servidor de sockets.