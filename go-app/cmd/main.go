package main

import (
	"github.com/gorilla/mux"
	"github.com/sirupsen/logrus"
	"net/http"
	"serveur/internal/controllers"
	"strconv"
)

func main() {
	logrus.Infoln("Starting server...")

	m := mux.NewRouter()

	router := m.PathPrefix("/").Subrouter()

	router.HandleFunc("/", controllers.GetMoiCa).Methods(http.MethodGet, http.MethodOptions)
	logrus.Info("Web server started. Now listening on *:8000")
	logrus.Fatalln(http.ListenAndServe(":"+strconv.Itoa(8000), m))
}
