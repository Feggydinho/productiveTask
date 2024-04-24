import { LightningElement, track, api } from 'lwc';
import getAllSubscribers from '@salesforce/apex/SubscriberController.getAllSubscribers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SubscriberListClientFilter extends LightningElement {
    @track subscribers = [];
    @api pageNumber = 1;
    @api pageSize = 10;
    @track searchString = '';
    @api includeDisconnected = false;
    @api totalRecords = 0;
    allSubscribers = [];  // Stores the original data

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Phone', fieldName: 'Phone__c' },
        { label: 'Email', fieldName: 'Email__c' },
        { label: 'Data Used', fieldName: 'Data_Used__c' },
        { label: 'Country', fieldName: 'Country__c' },
        { label: 'Date Joined', fieldName: 'Date_Joined__c' },
        { label: 'Status', fieldName: 'Status__c' },
    ];

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        getAllSubscribers()
            .then(result => {
                this.allSubscribers = result;
                this.applyFilters();
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    applyFilters() {
        let filteredData = this.allSubscribers.filter(sub => {
            const nameMatch = sub.Name.toLowerCase().includes(this.searchString.toLowerCase());
            const phoneMatch = sub.Phone__c.toLowerCase().includes(this.searchString.toLowerCase());
            const emailMatch = sub.Email__c.toLowerCase().includes(this.searchString.toLowerCase());
            const searchMatch = nameMatch || phoneMatch || emailMatch;
            const statusMatch = this.includeDisconnected ? true : sub.Status__c !== 'DISCONNECTED';
            return searchMatch && statusMatch;
        });
        this.totalRecords = filteredData.length;
        this.updatePageData(filteredData);
    }

    updatePageData(filteredData) {
        const startIndex = (this.pageNumber - 1) * this.pageSize;
        const endIndex = startIndex + this.pageSize;
        this.subscribers = filteredData.slice(startIndex, endIndex);
    }

    handleSearchChange(event) {
        this.searchString = event.target.value;
        this.debounce(() => {
            this.pageNumber = 1;
            this.applyFilters();
        });
    }

    handleCheckboxChange(event) {
        this.includeDisconnected = event.target.checked;
        this.pageNumber = 1;
        this.applyFilters();
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber--;
            this.applyFilters();
        }
    }

    handleNext() {
        if (this.pageNumber < Math.ceil(this.totalRecords / this.pageSize)) {
            this.pageNumber++;
            this.applyFilters();
        }
    }

    debounce(fn, delay = 300) {
        window.clearTimeout(this.searchTimeout);
        this.searchTimeout = window.setTimeout(() => {
            fn();
        }, delay);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }

    get isFirstPage() {
        return this.pageNumber === 1;
    }

    get isLastPage() {
        return this.pageNumber >= Math.ceil(this.totalRecords / this.pageSize);
    }
}
