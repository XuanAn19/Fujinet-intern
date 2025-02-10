package fu.training.dao;

public class T002 {
	 public List<Customer> searchCustomers(String name, String sex, String birthdayStart, String birthdayEnd) {
	        List<Customer> customers = new ArrayList<>();
	        String sql = "SELECT * FROM customers WHERE 1=1"; // Bắt đầu với điều kiện luôn đúng để dễ dàng thêm điều kiện khác

	        // Thêm điều kiện nếu có input
	        if (name != null && !name.trim().isEmpty()) sql += " AND name LIKE ?";
	        if (sex != null && !sex.isEmpty()) sql += " AND sex = ?";
	        if (birthdayStart != null && !birthdayStart.isEmpty()) sql += " AND birthday >= ?";
	        if (birthdayEnd != null && !birthdayEnd.isEmpty()) sql += " AND birthday <= ?";

	        try (Connection conn = DatabaseConnection.getConnection();
	             PreparedStatement stmt = conn.prepareStatement(sql)) {

	            int index = 1;
	            if (name != null && !name.trim().isEmpty()) stmt.setString(index++, "%" + name + "%");
	            if (sex != null && !sex.isEmpty()) stmt.setString(index++, sex);
	            if (birthdayStart != null && !birthdayStart.isEmpty()) stmt.setString(index++, birthdayStart);
	            if (birthdayEnd != null && !birthdayEnd.isEmpty()) stmt.setString(index++, birthdayEnd);

	            ResultSet rs = stmt.executeQuery();
	            while (rs.next()) {
	                customers.add(new Customer(
	                    rs.getString("user_id"),
	                    rs.getString("name"),
	                    rs.getString("sex"),
	                    rs.getString("birthday"),
	                    rs.getString("address")
	                ));
	            }
	        } catch (SQLException e) {
	            e.printStackTrace();
	        }
	        return customers;
	    }
}
