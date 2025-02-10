<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Training - Search Customer</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <header>
        <h1>Training</h1>
        <nav>
            <a href="#">Login</a> > <span>Search Customer</span>
        </nav>
    </header>

    <section class="search-container">
        <p>Welcome ABC</p>
        <form id="searchForm" action="CustomerServlet" method="GET">
            <input type="text" name="customerName" placeholder="Customer Name">
            <select name="sex">
                <option value="">Select</option>
                <option value="Male">Male</option>
                <option value="Female">Female</option>
            </select>
            <input type="date" name="birthdayStart">
            <input type="date" name="birthdayEnd">
            <button type="submit">Search</button>
        </form>
    </section>

    <section class="table-container">
        <table>
            <thead>
                <tr>
                    <th><input type="checkbox" id="selectAll"></th>
                    <th>USERID</th>
                    <th>Name</th>
                    <th>Sex</th>
                    <th>Birthday</th>
                    <th>Address</th>
                </tr>
            </thead>
            <tbody>
                <%
                    java.util.List<Customer> customers = (java.util.List<Customer>) request.getAttribute("customers");
                    if (customers != null) {
                        for (Customer customer : customers) {
                %>
                <tr>
                    <td><input type="checkbox" class="select-item" value="<%= customer.getUserId() %>"></td>
                    <td><%= customer.getUserId() %></td>
                    <td><%= customer.getName() %></td>
                    <td><%= customer.getSex() %></td>
                    <td><%= customer.getBirthday() %></td>
                    <td><%= customer.getAddress() %></td>
                </tr>
                <%
                        }
                    }
                %>
            </tbody>
        </table>
        <button id="addUser">Add User</button>
        <button id="deleteSelected">DELETE</button>
    </section>

    <footer>
        <p>Bản quyền</p>
    </footer>

    <script src="script.js"></script>
</body>
</html>
