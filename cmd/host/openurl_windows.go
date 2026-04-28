//go:build windows
// +build windows

package main

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"unsafe"

	"golang.org/x/sys/windows"
)

const swShowNormal = 1

var shellExecuteW = syscall.NewLazyDLL("shell32.dll").NewProc("ShellExecuteW")

func openURL(uri string) error {
	// Native messaging host is often launched in browser job objects.
	// Start gopeed.exe with breakaway flags to avoid being terminated when browser exits.
	if strings.HasPrefix(strings.ToLower(uri), "gopeed:") {
		return launchGopeed(uri)
	}

	verb, err := syscall.UTF16PtrFromString("open")
	if err != nil {
		return err
	}
	file, err := syscall.UTF16PtrFromString(uri)
	if err != nil {
		return err
	}

	ret, _, callErr := shellExecuteW.Call(
		0,
		uintptr(unsafe.Pointer(verb)),
		uintptr(unsafe.Pointer(file)),
		0,
		0,
		swShowNormal,
	)
	if ret > 32 {
		return nil
	}
	if callErr != syscall.Errno(0) {
		return callErr
	}
	return fmt.Errorf("ShellExecuteW failed: %d", ret)
}

func launchGopeed(uri string) error {
	exe, err := os.Executable()
	if err != nil {
		return err
	}
	gopeedPath := filepath.Join(filepath.Dir(exe), "gopeed.exe")
	if _, err := os.Stat(gopeedPath); err != nil {
		return err
	}

	args := make([]string, 0, 1)
	if strings.Contains(strings.ToLower(uri), "hidden=true") {
		args = append(args, "--hidden")
	}

	cmd := exec.Command(gopeedPath, args...)
	cmd.SysProcAttr = &syscall.SysProcAttr{
		CreationFlags: windows.CREATE_BREAKAWAY_FROM_JOB |
			windows.CREATE_NEW_PROCESS_GROUP |
			windows.DETACHED_PROCESS,
		HideWindow: true,
	}
	if err := cmd.Start(); err != nil {
		return err
	}
	if cmd.Process == nil {
		return errors.New("start gopeed failed: process is nil")
	}
	return cmd.Process.Release()
}
