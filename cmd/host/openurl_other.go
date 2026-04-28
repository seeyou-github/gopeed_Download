//go:build !windows
// +build !windows

package main

import "github.com/pkg/browser"

func openURL(uri string) error {
	return browser.OpenURL(uri)
}
