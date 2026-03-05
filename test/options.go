/*
Copyright 2023 The Radius Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package test

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"
	"k8s.io/client-go/dynamic"
	k8s "k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"sigs.k8s.io/controller-runtime/pkg/client"

	"github.com/radius-project/radius/pkg/cli"
	"github.com/radius-project/radius/pkg/cli/kubernetes"
)

type TestOptions struct {
	ConfigFilePath string
	K8sClient      *k8s.Clientset
	K8sConfig      *rest.Config
	DynamicClient  dynamic.Interface
	Client         client.WithWatch
}

// TryNewTestOptions creates a TestOptions struct with the necessary clients and
// configs for testing. It returns an error instead of calling t.FailNow(), making
// it safe to call from goroutines or retry loops where t.FailNow() would cause a
// runtime.Goexit() in the wrong goroutine.
func TryNewTestOptions(t *testing.T) (TestOptions, error) {
	config, err := cli.LoadConfig("")
	if err != nil {
		return TestOptions{}, fmt.Errorf("failed to read radius config: %w", err)
	}

	contextName, err := kubernetes.GetContextFromConfigFileIfExists("", "")
	if err != nil {
		return TestOptions{}, fmt.Errorf("failed to read k8s config: %w", err)
	}

	k8s, restConfig, err := kubernetes.NewClientset(contextName)
	if err != nil {
		return TestOptions{}, fmt.Errorf("failed to create kubernetes client: %w", err)
	}

	dynamicClient, err := kubernetes.NewDynamicClient(contextName)
	if err != nil {
		return TestOptions{}, fmt.Errorf("failed to create kubernetes dynamic client: %w", err)
	}

	client, err := kubernetes.NewRuntimeClient(contextName, kubernetes.Scheme)
	if err != nil {
		return TestOptions{}, fmt.Errorf("failed to create runtime client: %w", err)
	}

	return TestOptions{
		ConfigFilePath: config.ConfigFileUsed(),
		K8sClient:      k8s,
		K8sConfig:      restConfig,
		Client:         client,
		DynamicClient:  dynamicClient,
	}, nil
}

// NewTestOptions creates a TestOptions struct with the necessary clients and configs for testing.
func NewTestOptions(t *testing.T) TestOptions {
	opts, err := TryNewTestOptions(t)
	require.NoError(t, err)
	return opts
}
