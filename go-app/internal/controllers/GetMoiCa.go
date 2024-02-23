package controllers

import (
	"net/http"
	
)

func GetMoiCa(w http.ResponseWriter, r *http.Request) {

	_, _ = w.Write([]byte("Le serveur a bien démarré."))
}
