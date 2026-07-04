/// Route guards for authentication and onboarding checks.
library;

import 'package:flutter/material.dart';
import 'package:rug/routes/route_names.dart';

/// Checks if the user is authenticated before allowing navigation.
///
/// Returns the redirect path if not authenticated, null otherwise.
String? authGuard(BuildContext context, {required bool isAuthenticated}) {
  if (!isAuthenticated) {
    return RouteNames.auth;
  }
  return null;
}

/// Prevents authenticated users from accessing auth screens.
///
/// Redirects to home if already logged in.
String? noAuthGuard(BuildContext context, {required bool isAuthenticated}) {
  if (isAuthenticated) {
    return RouteNames.home;
  }
  return null;
}
