class AppUser {
  final String firstName;
  final String lastName;
  final String password;
  final String email;
  final String appUserRole;

  const AppUser({required this.firstName, required this.lastName,
    required this.password, required this.email, required this.appUserRole});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return switch(json) {
      {
      "firstName": String firstName,
      "lastName" : String lastName,
      "password": String password,
      "email" : String email,
      "appUserRole" : String appUserRole
      }
      =>
          AppUser(
            firstName: firstName,
            lastName: lastName,
            password: password,
            email: email,
            appUserRole: appUserRole,
          ),
      _ => throw const FormatException('Failed to load user.'),
    };
  }
}