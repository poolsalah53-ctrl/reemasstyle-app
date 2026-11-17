[11/17/2026 11:06 PM] Salah Joudeh: إليك كل ما يلزم لتجهيز المشروع عملياً وربطه بالكامل عبر GitHub: كود تطبيق الهاتف المكتمل، كود لوحة التحكم، وسكربت قاعدة بيانات Supabase.

سيكون لدينا مستودعان على GitHub أو مجلدان رئيسيان: واحد لتطبيق الهاتف ومعه إعداد البناء السحابي لـ APK، والآخر للوحة التحكم والمتجر لرفعه بضغطة زر على Vercel.

---

### أولاً: كود قاعدة البيانات (Supabase SQL)

قم بفتح حساب مجاني على موقع supabase.com، وأنشئ مشروعاً جديداً باسم reemasstyle، ثم ادخل على تبويب SQL Editor، والصق هذا السكربت واضغط Run لتجهيز الجداول والصلاحيات فوراً:

-- جدول الأقسام
CREATE TABLE categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول المنتجات
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  price NUMERIC(10, 2) NOT NULL,
  old_price NUMERIC(10, 2),
  images TEXT[] NOT NULL DEFAULT '{}',
  is_featured BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول المقاسات والألوان والمخزون
CREATE TABLE product_variants (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  color VARCHAR(50) NOT NULL,
  size VARCHAR(20) NOT NULL,
  stock INT NOT NULL DEFAULT 0
);

-- جدول الطلبات
CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_number VARCHAR(50) UNIQUE NOT NULL,
  customer_name VARCHAR(150) NOT NULL,
  phone VARCHAR(30) NOT NULL,
  city VARCHAR(100) NOT NULL,
  address TEXT NOT NULL,
  total_amount NUMERIC(10, 2) NOT NULL,
  delivery_fee NUMERIC(10, 2) DEFAULT 0,
  payment_method VARCHAR(50) DEFAULT 'COD',
  status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول عناصر الطلب
CREATE TABLE order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  product_title VARCHAR(200) NOT NULL,
  selected_size VARCHAR(20),
  selected_color VARCHAR(50),
  price NUMERIC(10, 2) NOT NULL,
  quantity INT NOT NULL DEFAULT 1
);

