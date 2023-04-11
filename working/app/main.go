package main

import (
	"context"
	"crypto/tls"
	"encoding/base64"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/hashicorp/app/handlers"
	"github.com/hashicorp/go-hclog"
	"github.com/nicholasjackson/config"
	"github.com/nicholasjackson/env"
)

// Config defines a structure which holds individual configuration parameters for the application
type Config struct {
	DBConnection   string `json:"db_connection"`
	BindAddress    string `json:"bind_address"`
	TLSCert        string `json:"tls_cert"`
	TLSKey         string `json:"tls_key"`
	VaultAddr      string `json:"vault_addr"`
	VaultTokenFile string `json:"vault_token_file"`
	PaymentsAPIKey string `json:"payments_api_key"`
}

var configFile = env.String("CONFIG_FILE", false, "./config.json", "Path to JSON encoded config file")
var log hclog.Logger
var server *http.Server

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

	// load the Vault token
	//d, err := ioutil.ReadFile(conf.VaultTokenFile)
	//if err != nil {
	//	log.Error("Unable to read Vault token", "error", err)
	//	os.Exit(1)
	//}

	// Create the vault client
	//vc := vault.NewClient(conf.VaultAddr, string(d))
	//if !vc.IsOK() {
	//	log.Error("Unable to connect to Vault server")
	//	os.Exit(1)
	//}

	// Create the database connection
	//db, err := data.New(conf.DBConnection, 60*time.Second)
	//if err != nil {
	//	log.Error("Unable to connect to database", "error", err)
	//	os.Exit(1)
	//}

	//// Create the product handler
	//hc := handlers.NewCoffee(db, log)
	//hp := handlers.NewPay(vc, log)
	hh := handlers.NewHealth(log)

	//http.Handle("/", hc)
	//http.Handle("/pay", hp)
	http.Handle("/health", hh)

	go startTLSServer(c.Get())

	done := make(chan os.Signal, 1)
	signal.Notify(done, syscall.SIGINT, syscall.SIGTERM)
	<-done // Will block here until user hits ctrl+c

	shutdownServer()
}

func startTLSServer(conf *Config) {
	log.Info("Starting Server", "bind", conf.BindAddress)

	certByte, _ := base64.StdEncoding.DecodeString(conf.TLSCert)
	keyByte, _ := base64.StdEncoding.DecodeString(conf.TLSKey)

	cert, _ := tls.X509KeyPair(certByte, keyByte)

	cfg := &tls.Config{Certificates: []tls.Certificate{cert}}

	server = &http.Server{
		Addr:      conf.BindAddress,
		TLSConfig: cfg,
	}

	err := server.ListenAndServeTLS("", "")
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
