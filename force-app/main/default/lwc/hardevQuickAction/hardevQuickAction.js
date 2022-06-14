import { LightningElement, api, track, wire } from 'lwc';

import loadComments from '@salesforce/apex/CommentController.loadComments';

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

    changeComment(element) {
        let commentId = element.currentTarget.dataset.commentId;
        let selectComment = this.comments.find(item => item.Id == commentId);
        selectComment.Comment = element.target.value;
    }

    debugComments() {
        console.log(JSON.stringify(this.comments));
        console.log(JSON.stringify(this.removedComments));
    }

}