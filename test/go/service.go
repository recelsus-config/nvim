package main

import (
	"fmt"
	"strings"
)

func create_directory(seed_users []user_profile) *user_directory {
	directory := new_user_directory()
	for _, user := range seed_users {
		directory.add_user(user)
	}
	return directory
}

func format_user_label(user user_profile) string {
	return fmt.Sprintf("%s (%s)", user.name, strings.Join(user.roles, ", "))
}

func require_user(directory *user_directory, id user_id) (user_profile, error) {
	user, ok := directory.find_user(id)
	if !ok {
		return user_profile{}, fmt.Errorf("user not found: %s", id)
	}
	return user, nil
}
