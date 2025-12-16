import 'package:go_router/go_router.dart';
import 'package:staffora/presentation/auth/views/forgot_password.dart';
import 'package:staffora/presentation/auth/views/login_screen.dart';
import 'package:staffora/presentation/auth/views/register_screen.dart';
import 'package:staffora/presentation/dashboard/views/dashboard_screen.dart';
import 'package:staffora/presentation/leave/views/apply_leave.dart';
import 'package:staffora/presentation/product/views/create_product_view.dart';
import 'package:staffora/presentation/users/views/getall_users_view.dart';
import 'package:staffora/presentation/department/views/department_management.dart';
import '../../presentation/product/views/product_success_view.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: "/auth/login",
    routes: [
      GoRoute(
        path: "/auth/create_account",
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: "/auth/login",
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: "/auth/forgot",
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
          path: "/product/create",
          builder: (context, state) => const CreateProductView()),
      GoRoute(
        path: "/product/success",
        builder: (context, state) => const ProductSuccessView(),
      ),
      GoRoute(
        path: "/users/allusers",
        builder: (context, state) => GetAllUsersView(),
      ),
      GoRoute(
        path: "/profile/user",
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: "/leave/apply",
        builder: (context, state) => ApplyLeaveForm(),
      ),
      GoRoute(
        path: "/department/management",
        builder: (context, state) => const DepartmentManagementScreen(),
      ),
    ],
  );
}
