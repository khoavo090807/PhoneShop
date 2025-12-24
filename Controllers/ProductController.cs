using LTW_NHOM8.Models;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using System.Data.Entity;
namespace LTW_NHOM8.Controllers
{
    public class ProductController : Controller
    {
        private DB_LTWEntities db = new DB_LTWEntities();

        // GET: Product
        public ActionResult Index()
        {
            return View();
        }
        public ActionResult Shop(string q, string price, int? categoryId, int page = 1)
        {
            const int pageSize = 9;
            if (page < 1) page = 1;

            var products = db.Products.Where(p => p.IsActive == true).AsQueryable();

            // search
            if (!string.IsNullOrWhiteSpace(q))
            {
                q = q.Trim();
                products = products.Where(p => p.ProductName.Contains(q) || p.SKU.Contains(q));
            }

            // price
            if (!string.IsNullOrWhiteSpace(price))
            {
                var arr = price.Split('-');
                if (arr.Length == 2
                    && long.TryParse(arr[0], out long min)
                    && long.TryParse(arr[1], out long max))
                {
                    products = products.Where(p => p.Price >= min && p.Price <= max);
                }
            }

            // category
            if (categoryId.HasValue)
            {
                int cid = categoryId.Value;
                products = products.Where(p => p.Categories.Any(c => c.CategoryId == cid));
            }

            var totalItems = products.Count();
            var totalPages = (int)Math.Ceiling((double)totalItems / pageSize);

            var data = products
                .OrderByDescending(p => p.ProductId)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToList();

            ViewBag.Page = page;
            ViewBag.TotalPages = totalPages;
            ViewBag.TotalItems = totalItems;

            // để view build link giữ filter
            ViewBag.Q = q;
            ViewBag.Price = price;
            ViewBag.CategoryId = categoryId;

            return View(data);
        }
        public ActionResult Details(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }

            // include ProductImages and Category -> CategoryGroup (để xác định hãng)
            var product = db.Products
                .Include(p => p.ProductImages)
                .Include(p => p.Categories.Select(c => c.CategoryGroup))
                .FirstOrDefault(p => p.ProductId == id && p.IsActive == true);

            if (product == null)
            {
                return HttpNotFound();
            }

            // Tìm category thuộc nhóm "Hãng" của product (ưu tiên GroupCode == "brand" hoặc GroupName chứa "Hãng"/"Brand")
            var brandCategoryIds = product.Categories
                .Where(c => c.CategoryGroup != null &&
                           (
                               (c.CategoryGroup.GroupCode != null && c.CategoryGroup.GroupCode.Equals("brand", StringComparison.OrdinalIgnoreCase))
                               || (c.CategoryGroup.GroupName != null && (c.CategoryGroup.GroupName.IndexOf("hãng", StringComparison.OrdinalIgnoreCase) >= 0 || c.CategoryGroup.GroupName.IndexOf("brand", StringComparison.OrdinalIgnoreCase) >= 0))
                           ))
                .Select(c => c.CategoryId)
                .ToList();

            // Nếu không tìm được category thuộc nhóm Hãng, fallback lấy tất cả category của product
            if (!brandCategoryIds.Any())
            {
                brandCategoryIds = product.Categories.Select(c => c.CategoryId).ToList();
            }

            // Lấy products liên quan theo cùng hãng (cùng category trong brandCategoryIds), exclude current
            var related = db.Products
                .Include(p => p.ProductImages)
                .Include(p => p.Categories)
                .Where(p => p.IsActive == true
                            && p.ProductId != product.ProductId
                            && p.Categories.Any(c => brandCategoryIds.Contains(c.CategoryId)))
                .OrderByDescending(p => p.ProductId)
                .Take(8)
                .ToList();

            ViewBag.RelatedProducts = related;

            return View(product);
        }
    }
}