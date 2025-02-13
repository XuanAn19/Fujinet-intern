import com.google.gson.Gson;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;
import java.util.Map;

@WebServlet("/UserServlet")
public class UserServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8"); // Đảm bảo hỗ trợ tiếng Việt
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            BufferedReader reader = request.getReader();
            Gson gson = new Gson();
            Map<String, List<String>> requestData = gson.fromJson(reader, Map.class);
            List<String> userIds = requestData.get("userIds");

            if (userIds == null || userIds.isEmpty()) {
                response.getWriter().write("{\"success\": false, \"message\": \"Không có user nào được chọn\"}");
                return;
            }

            try (Connection conn = DatabaseUtil.getConnection()) {
                String sql = "UPDATE users SET delete_YMD = NOW() WHERE user_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);

                for (String id : userIds) {
                    try {
                        int userId = Integer.parseInt(id);
                        stmt.setInt(1, userId);
                        stmt.addBatch();
                    } catch (NumberFormatException e) {
                        System.out.println("Lỗi chuyển đổi user_id: " + id);
                    }
                }

                int[] results = stmt.executeBatch();
                int updatedRows = 0;
                for (int result : results) {
                    if (result > 0) updatedRows++;
                }

                if (updatedRows > 0) {
                    response.getWriter().write("{\"success\": true, \"message\": \"Xóa thành công " + updatedRows + " người dùng!\"}");
                } else {
                    response.getWriter().write("{\"success\": false, \"message\": \"Không có bản ghi nào được cập nhật!\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write("{\"success\": false, \"message\": \"Lỗi hệ thống!\"}");
            }
        }
    }
}


function deleteSelectedUsers() {
    const selectedIds = Array.from(document.querySelectorAll(".row-checkbox:checked"))
        .map(checkbox => checkbox.dataset.userId); // Lấy danh sách ID đã chọn

    if (selectedIds.length === 0) {
        alert("Vui lòng chọn ít nhất một người dùng để xóa.");
        return;
    }

    if (!confirm(`Bạn có chắc chắn muốn xóa ${selectedIds.length} người dùng không?`)) {
        return;
    }

    console.log("User IDs gửi lên:", selectedIds); // Debug

    fetch("UserServlet?action=delete", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ userIds: selectedIds })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert(data.message || "Xóa thành công!");
            location.reload(); // Load lại trang để cập nhật danh sách
        } else {
            alert(data.message || "Có lỗi xảy ra!");
        }
    })
    .catch(error => {
        console.error("Lỗi:", error);
        alert("Lỗi kết nối đến server!");
    });
}


<table>
    <thead>
        <tr>
            <th><input type="checkbox" onclick="toggleSelectAll(this)"></th>
            <th>ID</th>
            <th>Tên</th>
            <th>Giới tính</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><input type="checkbox" class="row-checkbox" data-user-id="1"></td>
            <td>1</td>
            <td>Nguyễn Văn A</td>
            <td>Nam</td>
        </tr>
        <tr>
            <td><input type="checkbox" class="row-checkbox" data-user-id="2"></td>
            <td>2</td>
            <td>Trần Thị B</td>
            <td>Nữ</td>
        </tr>
    </tbody>
</table>

<button onclick="deleteSelectedUsers()">Xóa các user đã chọn</button>

<h1>ngay sinh<h1>


document.getElementById("searchForm").addEventListener("submit", function (event) {
    const customerName = document.querySelector("input[name='customerName']").value.trim();
    const birthdayStart = document.querySelector("input[name='birthdayStart']").value.trim();
    const birthdayEnd = document.querySelector("input[name='birthdayEnd']").value.trim();
    const today = new Date().toISOString().split("T")[0]; // Ngày hiện tại (YYYY-MM-DD)

    // Kiểm tra độ dài CustomerName (tối đa 50 ký tự)
    if (customerName.length > 50) {
        alert("Tên khách hàng không được vượt quá 50 ký tự!");
        event.preventDefault();
        return;
    }

    // Kiểm tra độ dài BirthDayFrom, BirthDayTo (tối đa 10 ký tự)
    if (birthdayStart.length > 10 || birthdayEnd.length > 10) {
        alert("Ngày sinh chỉ được nhập tối đa 10 ký tự (YYYY-MM-DD)!");
        event.preventDefault();
        return;
    }

    // Kiểm tra định dạng ngày sinh (YYYY-MM-DD)
    const datePattern = /^\d{4}-\d{2}-\d{2}$/;
    if (birthdayStart && !datePattern.test(birthdayStart)) {
        alert("Ngày bắt đầu không đúng định dạng (YYYY-MM-DD)!");
        event.preventDefault();
        return;
    }

    if (birthdayEnd && !datePattern.test(birthdayEnd)) {
        alert("Ngày kết thúc không đúng định dạng (YYYY-MM-DD)!");
        event.preventDefault();
        return;
    }

    // Kiểm tra ngày bắt đầu không lớn hơn ngày kết thúc
    if (birthdayStart && birthdayEnd && birthdayStart > birthdayEnd) {
        alert("Ngày bắt đầu không thể lớn hơn ngày kết thúc!");
        event.preventDefault();
        return;
    }

    // Kiểm tra ngày sinh không vượt quá ngày hiện tại
    if ((birthdayStart && birthdayStart > today) || (birthdayEnd && birthdayEnd > today)) {
        alert("Ngày sinh không thể lớn hơn ngày hiện tại!");
        event.preventDefault();
    }
});