-- بيانات تجريبية أولية لمتجر Reemasstyle
INSERT INTO categories (name, image_url) VALUES
('عبايات فاخرة', 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600'),
('فساتين سهرة', 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600'),
('أطقم رسمية', 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600');

INSERT INTO products (title, description, price, old_price, images) VALUES
('فستان سهرة حريري ريماس', 'فستان نسائي راقٍ مصنوع من الحرير الناعم بلون عاجي جذاب، مناسب للمناسبات الخاصة.', 450.00, 550.00, ARRAY['https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800']),
('عباية مخملية بتطريز ذهبي', 'عباية سوداء محتشمة بتطريز يدوي على الأكمام، تصميم عصري وخامة ممتازة.', 380.00, 420.00, ARRAY['https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800']),
('طقم رسمي أنيق قطعتين', 'طقم نسائي كلاسيكي للمناسبات الرسمية والعمل بجودة عالية وتقفيل ممتاز.', 520.00, 600.00, ARRAY['https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800']);
---

### ثانياً: كود تطبيق الهاتف المكتمل (Flutter)

داخل مستودع reemasstyle-app على GitHub:

#### 1. ملف pubspec.yaml
name: reemasstyle
description: "تطبيق متجر ريماس ستايل للأزياء النسائية"
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0
  cached_network_image: ^3.3.1
  url_launcher: ^6.2.5

flutter:
  uses-material-design: true
#### 2. ملف lib/main.dart (يحتوي على الواجهة، تفاصيل المنتج، اختيار المقاس، السلة، وإتمام الطلب عبر واتساب)
`dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const ReemasStyleApp());
}

class ReemasStyleApp extends StatelessWidget {
  const ReemasStyleApp({super.key});
[11/17/2026 11:06 PM] Salah Joudeh: @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reemasstyle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFBF9F6),
        primaryColor: const Color(0xFFD8A48F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD8A48F),
          primary: const Color(0xFF1A1A1A),
          secondary: const Color(0xFFC5A880),
        ),
        textTheme: GoogleFonts.cairoTextTheme(),
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final double oldPrice;
  final String image;
  final List<String> sizes;
  final List<String> colors;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.image,
    required this.sizes,
    required this.colors,
  });
}

final List<Product> sampleProducts = [
  Product(
    id: '1',
    title: 'فستان سهرة حريري ريماس',
    description: 'فستان نسائي راقٍ مصنوع من أجود أنواع الحرير الناعم، يجمع بين الفخامة والاحتشام ليمنحك إطلالة ساحرة في مناسباتك الخاصة.',
    price: 450,
    oldPrice: 550,
    image: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800',
    sizes: ['S', 'M', 'L', 'XL'],
    colors: ['عاجي', 'وردي مترب', 'أسود'],
  ),
  Product(
    id: '2',
    title: 'عباية مخملية بتطريز ذهبي',
    description: 'عباية كلاسيكية فاخرة بقماش مخملي كوري مع تطريز خيوط ذهبية على الأكمام والأطراف، تأتي مع طرحة متناسقة.',
    price: 380,
    oldPrice: 420,
    image: 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800',
    sizes: ['52', '54', '56', '58'],
    colors: ['أسود ملكي', 'كحلي دافئ'],
  ),
  Product(
    id: '3',
    title: 'طقم رسمي أنيق قطعتين',
    description: 'طقم متناسق يتكون من بليزر طويل وبنطال بقصة واسعة ومريحة، ملائم للعمل والزيارات الرسمية.',
    price: 520,
    oldPrice: 600,
    image: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800',
    sizes: ['M', 'L', 'XL'],
    colors: ['بيج', 'رمادي فاتح'],
  ),
];

class CartItem {
  final Product product;
  final String size;
  final String color;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.color,
    this.quantity = 1,
  });
}

List<CartItem> userCart = [];

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onOpenCart: () => setState(() => _currentIndex = 1)),
      CartScreen(onCheckoutSuccess: () => setState(() => _currentIndex = 0)),
      const Center(child: Text('خدمة العملاء والتواصل: 0500000000')),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF1A1A1A),
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: userCart.isNotEmpty,
              label: Text('${userCart.length}'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            label: 'السلة',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.headset_mic_outlined), label: 'المساعدة'),
        ],
      ),
    );
  }
}
[11/17/2026 11:06 PM] Salah Joudeh: class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenCart;
  const HomeScreen({super.key, required this.onOpenCart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Reemasstyle',
          style: GoogleFonts.cairo(color: const Color(0xFF1A1A1A), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF1A1A1A)),
            onPressed: onOpenCart,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFD8A48F), Color(0xFFC5A880)]),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('تألقي مع تشكيلة Reemasstyle', style: GoogleFonts.cairo(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('أزياء نسائية فاخرة بخصومات تصل إلى 30%', style: GoogleFonts.tajawal(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('وصل حديثاً', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sampleProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final product = sampleProducts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(product.image, fit: BoxFit.cover, width: double.infinity),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
[11/17/2026 11:06 PM] Salah Joudeh: Text('${product.price} ر.س', style: GoogleFonts.tajawal(color: const Color(0xFFD8A48F), fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(width: 6),
                                Text('${product.oldPrice}', style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 11, decoration: TextDecoration.lineThrough)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late String selectedSize;
  late String selectedColor;

  @override
  void initState() {
    super.initState();
    selectedSize = widget.product.sizes.first;
    selectedColor = widget.product.colors.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title, style: GoogleFonts.cairo(color: Colors.black, fontSize: 15)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(widget.product.image, height: 350, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text(widget.product.title, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${widget.product.price} ر.س', style: GoogleFonts.tajawal(fontSize: 18, color: const Color(0xFFD8A48F), fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('المقاس:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: widget.product.sizes.map((s) {
              final isSelected = s == selectedSize;
              return ChoiceChip(
                label: Text(s),
                selected: isSelected,
                onSelected: (_) => setState(() => selectedSize = s),
                selectedColor: const Color(0xFF1A1A1A),
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('اللون:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: widget.product.colors.map((c) {
              final isSelected = c == selectedColor;
              return ChoiceChip(
                label: Text(c),
                selected: isSelected,
                onSelected: (_) => setState(() => selectedColor = c),
                selectedColor: const Color(0xFFD8A48F),
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('الوصف:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(widget.product.description, style: GoogleFonts.tajawal(color: Colors.grey[700], height: 1.5)),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
[11/17/2026 11:06 PM] Salah Joudeh: decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            userCart.add(CartItem(product: widget.product, size: selectedSize, color: selectedColor));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة إلى السلة بنجاح')));
            Navigator.pop(context);
          },
          child: Text('إضافة إلى السلة', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  final VoidCallback onCheckoutSuccess;
  const CartScreen({super.key, required this.onCheckoutSuccess});

  @override
  Widget build(BuildContext context) {
    double total = userCart.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

    if (userCart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text('سلة المشتريات فارغة حالياً', style: GoogleFonts.cairo(fontSize: 16)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('سلة المشتريات'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0.5),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: userCart.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) {
          final item = userCart[i];
          return ListTile(
            leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.product.image, width: 50, height: 60, fit: BoxFit.cover)),
            title: Text(item.product.title, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Text('المقاس: ${item.size} | اللون: ${item.color}\n${item.product.price} ر.س', style: GoogleFonts.tajawal(fontSize: 12)),
            trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => (context as Element).markNeedsBuild()),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الإجمالي:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('$total ر.س', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFFD8A48F))),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A1A), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  final text = 'مرحباً، أود تأكيد طلبي من Reemasstyle:\n' + userCart.map((e) => '- ${e.product.title} (مقاس: ${e.size}, لون: ${e.color})').join('\n') + '\nالإجمالي: $total ر.س';
                  launchUrl(Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}'), mode: LaunchMode.externalApplication);
[11/17/2026 11:06 PM] Salah Joudeh: userCart.clear();
                  onCheckoutSuccess();
                },
                child: Text('إتمام الطلب عبر واتساب (الدفع عند الاستلام)', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
`
