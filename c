window.onload = function() {
    // Lấy tất cả các tham số từ URL
    let params = new URLSearchParams(window.location.search);

    // Duyệt qua tất cả các khóa trong sessionStorage
    for (let key in sessionStorage) {
        if (sessionStorage.hasOwnProperty(key)) {
            // Nếu tham số không có trong URL, xóa khỏi sessionStorage và ô input
            if (!params.has(key)) {
                sessionStorage.removeItem(key);
                let inputElement = document.getElementById(key);
                if (inputElement) {
                    inputElement.value = '';
                }
            } else {
                // Nếu tham số có trong URL, cập nhật ô input với giá trị từ sessionStorage
                let inputElement = document.getElementById(key);
                if (inputElement) {
                    inputElement.value = sessionStorage.getItem(key);
                }
            }
        }
    }

    // Cập nhật sessionStorage với các tham số hiện có trong URL
    params.forEach((value, key) => {
        sessionStorage.setItem(key, value);
        let inputElement = document.getElementById(key);
        if (inputElement) {
            inputElement.value = value;
        }
    });
};

// Lưu các tham số tìm kiếm vào sessionStorage khi submit form
document.getElementById("searchForm").addEventListener("submit", function() {
    let inputs = document.querySelectorAll("#searchForm input[name]");
    inputs.forEach(input => {
        let value = input.value.trim();
        if (value) {
            sessionStorage.setItem(input.name, value);
        } else {
            sessionStorage.removeItem(input.name);
        }
    });
});
