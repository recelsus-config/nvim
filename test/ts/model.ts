export type user_id = string;

export interface user_profile {
  id: user_id;
  name: string;
  roles: string[];
}

export class user_directory {
  private readonly users = new Map<user_id, user_profile>();

  add_user(profile: user_profile): void {
    this.users.set(profile.id, profile);
  }

  find_user(id: user_id): user_profile | undefined {
    return this.users.get(id);
  }

  list_admins(): user_profile[] {
    return Array.from(this.users.values()).filter((user) =>
      user.roles.includes("admin"),
    );
  }
}
