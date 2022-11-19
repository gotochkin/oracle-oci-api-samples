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
/// Get list of instances in a compartment using http package
///

package ociapisamples

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"time"

	common "github.com/oracle/oci-go-sdk/common"
)

func OciGet(endPoint string, compartmentId string, profile string) (status string) {
	fmt.Println("Start")
	// Create URL
	restApi := "/20160918/instances"
	//Filter by URL parameters
	//url := endPoint + restApi + "?compartmentId=" + compartmentId + "&displayName=bastion-ca"
	url := endPoint + restApi + "?compartmentId=" + compartmentId
	// create a request
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		log.Fatal(err)
	}

	// Set the header with date in UTC using http format
	req.Header.Set("Date", time.Now().UTC().Format(http.TimeFormat))

	//Get the provider cofig data using custom profile
	provider := common.CustomProfileConfigProvider("~/.oci/config", profile)

	//Get the provider cofig data using default profile
	//provider := common.DefaultConfigProvider()

	//Get the signer
	signer := common.DefaultRequestSigner(provider)

	//Sign the request
	signer.Sign(req)

	//Create client
	client := http.Client{}

	//List headers
	for name, headers := range req.Header {
		for _, h := range headers {
			log.Printf("%v: %v\n", name, h)
		}
	}

	//Send the request and get response
	resp, err := client.Do(req)
	if err != nil {
		log.Fatal(err)
	}

	defer resp.Body.Close()

	//Print response status and headers
	log.Println("response Status:", resp.Status)
	log.Println("response Headers:", resp.Header)

	body, _ := ioutil.ReadAll(resp.Body)
	//Printing entire body
	//log.Println("response Body:", string(body))

	//Parsing the response
	var responseArray []map[string]interface{}
	err = json.Unmarshal(body, &responseArray)
	if err != nil {
		log.Fatal(err)
	}

	for i := range responseArray {
		displayName := responseArray[i]["displayName"].(string)
		shape := responseArray[i]["shape"].(string)
		lifecycleState := responseArray[i]["lifecycleState"].(string)
		fmt.Printf("displayName: %v shape: %v lifecycleState: %v\n", displayName, shape, lifecycleState)

	}
	//Return the status
	return resp.Status

}
