import { create_directory, format_user_label, require_user } from "./service";
import type { user_profile } from "./model";

const seed_users: user_profile[] = [
  { id: "u-001", name: "Ada", roles: ["admin", "developer"] },
  { id: "u-002", name: "Grace", roles: ["developer"] },
  { id: "u-003", name: "Linus", roles: ["reviewer"] },
];

const directory = create_directory(seed_users);
const selected = require_user(directory, "u-001");

console.log(format_user_label(selected));

for (const admin of directory.list_admins()) {
  console.log(`admin: ${format_user_label(admin)}`);
}
