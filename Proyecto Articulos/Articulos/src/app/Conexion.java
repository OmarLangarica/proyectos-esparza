package app;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexion {
    
    public static String servidor="localhost";
    public static  String database = "Ventas";
    public static  String usuario="pruebaarticulos";
    public static  String contraseña="123";
    static String error = "";
    static boolean estatus = false;
    
    public static Connection getConexion(){
        String conexionUrl = "jdbc:sqlserver://"+servidor+":1433;"
                + "database="+database+";"
                + "user="+usuario+";"
                + "password="+contraseña+";"
                + "loginTimeout=10;"
                + "trustServerCertificate=True";
        try{
            Connection con = DriverManager.getConnection(conexionUrl);
            estatus =true;
            return con;
        }catch(SQLException e){
            System.out.println(e.getMessage());
            error =e.getMessage();
            estatus = false;
            return null;
        }
    }
}
