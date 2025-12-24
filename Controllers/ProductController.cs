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
        
    }
}