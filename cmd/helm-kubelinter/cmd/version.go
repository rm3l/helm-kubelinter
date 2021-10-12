package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var (
	version = "dev"
	commit  string
	date    string
)

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "print current helm-kubelinter version",
	Long:  ``,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("version: ", version)
		fmt.Println("commit: ", commit)
		fmt.Println("date: ", date)
	},
}

func init() {
	rootCmd.AddCommand(versionCmd)
}
