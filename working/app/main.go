package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/hashicorp/app/data"
	"github.com/hashicorp/app/handlers"
	"github.com/hashicorp/app/vault"
	"github.com/hashicorp/go-hclog"
	"github.com/nicholasjackson/config"
	"github.com/nicholasjackson/env"
)

// Config defines a structure which holds individual configuration parameters for the application
type Config struct {
	BindAddress        string `json:"bind_address"`         // address to bind the server to
	VaultAddr          string `json:"vault_addr"`           // address of the vault server
	VaultEncryptionKey string `json:"vault_encryption_key"` // name of the Vault encryption key to use
	DBConnection       string `json:"db_connection"`        // postgres database connection string
	PaymentsAPIKey     string `json:"payments_api_key"`     // static secret for the payments api
}

var configFile = env.String("CONFIG_FILE", false, "./config.json", "Path to JSON encoded config file")
var tlsCert = env.String("TLS_CERT", false, "./tls/cert.pem", "Path to the PEM encoded TLS Certificate")
var tlsKey = env.String("TLS_KEY", false, "./tls/key.pem", "Path to the PEM encoded Private Key")

var log hclog.Logger
var server *http.Server

// global reference for the config
var conf *config.File[*Config]

func main() {
	log = hclog.Default()

	env.Parse()

	// Create a new config watcher
	c, _ := config.New(
		*configFile,
		10*time.Second,
		log.StandardLogger(&hclog.StandardLoggerOptions{}),
		configUpdated,
	)
	defer c.Close()
	conf = c

	writePid()

	// load the Vault token
	//d, err := ioutil.ReadFile(conf.VaultTokenFile)
	//if err != nil {
	//	log.Error("Unable to read Vault token", "error", err)
	//	os.Exit(1)
	//}

	// Create the vault client
	vc := vault.NewClient(conf.Get().VaultAddr, conf.Get().VaultEncryptionKey, "")
	if !vc.IsOK() {
		log.Warn("Unable to connect to Vault server, have you configured the local listener for Vault Agent?")
	}

	// Create the database connection
	db, err := data.New(conf.Get().DBConnection, 60*time.Second)
	if err != nil {
		log.Error("Unable to connect to database", "error", err)
		os.Exit(1)
	}

	//// Create the product handler
	hc := handlers.NewCoffee(db, log)
	hp := handlers.NewPay(vc, log)
	hh := handlers.NewHealth(log)

	http.Handle("/coffee", hc)
	http.Handle("/pay", hp)
	http.Handle("/health", hh)

	go startTLSServer(c.Get())

	waitForSignal()
}

func writePid() {
	pid := os.Getpid()
	pidBytes := []byte(fmt.Sprintf("%d", pid))

	ioutil.WriteFile("./app.pid", pidBytes, os.ModePerm)

	log.Info("Written pid to file", "pid", pid, "file", "./app.pid")
}

func waitForSignal() {
	done := make(chan os.Signal, 1)
	signal.Notify(done, syscall.SIGINT, syscall.SIGTERM, syscall.SIGHUP)
	sig := <-done // Will block here until user hits ctrl+c

	// shutdown the server

	switch sig {
	case syscall.SIGHUP:
		log.Info("Received SIGHUP, reloading")
		configUpdated(conf.Get())
		waitForSignal()
	default:
		shutdownServer()
	}
}

func startTLSServer(conf *Config) {
	log.Info("Starting Server", "bind", conf.BindAddress)

	server = &http.Server{
		Addr: conf.BindAddress,
	}

	// start the server with the provided certificates
	err := server.ListenAndServeTLS(*tlsCert, *tlsKey)
	if err != nil && err != http.ErrServerClosed {
		log.Error("Unable to start server", "error", err)
	}
}

func shutdownServer() {
	log.Info("Stopping Server")

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	server.Shutdown(ctx)
}

func configUpdated(conf *Config) {
	log.Info("Config file updated", "config", conf)
	shutdownServer()

	// restart the server
	go startTLSServer(conf)
}
