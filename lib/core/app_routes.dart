import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import '../views/home/all_products_page.dart';
import '../views/home/contact_page.dart';
import '../views/home/product_detail_page.dart';
import '../views/home/services_page.dart';
import '../views/order/order_page.dart';
import '../views/profile/about_page.dart';
import '../views/profile/address_page.dart';
import '../views/profile/faq_page.dart';
import '../views/profile/notification_page.dart';
import '../views/profile/payment_method_page.dart';
import '../views/profile/profile_page.dart';
import '../views/profile/security_page.dart';
import '../views/shopping/cart_page.dart';
import '../views/shopping/checkout_page.dart';
import '../views/shopping/wishlist_page.dart';

class AppRoutes {
  AppRoutes._();

  static String? restorePath;

  static const cart = '/cart';
  static const wishlist = '/wishlist';
  static const checkout = '/checkout';
  static const orders = '/orders';
  static const contact = '/contact';
  static const services = '/services';
  static const about = '/about';
  static const profile = '/profile';
  static const security = '/profile/security';
  static const notifications = '/profile/notifications';
  static const address = '/profile/address';
  static const payment = '/profile/payment';
  static const faq = '/profile/faq';

  static String allProducts(AllProductsMode mode) => '/products/${mode.name}';

  static String product(Product p) =>
      '/product/${Uri.encodeComponent(p.name)}';

  static Widget? _pageFor(String routeName) {
    final uri = Uri.parse(routeName);
    final seg = uri.pathSegments;

    switch (uri.path) {
      case cart:
        return const CartPage();
      case wishlist:
        return const WishlistPage();
      case checkout:
        return const CheckoutPage();
      case orders:
        return const OrderPage();
      case contact:
        return const ContactPage();
      case services:
        return const ServicesPage();
      case about:
        return const AboutPage();
      case security:
        return const SecurityPage();
      case notifications:
        return const NotificationPage();
      case address:
        return const AddressPage();
      case payment:
        return const PaymentMethodPage();
      case faq:
        return const FaqPage();
      case profile:
        final user = AuthController.firebaseUser;
        return ProfilePage(
          name: AuthController.currentName ??
              user?.displayName ??
              'Pengguna SOLEA',
          email: AuthController.currentEmail ?? user?.email ?? '',
        );
    }

    if (seg.length == 2 && seg[0] == 'products') {
      for (final mode in AllProductsMode.values) {
        if (mode.name == seg[1]) return AllProductsPage(mode: mode);
      }
    }

    if (seg.length == 2 && seg[0] == 'product') {
      for (final p in ProductController.products) {
        if (p.name == seg[1]) return ProductDetailPage(product: p);
      }
    }

    return null;
  }

  static bool isKnown(String routeName) => _pageFor(routeName) != null;

  static List<String> stackFor(String path) {
    if (path.startsWith('$profile/')) return [profile, path];
    return [path];
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final page = _pageFor(settings.name ?? '/');
    if (page == null) return null;

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => page,
    );
  }
}