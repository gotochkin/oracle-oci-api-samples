// Copyright 2022 Gleb Otochkin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
/// Get list of instances in a compartment using Oracle SDK for Go
///

package ociapisamples

import (
	"context"
	"fmt"
	"log"

	common "github.com/oracle/oci-go-sdk/common"
	core "github.com/oracle/oci-go-sdk/core"
)

func OciListInst(endPoint string, compartmentId string, profile string) (status string) {
	fmt.Println("Start")
	// Get the provider using oci cli config file and the profile name
	provider := common.CustomProfileConfigProvider("~/.oci/config", profile)

	client, err := core.NewComputeClientWithConfigurationProvider(provider)
	if err != nil {
		log.Fatal(err)
	}

	req := core.ListInstancesRequest{CompartmentId: common.String(compartmentId)}

	//Send the request and get response
	resp, err := client.ListInstances(context.Background(), req)
	if err != nil {
		log.Fatal(err)
	}

	for _, v := range resp.Items {
		displayName := *v.DisplayName
		shape := *v.Shape
		lifecycleState := *&v.LifecycleState
		fmt.Printf("displayName: %v shape: %v lifecycleState: %v\n", displayName, shape, lifecycleState)
	}
	//Return the status
	return resp.RawResponse.Status
}
