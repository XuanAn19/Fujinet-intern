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
    private CustomerDAO customerDAO = new CustomerDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("customerName");
        String sex = request.getParameter("sex");
        String birthdayStart = request.getParameter("birthdayStart");
        String birthdayEnd = request.getParameter("birthdayEnd");

        List<Customer> customers = customerDAO.searchCustomers(name, sex, birthdayStart, birthdayEnd);
        request.setAttribute("customers", customers);
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Gson gson = new Gson();
        DeleteRequest deleteRequest = gson.fromJson(request.getReader(), DeleteRequest.class);

        boolean success = customerDAO.deleteCustomers(deleteRequest.deleteIds);
        response.setContentType("application/json");
        response.getWriter().write(gson.toJson(new Response(success)));
    }

    class DeleteRequest {
        List<String> deleteIds;
    }

    class Response {
        boolean success;
        Response(boolean success) { this.success = success; }
    }
}
