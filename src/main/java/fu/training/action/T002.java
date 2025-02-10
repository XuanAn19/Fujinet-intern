package fu.training.action;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet implementation class T002
 */
@WebServlet("/T002")
public class T002 extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public T002() {
        super();
        // TODO Auto-generated constructor stub
    }

 // Thông tin kết nối CSDL
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/customer_db";
    private static final String JDBC_USER = "root"; // Thay bằng user của bạn
    private static final String JDBC_PASSWORD = ""; // Nếu có mật khẩu, hãy thêm vào đây

    // Xử lý GET request
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String sex = request.getParameter("sex");
        String birthFrom = request.getParameter("birthFrom");
        String birthTo = request.getParameter("birthTo");

        List<String[]> customers = new ArrayList<>();

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            String sql = "SELECT * FROM customers WHERE 1=1";
            if (name != null && !name.isEmpty()) sql += " AND name LIKE ?";
            if (sex != null && !sex.isEmpty()) sql += " AND sex = ?";
            if (birthFrom != null && !birthFrom.isEmpty()) sql += " AND birth_date >= ?";
            if (birthTo != null && !birthTo.isEmpty()) sql += " AND birth_date <= ?";

            PreparedStatement stmt = conn.prepareStatement(sql);
            int paramIndex = 1;

            if (name != null && !name.isEmpty()) stmt.setString(paramIndex++, "%" + name + "%");
            if (sex != null && !sex.isEmpty()) stmt.setString(paramIndex++, sex);
            if (birthFrom != null && !birthFrom.isEmpty()) stmt.setDate(paramIndex++, Date.valueOf(birthFrom));
            if (birthTo != null && !birthTo.isEmpty()) stmt.setDate(paramIndex++, Date.valueOf(birthTo));

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                customers.add(new String[]{
                        rs.getString("id"),
                        rs.getString("name"),
                        rs.getString("sex"),
                        rs.getString("birth_date"),
                        rs.getString("address")
                });
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("customers", customers);
        request.getRequestDispatcher("pages/search.jsp").forward(request, response);
    }
}
