using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LTW_NHOM8.Models
{
    [Serializable]
    public class CartItem
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        // lưu tên file ảnh (ví dụ "abc.jpg") hoặc đường dẫn; view sẽ resolve tới ~/Content/img/main/ nếu cần
        public string Image { get; set; }
        public decimal Price { get; set; }
        public int Quantity { get; set; }
        // hiển thị category (ví dụ "Dip / Sinh nhật")
        public string CategoryName { get; set; }

        public decimal Total => Price * Quantity;
    }
}


