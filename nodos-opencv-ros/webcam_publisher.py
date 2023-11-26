#!/usr/bin/env python3

import rospy
from sensor_msgs.msg import Image 
from cv_bridge import CvBridge 
import cv2
from time import sleep

def publish_msg():

  img_publisher = rospy.Publisher('video_frames', Image, queue_size=10)
  rospy.init_node('video_pub', anonymous=True)

  cap = cv2.VideoCapture(0)  # 0 indica la camara predeterminada, si tienes multiples camaras, puedes cambiar el indice
  cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)  # Ancho del cuadro de captura
  cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)  # Alto del cuadro de capturacap = cv2.VideoCapture(0)
  br = CvBridge()
  # rate = rospy.Rate(1)

  while not rospy.is_shutdown():
    
    ret, frame = cap.read()
        
    if ret == True:
      rospy.loginfo('Publicando frame')
            
      img_publisher.publish(br.cv2_to_imgmsg(frame))

      sleep(0.1)
             
      
         
if __name__ == '__main__':
  try:
    publish_msg()
  except rospy.ROSInterruptException:
    print("Salimos")