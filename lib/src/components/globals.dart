library globals;

import '../../supabase_auth_ui.dart';

bool updatePassword = false;

final currentUser = Supabase.instance.client.auth.currentUser;