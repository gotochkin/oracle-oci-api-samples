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
/// Create an instance using POST using http package
///

package ociapisamples

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"text/template"
	"time"

	common "github.com/oracle/oci-go-sdk/common"
)

func OciPost(endPoint string, compartmentId string, profile string, postBodyTmpl string, displayName string, sshPubKey string, subnetId string) (status string) {
	fmt.Println("Start")
	// Create URL
	restApi := "/20160918/instances"

	url := endPoint + restApi
	fmt.Println(url)

	// Template variables
	tmplvars := make(map[string]interface{})
	tmplvars["compartmentId"] = compartmentId
	tmplvars["displayName"] = displayName
	tmplvars["sshPubKey"] = sshPubKey
	tmplvars["subnetId"] = subnetId

	if _, err := os.Stat(postBodyTmpl); err == nil {
		tmpl, _ := template.ParseFiles(postBodyTmpl)
		postBody, _ := os.Create("./post_body.json")
		defer postBody.Close()
		err := tmpl.Execute(postBody, tmplvars)
		if err != nil {
			log.Fatalln(err)
		}
		//postBody.Close()
	} else if errors.Is(err, os.ErrNotExist) {
		fmt.Println("The template " + postBodyTmpl + " doesn't exist!")
	}

	bodyReader, err := os.Open("./post_body.json")
	if err != nil {
		log.Fatal(err)
	}
	defer bodyReader.Close()
	// create a request
	req, err := http.NewRequest("POST", url, bodyReader)
	if err != nil {
		log.Fatal(err)
	}

	// Set the header with date in UTC using http format
	req.Header.Set("Date", time.Now().UTC().Format(http.TimeFormat))

	req.Header.Set("content-type", "application/json")

	//Get the provider cofig data using custom profile
	provider := common.CustomProfileConfigProvider("~/.oci/config", profile)

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

	//Print response status
	log.Println("response Status:", resp.Status)
	log.Println("response Headers:", resp.Header)

	body, _ := ioutil.ReadAll(resp.Body)
	//Printing entire body
	//log.Println("response Body:", string(body))

	var responseBody map[string]interface{}
	err = json.Unmarshal(body, &responseBody)
	if err != nil {
		log.Fatal(err)
	}

	//Printing only three properties for the created instance
	dispName := responseBody["displayName"].(string)
	shape := responseBody["shape"].(string)
	lifecycleState := responseBody["lifecycleState"].(string)
	fmt.Printf("displayName: %v \nshape: %v \nlifecycleState: %v\n", dispName, shape, lifecycleState)

	//Remove the temporary json file
	if _, err := os.Stat("./post_body.json"); err == nil {
		err := os.Remove("./post_body.json")
		if err != nil {
			log.Fatal(err)
		}
	} else if errors.Is(err, os.ErrNotExist) {
		fmt.Println("The file ./post_body.json doesn't exist!")
	}
	//Return the status
	return resp.Status
}
