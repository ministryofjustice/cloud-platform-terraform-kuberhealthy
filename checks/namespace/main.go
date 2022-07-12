package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"time"

	log "github.com/sirupsen/logrus"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	"github.com/kuberhealthy/kuberhealthy/v2/pkg/checks/external/checkclient"
	kh "github.com/kuberhealthy/kuberhealthy/v2/pkg/checks/external/checkclient"
	"github.com/kuberhealthy/kuberhealthy/v2/pkg/kubeClient"
	"k8s.io/client-go/kubernetes"
)

var (
	// K8s client used for the check.
	client *kubernetes.Clientset
	// K8s config file for the client.
	kubeConfigFile = filepath.Join(os.Getenv("HOME"), ".kube", "config")
	// We have to explicitly list of namespaces that we want to look for

	ctx       context.Context
	ctxCancel context.CancelFunc

	debugEnv = os.Getenv("DEBUG")
	debug    bool

	namespaces = []string{
		"cert-manager",
		"default",
		"ingress-controllers",
		"kube-system",
		"logging",
		"monitoring",
		"opa",
		"velero",
	}
)

func main() {
	// create context
	ctx, ctxCancel = context.WithTimeout(context.Background(), time.Duration(time.Minute*5))

	// Create a kubernetes client.
	var err error
	client, err = kubeClient.Create(kubeConfigFile)
	if err != nil {
		errorMessage := "failed to create a kubernetes client with error: " + err.Error()
		reportErr := kh.ReportFailure([]string{errorMessage})
		if reportErr != nil {
			log.Fatalln("error reporting failure to kuberhealthy:", reportErr.Error())
		}
		return
	}
	log.Infoln("Kubernetes client created.")

	ok, err := namespaceExist(ctx)
	if err != nil {
		log.Fatalln("Namespace check failed:", err)
	}

	if !ok {
		checkclient.ReportFailure([]string{"Namespace check failed"})
		return
	}
	checkclient.ReportSuccess()
}

func namespaceExist(ctx context.Context) (bool, error) {

	var notFoundNamespaces []string
	//range over namespaces and check if exists
	for _, ns := range namespaces {
		_, err := client.CoreV1().Namespaces().Get(ctx, ns, metav1.GetOptions{})
		if err != nil {
			notFoundNamespaces = append(notFoundNamespaces, ns)
		}
	}
	// If the notFoundNamespaces collection contains a namespace entry, then the check has to fail.
	if notFoundNamespaces != nil {
		return false, fmt.Errorf("Namespaces %s not found", notFoundNamespaces)
	}
	return true, nil
}
