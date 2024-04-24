import { LightningElement, api, track, wire } from 'lwc';
import getSubscribers from '@salesforce/apex/SubscriberController.getSubscribers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SubscriberList extends LightningElement {
    @api pageSize = 10;
    @api includeDisconnected = false;
    @track subscribers = [];
    @track pageNumber = 1;
    @api searchString = '';
    isLoading = false;
    
    searchTimeout;

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Phone', fieldName: 'Phone__c' },
        { label: 'Email', fieldName: 'Email__c' },
        { label: 'Data Used', fieldName: 'Data_Used__c' },
        { label: 'Country', fieldName: 'Country__c' },
        { label: 'Date Joined', fieldName: 'Date_Joined__c' },
        { label: 'Status', fieldName: 'Status__c' },
    ];

    @wire(getSubscribers, {
        searchString: '$searchString',
        pageSize: '$pageSize',
        pageNumber: '$pageNumber',
        includeDisconnected: '$includeDisconnected'
    })
    wiredSubscribers(response) {
        this.isLoading = false;
        console.log(`Calling Apex with pageSize: ${this.pageSize}, pageNumber: ${this.pageNumber}, searchString: '${this.searchString}', includeDisconnected: ${this.includeDisconnected}`);
        console.log(JSON.stringify(response));
        if (response.data) {
            console.log('data:',response.data);
            this.subscribers = response.data;
        } else if (response.error) {
            console.error('Error:', JSON.stringify(response.error));
            this.showToast('Error', error.body.message, 'error');
            this.subscribers = [];
        } else {
            this.showToast('Error', 'No data and no error detected', 'error');
        }
    }

    get isFirstPage() {
        return this.pageNumber <= 1;
    }

    handleSearchChange(event) {
        console.log(`Input Event Target: `, event.target);
        window.clearTimeout(this.searchTimeout);
        const searchValue = event.target.value;

        // Set a new timeout
        this.searchTimeout = window.setTimeout(() => {
            this.searchString = searchValue;
            this.pageNumber = 1;
            this.isLoading = true;
            console.log(`Search String changed to: ${this.searchString}`);
        }, 300); // Wait for 300 ms before executing the search
    }

    handleCheckboxChange(event) {
        this.includeDisconnected = event.target.checked;
        this.pageNumber = 1;
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber--;
            this.isLoading = true;
        }
    }

    handleNext() {
        this.pageNumber++;
        this.isLoading = true;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }

}
