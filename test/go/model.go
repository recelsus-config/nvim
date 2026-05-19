package main

type user_id string

type user_profile struct {
	id    user_id
	name  string
	roles []string
}

type user_directory struct {
	users map[user_id]user_profile
}

func new_user_directory() *user_directory {
	return &user_directory{
		users: make(map[user_id]user_profile),
	}
}

func (directory *user_directory) add_user(profile user_profile) {
	directory.users[profile.id] = profile
}

func (directory *user_directory) find_user(id user_id) (user_profile, bool) {
	profile, ok := directory.users[id]
	return profile, ok
}

func (directory *user_directory) list_admins() []user_profile {
	admins := make([]user_profile, 0)
	for _, user := range directory.users {
		if has_role(user, "admin") {
			admins = append(admins, user)
		}
	}
	return admins
}

func has_role(profile user_profile, role string) bool {
	for _, current := range profile.roles {
		if current == role {
			return true
		}
	}
	return false
}
