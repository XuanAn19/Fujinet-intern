package fu.training.utils;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DBUtils {
	private static final String DB_SERVERNAME ="NXAN-INTERN-LAB";
    private static final String DB_LOGIN ="sa";
    private static final String DB_PASS ="12345@";
    private static final String DB_NAME ="DB001";


    
    // Đọc cấu hình từ file properties
    private static Properties loadProperties() throws IOException {
        Properties properties = new Properties();
        try (InputStream input = DBUtils.class.getClassLoader().getResourceAsStream("DBConfig.properties")) {
            if (input == null) {
                throw new IOException("Không tìm thấy file DBConfig.properties");
            }
            properties.load(input);
            System.out.println("Cấu hình đọc được từ file: ");
            properties.forEach((key, value) -> System.out.println(key + ": " + value));
        }
        return properties;
    }

    // Kết nối đến database chính
   public static Connection getConnection() throws SQLException, IOException {
        Properties properties = loadProperties();
        if (properties == null) {
            System.out.println("Lỗi đọc file cấu hình");
            return null;
        }
        String url = properties.getProperty("db.url");
        String username = properties.getProperty("db.username");
        String password = properties.getProperty("db.password");
        String driver = properties.getProperty("db.driver");

        
        try {
            Class.forName(driver); // Load driver SQL Server
        } catch (ClassNotFoundException e) {
            System.out.println("Lỗi kết nối ha: " + e.getMessage());
        }
        return DriverManager.getConnection(url, username, password);
    }

    public static Connection getConnectionn() {
    	try {
    		Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    		String url = "jdbc:sqlserver://"+DB_SERVERNAME+":1433"+";databaseName="+DB_NAME+";encrypt=true ; trustServerCertificate = true"; 
    		return DriverManager.getConnection(url, DB_LOGIN, DB_PASS);
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
		return null;
    }
   
    // Đóng kết nối
    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
                System.out.println("Đóng kết nối thành công.");
            } catch (SQLException e) {
                System.err.println("Lỗi đóng kết nối: " + e.getMessage());
            }
        }
    }
    
    public static void main(String[] args) {
        try {
            Connection connection = DBUtils.getConnection();
            if (connection != null) {
                System.out.println("Kết nối SQL Server thành công!");
                DBUtils.closeConnection(connection);
            } else {
                System.out.println("Kết nối thất bại!");
            }
        } catch (Exception e) {
        	System.out.println("Lỗi kết nối");
            e.printStackTrace();
        }
    }
}
