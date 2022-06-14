public with sharing class ActionResponse {
    public ActionResponse() {}

    public class ToastInfo {
        public String Title   {get; set;}
        public String Message {get; set;}
        public String Type    {get; set;}

        public ToastInfo(String title, String message, String type) {
            this.Title   = title;  
            this.Message = message;
            this.Type    = type;  
        }
    }

    public class Response {

        public Boolean HasError      {get; set;}
        public Boolean BusinessError {get; set;}
        public String Message        {get; set;}
        public String ResponseJSON   {get; set;}
        public ToastInfo ToastInfo   {get; set;}

        public Response (Boolean businessError, String message, String responseJSON) {
            this.HasError       = businessError;
            this.BusinessError  = businessError;
            this.Message        = message;
            this.ResponseJSON   = responseJSON;
            this.fillToast ();
        }

        public Response (Exception e) {
            this.HasError       = true;
            this.businessError  = false;
            this.Message        = e.getMessage();
            this.ResponseJSON   = '';
            this.fillToast ();

        }

        public void fillToast () {
            if (!this.HasError) {
                this.ToastInfo = new ToastInfo ('Success', this.Message, 'success');
            } 
            else if (this.BusinessError) {
                this.ToastInfo = new ToastInfo ('Alert', this.Message, 'warning');
            }
            else {
                this.ToastInfo = new ToastInfo ('Erro', this.Message, 'error');
            }
        }
    }
}
