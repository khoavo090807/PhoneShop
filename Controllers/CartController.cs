using LTW_NHOM8.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LTW_NHOM8.Controllers
{
    public class CartController : Controller
    {
        private DB_LTWEntities db = new DB_LTWEntities();
        private const string CART_SESSION = "Cart";

        // HÀM LẤY GIỎ HÀNG: Tự lấy UserId từ Session["USER"]
        private List<CartItem> GetCart()
        {
            // Ép kiểu Session["USER"] về object User (khớp với UserController)
            var user = Session["USER"] as LTW_NHOM8.Models.User;
            if (user == null) return new List<CartItem>();

            // Mỗi User có một giỏ hàng riêng dựa trên UserId
            string cartKey = CART_SESSION + "_" + user.UserId;
            var cart = Session[cartKey] as List<CartItem>;
            if (cart == null)
            {
                cart = new List<CartItem>();
                Session[cartKey] = cart;
            }
            return cart;
        }

        // GET: /Cart
        public ActionResult Index()
        {
            if (Session["USER"] == null)
            {
                return RedirectToAction("Login", "User");
            }
            var cart = GetCart();
            return View(cart);
        }

        // POST: /Cart/AddToCart
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult AddToCart(int productId, int quantity = 1)
        {
            // 1. Kiểm tra đăng nhập
            if (Session["USER"] == null)
            {
                return RedirectToAction("Login", "User");
            }

            if (quantity < 1) quantity = 1;

            // 2. Kiểm tra sản phẩm có tồn tại không
            var product = db.Products
                .Include(p => p.Categories)
                .FirstOrDefault(p => p.ProductId == productId && p.IsActive == true);

            if (product == null) return HttpNotFound();

            // 3. Lấy giỏ hàng của User này và thêm sản phẩm
            var cart = GetCart();
            var existing = cart.FirstOrDefault(x => x.ProductId == productId);

            if (existing != null)
            {
                existing.Quantity += quantity;
            }
            else
            {
                var catName = product.Categories != null && product.Categories.Any()
                    ? string.Join(" / ", product.Categories.Select(c => c.CategoryName))
                    : "";

                cart.Add(new CartItem
                {
                    ProductId = product.ProductId,
                    ProductName = product.ProductName,
                    Image = product.MainImage,
                    Price = product.Price,
                    Quantity = quantity,
                    CategoryName = catName
                });
            }

            return RedirectToAction("Index");
        }

        // POST: /Cart/UpdateQuantity
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult UpdateQuantity(int productId, int quantity)
        {
            if (Session["USER"] != null)
            {
                var cart = GetCart();
                var item = cart.FirstOrDefault(x => x.ProductId == productId);
                if (item != null)
                {
                    if (quantity <= 0) cart.Remove(item);
                    else item.Quantity = quantity;
                }
            }
            return RedirectToAction("Index");
        }

        // GET: /Cart/Remove
        public ActionResult Remove(int productId)
        {
            if (Session["USER"] != null)
            {
                var cart = GetCart();
                var item = cart.FirstOrDefault(x => x.ProductId == productId);
                if (item != null) cart.Remove(item);
            }
            return RedirectToAction("Index");
        }

        public ActionResult Clear()
        {
            var user = Session["USER"] as LTW_NHOM8.Models.User;
            if (user != null)
            {
                Session.Remove(CART_SESSION + "_" + user.UserId);
            }
            return RedirectToAction("Index");
        }
    }
}