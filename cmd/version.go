package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
)

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print current helm-kubelinter version",
	Long:  `Print current helm-kubelinter version`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("version:", "0.1.0-dev")
	},
}

func init() {
	rootCmd.AddCommand(versionCmd)
}
