import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';

import loadComments from '@salesforce/apex/CommentController.loadComments';
import saveComments from '@salesforce/apex/CommentController.saveComments';

export default class HardevQuickAction extends LightningElement {

    @api recordId;
    @track comments;
    @track countId = 0;
    @track removedComments = [];

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

    addNewComment() {
        this.comments.push({
            Comment     : '',
            AccountId   : this.recordId,
            Type        : '_new_',
            Id          : this.countId,
        });

        this.countId++;
    }

    removeComment(element) {
        let commentId = element.currentTarget.dataset.commentId;
        let selectComment = this.comments.find(item => item.Id == commentId);
        //let index = this.comments.findIndex(item => item.Id == commentId);
        //this.comments.splice(index, 1);
        
        if (selectComment.Type == '_database_') {
            this.removedComments.push(commentId);
        }

        this.comments = this.comments.filter(item => item.Id != commentId);
    }

    async removeCommentAPI(element) {
        let commentId = element.currentTarget.dataset.commentId;
        let selectComment = this.comments.find(item => item.Id == commentId);

        if (selectComment.Type == '_database_') {
            let response = await deleteRecord(commentId);
            console.log(JSON.stringify(response));
            const event = new ShowToastEvent({
                title   : 'Success',
                message : 'Comment removed successfully',
                variant : 'success'
            });
            this.dispatchEvent(event);
        }

        this.comments = this.comments.filter(item => item.Id != commentId);
        
    }

    changeComment(element) {
        let commentId           = element.currentTarget.dataset.commentId;
        let selectComment       = this.comments.find(item => item.Id == commentId);
        selectComment.Comment   = element.target.value;
    }

    async saveAccountComments() {
        let response = await saveComments({
            accountId       : this.recordId,
            commentsJSON    : JSON.stringify(this.comments),
            removedComments : this.removedComments
        });
        console.log(JSON.stringify(response));
        this.showToast(response);
        
    }

    debugComments() {
        console.log(JSON.stringify(this.comments));
        console.log(JSON.stringify(this.removedComments));
    }

    showToast(response) {
        const event = new ShowToastEvent({
            title   : response.ToastInfo.Title,
            message : response.ToastInfo.Message,
            variant : response.ToastInfo.Type
        });
        this.dispatchEvent(event);
    }

}