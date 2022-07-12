package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"time"

	log "github.com/sirupsen/logrus"
	"k8s.io/client-go/kubernetes"

	"github.com/kuberhealthy/kuberhealthy/v2/pkg/checks/external/checkclient"
	kh "github.com/kuberhealthy/kuberhealthy/v2/pkg/checks/external/checkclient"
	"github.com/kuberhealthy/kuberhealthy/v2/pkg/kubeClient"
	apierrors "k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

var (
	client *kubernetes.Clientset

	// K8s config file for the client.
	KubeConfigFile = filepath.Join(os.Getenv("HOME"), ".kube", "config")
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

func init() {
	checkclient.Debug = true
}

type Options struct {
	client kubernetes.Interface
}

func main() {
	// create context
	ctx, ctxCancel = context.WithTimeout(context.Background(), time.Duration(time.Minute*5))

	// Create a kubernetes client.
	var err error
	o := Options{}
	o.client, err = kubeClient.Create(KubeConfigFile)
	if err != nil {
		errorMessage := "failed to create a kubernetes client with error: " + err.Error()
		reportErr := kh.ReportFailure([]string{errorMessage})
		if reportErr != nil {
			log.Fatalln("error reporting failure to kuberhealthy:", reportErr.Error())
		}
		return
	}
	log.Infoln("Kubernetes client created.")

	ok, err := o.namespaceExist(ctx)
	if err != nil {
		log.Fatalln("Namespace check failed:", err)
	}

	if !ok {
		checkclient.ReportFailure([]string{"Namespace check failed"})
		return
	}
	checkclient.ReportSuccess()
}

func (o Options) namespaceExist(ctx context.Context) (bool, error) {
	var notFoundNamespaces []string
	// range over namespaces and check if exists
	for _, ns := range namespaces {
		_, err := o.client.CoreV1().Namespaces().Get(ctx, ns, metav1.GetOptions{})
		if apierrors.IsNotFound(err) {
			notFoundNamespaces = append(notFoundNamespaces, ns)
		} else if err != nil {
			log.Infoln("Getting namespace from cluster failed:", err)
			return false, fmt.Errorf("failed getting namespace %s from cluster", ns)
		}
	}
	// If the notFoundNamespaces collection contains a namespace entry, then the check has to fail.
	if notFoundNamespaces != nil {
		return false, fmt.Errorf("namespaces %s not found", notFoundNamespaces)
	}
	return true, nil
}
