/**
 * 
 */

function searchCustomer() {
    let name = document.getElementById("customerName").value;
    let sex = document.getElementById("sex").value;
    let birthFrom = document.getElementById("birthFrom").value;
    let birthTo = document.getElementById("birthTo").value;

    console.log("Searching for:", name, sex, birthFrom, birthTo);
}

function addUser() {
    alert("Add User Clicked!");
}

function deleteUser() {
    alert("Delete User Clicked!");
}
