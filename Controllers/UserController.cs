using LTW_NHOM8.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LTW_NHOM8.Controllers
{
    public class UserController : Controller
    {
        private DB_LTWEntities db = new DB_LTWEntities();
        // GET: User
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Login(string LoginIdentity, string Password)
        {
            var user = db.Users.FirstOrDefault(u =>
                (u.Email == LoginIdentity || u.Phone == LoginIdentity)
                && u.Password == Password);

            if (user == null)
            {
                ViewBag.LoginError = "Sai thông tin đăng nhập";
                ViewBag.ActiveTab = "login";
                return View();
            }

            Session["USER"] = user;
            return RedirectToAction("Shop", "Product");
        }

        public ActionResult Register()
        {
            return RedirectToAction("Login");
        }

        [HttpPost]
        public ActionResult Register(string FullName, string Email, string Phone, string Password, string ConfirmPassword)
        {
            if (Password != ConfirmPassword)
            {
                ViewBag.RegisterError = "Mật khẩu không khớp";
                ViewBag.ActiveTab = "register";
                return View("Login");
            }

            if (db.Users.Any(u => u.Email == Email))
            {
                ViewBag.RegisterError = "Email đã tồn tại";
                ViewBag.ActiveTab = "register";
                return View("Login");
            }

            if (db.Users.Any(u => u.Phone == Phone))
            {
                ViewBag.RegisterError = "Số điện thoại đã tồn tại";
                ViewBag.ActiveTab = "register";
                return View("Login");
            }

            var user = new User
            {
                FullName = FullName,
                Email = Email,
                Phone = Phone,
                Password = Password,
                Role = "CUSTOMER",
                IsActive = true
            };

            db.Users.Add(user);
            db.SaveChanges();

            TempData["Success"] = "Đăng ký thành công. Vui lòng đăng nhập!";
            return RedirectToAction("Login");
        }

        public ActionResult Logout()
        {
            Session.Remove("USER");
            return RedirectToAction("Shop", "Product");
        }

    }
}