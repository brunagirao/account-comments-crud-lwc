public with sharing class CommentController {
    public CommentController() {}

    @AuraEnabled
    public static  ActionResponse.Response saveComments (String accountId, String commentsJSON, List<String> removedComments) {
        try {

            List<AccountComment__c> accountCommentsToDelete = [
                SELECT Id
                  FROM AccountComment__c
                 WHERE Id IN: removedComments
                 
            ];
            delete accountCommentsToDelete;

            List<CommentVO> commentVOList = (List<CommentVO>)JSON.deserialize(commentsJSON, List<CommentVO>.class);
            List<AccountComment__c> accountCommentList = convertToAccountComment(commentVOList);

            upsert accountCommentList;

             ActionResponse.Response response = new ActionResponse.Response(
                false, 'Comentários salvos com sucesso', ''
             );

             return response;
                
        } catch (Exception e) {
            return new ActionResponse.Response(e);
        }
        
        
    }

    public static List<AccountComment__c> convertToAccountComment(List<CommentVO> commentVOList) {
        List<AccountComment__c> accountCommentList = new List<AccountComment__c>();
        
        for(CommentVO comment : commentVOList) {
            accountCommentList.add(
                comment.getAccountComment()
            );
        }

        return accountCommentList;
    }
 
    
    @AuraEnabled
    public static ActionResponse.Response loadComments (String accountId) {
        
        try {
           List<AccountComment__c> accountCommentList = [
                SELECT Id, Name, Comment__c, Account__c
                  FROM AccountComment__c
                 WHERE Account__c =: accountId
            ];

            List<CommentVO> commentVOList = convertToCommentVO(accountCommentList);

            ActionResponse.Response response = new ActionResponse.Response (
                false, '', JSON.serialize(commentVOList)
            );

            return response; 

        } catch (Exception e) {
            return new ActionResponse.Response(e);
        }

    }

    public static List<CommentVO> convertToCommentVO(List<AccountComment__c> accountCommentList) {
        List<CommentVO> commentVOList = new List<CommentVO>();
        
        for(AccountComment__c comment : accountCommentList) {
            commentVOList.add(
                new CommentVO(comment, '_database_')
            );
        }

        return commentVOList;
    }

    public class CommentVO {
        @AuraEnabled public String Id        {get; set; }
        @AuraEnabled public String Comment   {get; set; }
        @AuraEnabled public String AccountId {get; set; }
        @AuraEnabled public String Type      {get; set; }

        public CommentVO(AccountComment__c comment, String type) {
            this.Id         = comment.Id;
            this.Comment    = checkComment(comment.Comment__c);
            this.AccountId  = comment.Account__c;
            this.Type       = type;
        }

        public AccountComment__c getAccountComment() {
            AccountComment__c comment = new AccountComment__c(
                Comment__c = this.Comment,
                Account__c = this.AccountId
            );

            if(this.Type == '_database_') {
                comment.Id = this.Id;
            }

            return comment;
        }

        public String checkComment(String comment) {
            if(String.isBlank(comment)) return '';
            else return comment;
        }
    }
}
