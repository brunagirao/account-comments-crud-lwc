public with sharing class CommentController {
    public CommentController() {}

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
        public String Id        {get; set; }
        public String Comment   {get; set; }
        public String AccountId {get; set; }
        public String Type      {get; set; }

        public CommentVO(AccountComment__c comment, String type) {
            this.Id         = comment.Id;
            this.Comment    = checkComment(comment.Comment__c);
            this.AccountId  = comment.Account__c;
            this.Type       = type;
        }

        public String checkComment(String comment) {
            if(String.isBlank(comment)) return '';
            else return comment;
        }
    }
}
