document.addEventListener("DOMContentLoaded", function () {
    const sidebar = document.getElementById("sidebar");
    const toggle = document.getElementById("sidebarToggle");

    if (toggle && sidebar) {
        toggle.addEventListener("click", function () {
            if (window.innerWidth <= 991) {
                sidebar.classList.toggle("open");
            } else {
                sidebar.classList.toggle("collapsed");
            }
        });
    }
});