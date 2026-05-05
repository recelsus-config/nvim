import { user_directory, type user_id, type user_profile } from "./model";

export function create_directory(seed_users: user_profile[]): user_directory {
  const directory = new user_directory();

  for (const user of seed_users) {
    directory.add_user(user);
  }

  return directory;
}

export function format_user_label(user: user_profile): string {
  return `${user.name} (${user.roles.join(", ")})`;
}

export function require_user(directory: user_directory, id: user_id): user_profile {
  const user = directory.find_user(id);
  if (!user) {
    throw new Error(`User not found: ${id}`);
  }
  return user;
}
