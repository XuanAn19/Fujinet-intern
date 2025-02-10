<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Search</title>
    <link rel="stylesheet" href="../css/T002.css">
</head>
<body>

    <div class="container">
        <h2>Training</h2>
        <a href="login.jsp">Login</a> > <span>Search Customer</span>
        <p>Welcome ABC</p>

        <div class="search-container">
            <label>Customer Name</label>
            <input type="text" id="customerName">
            <label>Sex</label>
            <select id="sex">
                <option value="">All</option>
                <option value="Male">Male</option>
                <option value="Female">Female</option>
            </select>
            <label>Birth day</label>
            <input type="date" id="birthFrom"> ~ 
            <input type="date" id="birthTo">
            <button onclick="searchCustomer()">Search</button>
        </div>

        <table>
            <thead>
                <tr>
                    <th>Select</th>
                    <th>USERID</th>
                    <th>Name</th>
                    <th>Sex</th>
                    <th>Birthday</th>
                    <th>Address</th>
                </tr>
            </thead>
            <tbody id="customerTable">
                <tr>
                    <td><input type="checkbox"></td>
                    <td>USER01</td>
                    <td>Nguyen Xuan An</td>
                    <td>Male</td>
                    <td>2021/11/15</td>
                    <td>Quy Nhon</td>
                </tr>
            </tbody>
        </table>

        <button onclick="addUser()">Add User</button>
        <button onclick="deleteUser()">DELETE</button>

    </div>

    <script src="../js/script.js"></script>
</body>
</html>
