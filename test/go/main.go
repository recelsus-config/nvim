package main

import (
	"fmt"
	"log"
)

func main() {
	seed_users := []user_profile{
		{id: "u-001", name: "Ada", roles: []string{"admin", "developer"}},
		{id: "u-002", name: "Grace", roles: []string{"developer"}},
		{id: "u-003", name: "Linus", roles: []string{"reviewer"}},
	}

	directory := create_directory(seed_users)
	selected, err := require_user(directory, "u-001")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(format_user_label(selected))
	for _, admin := range directory.list_admins() {
		fmt.Printf("admin: %s\n", format_user_label(admin))
	}
}
