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
/// Execute one of the procedures in the ociapisamples package
/// For each procedure you need to uncomment and export required input variables.
///
package main

import (
	"fmt"
	"ociapisamples"
	"os"
)

func main() {
	// Call function ociGet() to list instances in the compartment
	endPoint := os.Getenv("ENDPOINT")
	// For example ENDPOINT=https://iaas.ca-toronto-1.oraclecloud.com
	compartmentId := os.Getenv("COMPARTMENTID")
	// For example COMPARTMENTID=ocid1.compartment.oc1..aaa
	profile := os.Getenv("OCIPROFILE")
	// For example  OCIPROFILE=DEFAULT
	//instanceId := os.Getenv("INSTANCEID")
	// For example INSTANCEID=ocid1.instance.oc1.
	//postBodyTmpl := os.Getenv("POSTBODYTMPL")
	// For example POSTBODYTMPL="./post_body.tmpl"
	//putBody := os.Getenv("PUTBODY")
	// For example PUTBODY="./put_body.json"
	//action := os.Getenv("ACTION")
	// For example ACTION=STOP
	//displayName := os.Getenv("DISPLAYNAME")
	// For example DISPLAYNAME="test-inst-ca-02"
	//sshPubKey := os.Getenv("SSHPUBKEY")
	// For example SSHPUBKEY="ssh-rsa AAAA..."
	//subnetId := os.Getenv("SUBNETID")
	// For example SUBNETID=ocid1.subnet.oc1.ca-toronto-1.aaa
	// Execute one of the procedures
	//status := ociapisamples.OciPost(endPoint, compartmentId, profile, postBodyTmpl, displayName, sshPubKey, subnetId)
	//status := ociapisamples.OciGet(endPoint, compartmentId, profile)
	status := ociapisamples.OciListInst(endPoint, compartmentId, profile)
	//status := ociapisamples.OciPut(endPoint, instanceId, profile, putBody)
	//status := ociapisamples.OciAction(endPoint, instanceId, profile, action)
	//status := ociapisamples.OciDelete(endPoint, instanceId, profile)
	//status := "test"
	fmt.Printf("Get response status: %v\n", status)
}
