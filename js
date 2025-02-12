@WebServlet("/UserServlet")
public class UserServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            BufferedReader reader = request.getReader();
            Gson gson = new Gson();
            Map<String, List<String>> requestData = gson.fromJson(reader, Map.class);
            List<String> userIds = requestData.get("userIds");

            try (Connection conn = DatabaseUtil.getConnection()) {
                String sql = "UPDATE users SET delete_YMD = NOW() WHERE user_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);

                for (String id : userIds) {
                    stmt.setInt(1, Integer.parseInt(id));
                    stmt.addBatch();
                }

                stmt.executeBatch();
                response.getWriter().write("{\"success\": true}");
            } catch (Exception e) {
                response.getWriter().write("{\"success\": false}");
                e.printStackTrace();
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

    // Gửi request đến Servlet để cập nhật delete_YMD
    fetch("UserServlet?action=delete", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ userIds: selectedIds })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert("Xóa thành công!");
            location.reload(); // Load lại trang để cập nhật danh sách
        } else {
            alert("Có lỗi xảy ra!");
        }
    })
    .catch(error => console.error("Lỗi:", error));
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
    const birthdayStart = document.querySelector("input[name='birthdayStart']").value;
    const birthdayEnd = document.querySelector("input[name='birthdayEnd']").value;
    const today = new Date().toISOString().split("T")[0]; // Ngày hiện tại (YYYY-MM-DD)

    if (birthdayStart && !/^\d{4}-\d{2}-\d{2}$/.test(birthdayStart)) {
        alert("Ngày bắt đầu không đúng định dạng (YYYY-MM-DD)!");
        event.preventDefault();
        return;
    }

    if (birthdayEnd && !/^\d{4}-\d{2}-\d{2}$/.test(birthdayEnd)) {
        alert("Ngày kết thúc không đúng định dạng (YYYY-MM-DD)!");
        event.preventDefault();
        return;
    }

    if (birthdayStart && birthdayEnd && birthdayStart > birthdayEnd) {
        alert("Ngày bắt đầu không thể lớn hơn ngày kết thúc!");
        event.preventDefault();
        return;
    }

    if ((birthdayStart && birthdayStart > today) || (birthdayEnd && birthdayEnd > today)) {
        alert("Ngày sinh không thể lớn hơn ngày hiện tại!");
        event.preventDefault();
    }
});




