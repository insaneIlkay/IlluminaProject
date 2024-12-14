import { LightningElement, track } from 'lwc';
import getLocationData from '@salesforce/apex/zipCodeInputScreenController.getLocationData';
import saveNonUSData from '@salesforce/apex/zipCodeInputScreenController.saveNonUSData';

export default class ZipcodeSearch extends LightningElement {
    zipCode = '';
    @track locationData;
    isUsLocation = false;
    countryMapping = [
        { country: "Andorra", code: "AD", range: ["AD100", "AD700"] },
        { country: "India", code: "IN", range: ["110001", "855126"] },
        { country: "United States", code: "US", range: ["00210", "99950"] },
        { country: "Mexico", code: "MX", range: ["01000", "99998"] }
    ];
    baseApiUrl = "http://api.zippopotam.us/";

    isZipCodeInRange(zipCode, range) {
        if (zipCode.length !== range[0].length) {
            zipCode = zipCode.padStart(range[0].length, "0"); 
        }
        return zipCode >= range[0] && zipCode <= range[1];
    }

    getApiUrl(zipCode) {
        for (const country of this.countryMapping) {
            if (this.isZipCodeInRange(zipCode, country.range)) {
                return {
                    country: country.country,
                    apiUrl: `${this.baseApiUrl}${country.code}/${zipCode}`, 
                };
            }
        }
        return { error: "No country found for this zip code." };
    }

    handleZipCodeChange(event) {
        this.zipCode = event.target.value;
    }

    handleSearch() {
        let url = this.getApiUrl(this.zipCode);
        if(this.zipCode && url) {
            getLocationData({ zipCode: this.zipCode, baseUrl: url.apiUrl })
                .then(result => {
                    this.locationData = result;
                    if (result.country === 'United States') {
                        this.isUsLocation = true;
                    } else {
                        const locationData = {
                            city: result.city,
                            country: result.country,
                            state: result.state,
                            zipcode: result.zipcode
                        };
                        console.log('@DS locationData'+JSON.stringify(locationData));
                        saveNonUSData({ data: locationData })
                            .then(() => {
                                console.log('Non-US location data saved successfully.');
                            })
                            .catch(error => {
                                console.error('Error saving non-US data: ', error);
                            });
                    }
                })
                .catch(error => {
                    console.error("Error fetching location data: ", error);
                });
        }
    }
}