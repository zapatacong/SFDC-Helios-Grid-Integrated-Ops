import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

// Import the specific field from the Asset object
import EFFICIENCY_FIELD from '@salesforce/schema/Asset.Efficiency_Rating__c';

export default class InverterHealthGauge extends LightningElement {
    @api recordId; // Automatically populated with the Asset ID from the page

    // Wire the data from Salesforce to the 'asset' property
    @wire(getRecord, { recordId: '$recordId', fields: [EFFICIENCY_FIELD] })
    asset;

    // Helper to get the numeric value
    get efficiency() {
        return getFieldValue(this.asset.data, EFFICIENCY_FIELD) || 0;
    }

    // Dynamic CSS class for the progress bar color
    get gaugeClass() {
        if (this.efficiency >= 90) return 'slds-progress-bar__value slds-is-success'; // Green
        if (this.efficiency >= 80) return 'slds-progress-bar__value slds-is-warning'; // Yellow (Custom or SLDS)
        return 'slds-progress-bar__value slds-is-error'; // Red
    }

    // Dynamic width based on the percentage
    get gaugeStyle() {
        return `width: ${this.efficiency}%`;
    }

    // Human-readable status message
    get statusMessage() {
        if (this.efficiency >= 90) return 'OPTIMAL PERFORMANCE';
        if (this.efficiency >= 80) return 'DEGRADED PERFORMANCE - MONITOR';
        return 'CRITICAL FAILURE - MAINTENANCE REQUIRED';
    }

    get statusBadgeClass() {
        let base = 'slds-badge ';
        if (this.efficiency >= 90) return base + 'slds-theme_success';
        if (this.efficiency >= 80) return base + 'slds-theme_warning';
        return base + 'slds-theme_error';
    }
}