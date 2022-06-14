import { LightningElement, api, track, wire } from 'lwc';

import loadComments from '@salesforce/apex/CommentController.loadComments';

export default class HardevQuickAction extends LightningElement {

    @api recordId;
    @track comments;

    connectedCallback() {
        console.log('iniciando');

        this.comments = [];
        this.loadAccountComments();
    }

    async loadAccountComments() {
        let response = await loadComments({
            accountId : this.recordId
        });

        if (response && !response.HasError && response.ResponseJSON) {
            this.comments = JSON.parse(response.ResponseJSON);
            console.log('Comments =>', JSON.stringify(this.comments));
        }
    }

}