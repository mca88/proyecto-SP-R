MODULE Module1
    VAR socketdev client;
    CONST string test_IP  := "127.0.0.1";
    CONST string robot_IP := "192.168.125.6";
    CONST string IP := robot_IP;
    VAR num PORT := 8080;
    
    CONST speeddata SLOW := v80;
    CONST speeddata MED := v80;
    CONST speeddata FAST := v500;
    
    CONST num x_offset := 230.63;
    CONST num y_offset := 323.93;
    CONST num cam_height := 480;
    
    VAR num socket_numbers{2};
    
    VAR robtarget tecla0;
    VAR robtarget tecla1;
    VAR robtarget tecla2;
    VAR robtarget tecla3;
    VAR robtarget tecla4;
    VAR robtarget tecla5;
    VAR robtarget tecla6;
    VAR robtarget tecla7;
    
    CONST robtarget Inicio:=[[250,0,556],[0.5,0,0.866025404,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    PROC main()
        movimiento;
    ENDPROC
    
    PROC estatico()
        VAR speeddata velocidad := v300;
        
        SocketClose client;
        createSocket;
        
        MoveJ Inicio,MED,z100,MyNewTool\WObj:=wobj0;
        
        tecla0 := get_robtarget("0");
        tecla1 := get_robtarget("1");
        tecla2 := get_robtarget("2");
        tecla3 := get_robtarget("3");
        tecla4 := get_robtarget("4");
        tecla5 := get_robtarget("5");
        tecla6 := get_robtarget("6");
        tecla7 := get_robtarget("7");
        
        SocketClose client;
        
        MoveL tecla5,velocidad,z100,MyNewTool\WObj:=wobj0;
        FOR i FROM 1 TO 3 DO
            pulsarTecla(tecla5);
        ENDFOR
        WaitTime 0.5;
        FOR i FROM 1 TO 3 DO
            pulsarTecla(tecla5);
        ENDFOR
        WaitTime 0.5;
        
        pulsarTecla(tecla5);
        MoveL tecla6,velocidad,z100,MyNewTool\WObj:=wobj0;
        pulsarTecla(tecla7);
        MoveL tecla3,velocidad,z100,MyNewTool\WObj:=wobj0;
        pulsarTecla(tecla3);
        MoveL tecla4,velocidad,z100,MyNewTool\WObj:=wobj0;
        pulsarTecla(tecla4);
        MoveL tecla5,velocidad,z100,MyNewTool\WObj:=wobj0;
        pulsarTecla(tecla5);
        
!        WaitTime 1;
        
        MoveL tecla6,velocidad,z100,MyNewTool\WObj:=wobj0;
        FOR i FROM 1 TO 3 DO
            pulsarTecla(tecla6);
        ENDFOR
!        WaitTime 0.5;
        FOR i FROM 1 TO 2 DO
            pulsarTecla(tecla6);
        ENDFOR
        
        MoveL tecla5,velocidad,z100,MyNewTool\WObj:=wobj0;
        FOR i FROM 1 TO 2 DO
            pulsarTecla(tecla5);
        ENDFOR
!        WaitTime 0.5;
        FOR i FROM 1 TO 2 DO
            pulsarTecla(tecla5);
        ENDFOR
        MoveL tecla4,velocidad,z100,MyNewTool\WObj:=wobj0;
        FOR i FROM 1 TO 2 DO
            pulsarTecla(tecla4);
        ENDFOR
        MoveL tecla5,velocidad,z100,MyNewTool\WObj:=wobj0;
        pulsarTecla(tecla5);
        MoveL tecla4,velocidad,z100,MyNewTool\WObj:=wobj0;
        pulsarTecla(tecla4);
        MoveL tecla7,velocidad,z100,MyNewTool\WObj:=wobj0;
        pulsarTecla(tecla7);
    ENDPROC
    
    PROC movimiento()
        VAR speeddata velocidad := v200;
        SocketClose client;
        createSocket;
        
        
        MoveJ Inicio,MED,z100,MyNewTool\WObj:=wobj0;
        
        FOR i FROM 0 TO 7 DO
            tecla0 := get_robtarget(ValToStr(i));
            MoveL tecla0,velocidad,z100,MyNewTool\WObj:=wobj0;
            pulsarTecla(tecla0);
            retirar_herramienta(tecla0);
        
            WaitTime 1;
        ENDFOR
        
    ENDPROC
    
    FUNC robtarget get_robtarget(string pos)
        VAR string respuesta;
        VAR bool ok;
        respuesta := requestSocket(pos);
        ok := msg_to_number(respuesta);
        IF ok THEN
            RETURN pixel_to_robtarget(pos);
        ENDIF
    ENDFUNC
    
    FUNC robtarget pixel_to_robtarget(string pos)
        VAR num pixel_x;
        VAR num pixel_y;
        VAR num coord_x;
        VAR num coord_y;
        VAR robtarget coord_final;

        pixel_x := socket_numbers{2};
        pixel_y := socket_numbers{1};
        pixel_x := cam_height - pixel_x;
        
        coord_x := pixel_x * 1.04;
        coord_y := pixel_y * 1.04;
        
        coord_x := coord_x + x_offset;
        coord_y := y_offset - coord_y;
        IF pos = "4" or pos = "6" OR pos = "7" THEN
            coord_y := coord_y + 15;
        ENDIF
        
        IF pos = "0" THEN
            coord_y := coord_y -10;
        ENDIF
        
        coord_final :=[[coord_x,coord_y,60],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        
        RETURN coord_final;
    ENDFUNC
    
    FUNC bool msg_to_number(string msg)
        VAR bool save_num1 := TRUE;
        VAR string letra;
        VAR string num1_str;
        VAR string num2_str;
        VAR num num1;
        VAR num num2;
        VAR bool ok;
        
        FOR i FROM 1 TO StrLen(msg) DO
            letra := StrPart(msg, i, 1);
            IF letra = "," THEN
                save_num1 := FALSE;
            ENDIF
            IF save_num1 and letra <> "," THEN
                num1_str := num1_str + letra;
            ELSEIF save_num1 = FALSE and letra <> "," THEN
                num2_Str := num2_str + letra;
            ENDIF
        ENDFOR
        ok := StrToVal(num1_str, num1);
        ok := StrToVal(num2_str, num2);
        
        socket_numbers{1} := num1;
        socket_numbers{2} := num2;
        
        RETURN TRUE;
    ENDFUNC
    
    
    PROC createSocket()
        SocketCreate client;
        SocketConnect client, IP, PORT;
    ENDPROC
    
    FUNC string requestSocket(string request)
        VAR string respuesta;
        
        SocketSend client, \Str:= request;
        SocketReceive client, \Str:= respuesta;
        
        RETURN respuesta;
    ENDFUNC
    
    PROC pulsarTecla(robtarget currentRobTarget)
        currentRobTarget.trans.z := 60;
        MoveL currentRobTarget,MED,fine,MyNewTool\WObj:=wobj0;
        
        currentRobTarget.trans.z := 35;
        MoveL currentRobTarget,FAST,fine,MyNewTool\WObj:=wobj0;
        
        currentRobTarget.trans.z := 60;
        MoveL currentRobTarget,FAST,fine,MyNewTool\WObj:=wobj0;
    ENDPROC
    
    PROC retirar_herramienta(robtarget currentRobTarget)
        CONST speeddata vel_retirar := v200;
        VAR robtarget pos_retirar;
        pos_retirar := Offs(currentRobTarget, -150, 0, 0);
        MoveL pos_retirar,vel_retirar,fine,MyNewTool\WObj:=wobj0;
    ENDPROC
    
    PROC Path_10()
        VAR robtarget Pos_Tecla:=[[526.027,83.89,60],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        MoveJ Inicio,MED,z100,MyNewTool\WObj:=wobj0;
        
        FOR i FROM 0 TO 6 DO
            MoveL Pos_Tecla,MED,z100,MyNewTool\WObj:=wobj0;
            pulsarTecla(Pos_Tecla);
            Pos_Tecla := Offs(Pos_Tecla, 0, -31, 0);
        ENDFOR
    ENDPROC
ENDMODULE