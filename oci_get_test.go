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
/// Test for the OciGet function
/// Please put your endpoint, compartment ID and OCI CLI profile name to the tests variables
/// You can use more than one variable using different profiles and compartments
package ociapisamples

import (
	"testing"
)

func TestOciGet(t *testing.T) {
	//
	var tests = []struct {
		endpoint      string
		compartmentId string
		profile       string
		status        string
	}{
		{"https://iaas.ca-toronto-1.oraclecloud.com",
			"ocid1.compartment.oc1..",
			"DEFAULT",
			"200 OK",
		},
	}
	for _, test := range tests {
		//
		resp := OciGet(test.endpoint, test.compartmentId, test.profile)
		if resp != test.status {
			t.Errorf("OciGet has returned %v when expected %v", resp, test.status)
		}
	}
}
