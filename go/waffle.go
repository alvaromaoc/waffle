package main

import (
	"fmt"
	"time"
	"os/exec"
	"os"
)

var SelfCertificateDays int = 90

func executeCommand(command string, arguments ...string): error {
	cmd := exec.Command(command, arguments...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}

func quoted(element string) string {
	return "\"" + element + "\""
}

func simpleJson(elements ...string) string {
	json := ""
	for i := 1; i < len(elements); i += 2 {
		if len(json) != 0 {
			json += ", "
		}
		json += quoted(elements[i-1]) + ": " + quoted(elements[i])
    }
	return "{" + json + "}"
}

func log(level string, message string) {
	fmt.Println(simpleJson("datetime", time.Now().Format("2006-01-02 15:04:05"), "level", level, "message", message))
}

func generateSelfSignedCertificate(domain string) {
	log("INFO", "Issuing self signed SSL certificate for " + domain)
	certPath := "/etc/letsencrypt/live/" + domain
	if err := executeCommand("mkdir", "-p", certPath); err != nil {
		log("ERROR", "Error creating certificate directory for " + domain)
		return
	}
	if err := executeCommand("openssl", "req", "-x509", "-newkey", "rsa:2048", "-keyout", certPath + "/privkey.pem", "-out", certPath + "/fullchain.pem", "-sha256", "-days", SelfCertificateDays, "-nodes", "-subj", "/CN=" + domain); err != nil {
		log("ERROR", "Error generating self signed certificate for " + domain)
		return
	}
	if err := executeCommand("touch", certPath + "/self-signed.txt"); err != nil {
		log("ERROR", "Error creating self signed evidence for " + domain)
		return
	}
	if err := executeCommand("chmod", "+r", certPath + "/*"); err != nil {
		log("ERROR", "Error giving permissions for certificate for " + domain)
		return
	}
	log("INFO", "Generated self-signed certificate for " + domain)
}

func main() {
    log("ERROR", "Hello!")
}