using LTW_NHOM8.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LTW_NHOM8.Controllers
{
    public class CategoryController : Controller
    {
        private DB_LTWEntities db = new DB_LTWEntities();

        [ChildActionOnly]
        public PartialViewResult MenuVertical()
        {
            var groups = db.CategoryGroups
                .Include("Categories")
                .Where(g => g.IsActive == true)
                .OrderBy(g => g.SortOrder)
                .ToList();

            foreach (var g in groups)
            {
                g.Categories = g.Categories
                    .Where(c => c.IsActive == true)
                    .OrderBy(c => c.SortOrder)
                    .ToList();
            }

            return PartialView("_MenuVertical", groups);
        }
    }
}