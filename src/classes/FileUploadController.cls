/**
 * Descripción: This class contains RemoteAction methods for File Upload
 * Date: 10/13/2012
 * Author: José Luis Almazán. Based on Jason Venable (TehNrd) code.
 */
global with sharing class FileUploadController {
	/*
	Description: Method to create an attachment.
	Parameters:
	    parentId: The sfdc object Id this file will be attached to
	    attachmentId: The record of the current Attachment file being processed
	    fileName: Name of the attachment
	    contentTye: Content Type of the file being attached
	    base64BlobValue: Base64 encoded string of the file piece currently processing
    */    
	@RemoteAction
	global static String attachBlob(String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue){
        //If recordId is blank this is the first part of a multi piece upload
        if(attachmentId == '' || attachmentId == null){
            Attachment att = new Attachment(
                ParentId = parentId,
                Body = EncodingUtil.Base64Decode(base64BlobValue),
                Name = fileName,
                ContentType = contentType
            );
            insert att;
            
            //Return the new attachment Id
            return att.Id;
            
        }else{
            for(Attachment atm : [select Id, Body from Attachment where Id = :attachmentId]){
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + base64BlobValue));
            }
            
            //Return the Id of the attachment we are currently processing
        	return attachmentId;
        }
    }

	/*
	Description: Method to delete un attachment.
	Parameters:
    	attachmentId: The record of the current Attachment file to delete
    */
    @RemoteAction
    global static void deleteAttachment(String attachmentId){
        //Delete the attachment
		delete new Attachment(Id = attachmentId);
    }
}